class Article < ApplicationRecord

  has_many :comments, dependent: :destroy
  has_and_belongs_to_many :categories
  belongs_to :user

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }

end
