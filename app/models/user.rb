class User < ApplicationRecord
  has_many :articles
  has_many :comments
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  before_create :set_default_role
  
  enum role: { user: 0, moderator: 1, admin: 2 }
  after_initialize :set_default_role, if: -> { new_record? }
  validates :username, uniqueness: { allow_nil: true }

  def set_default_role
    self.role ||= :user
  end
  
end
