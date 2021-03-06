class Group < ApplicationRecord
  self.primary_key = :uuid

  has_many :group_users, dependent: :destroy
  has_many :users, through: :group_users
  has_many :teams, through: :group_users

  def is_admin(user)
    self.group_users.where(is_admin: true).first.user == user
  end
end
