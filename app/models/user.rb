require "jwt"

class User < ApplicationRecord
  self.primary_key = :uuid

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :group_users, dependent: :destroy
  has_many :groups, through: :group_users
  has_many :teams, through: :group_users, dependent: :destroy

  mount_base64_uploader :avatar, AvatarUploader

  def create_authentication_token
    if self.authentication_token.present? && verify_authentication_token(self.authentication_token)&.last.key?("alg")
      return self.authentication_token
    else
      hmac_secret = ENV["HMAC_SECRET_KEY"]

      payload = { id: self.id, name: self.name, exp: (Time.now + 1.week).to_i }
      token = JWT.encode payload, hmac_secret, "HS256"

      self.update!(authentication_token: token)
      return token
    end
  end

  def verify_authentication_token(token)
    begin
      return JWT.decode token, ENV["HMAC_SECRET_KEY"], true, { algorithm: "HS256" }
    rescue
      return [{ error: "Invalid token" }]
    end
  end
end
