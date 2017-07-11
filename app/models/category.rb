class Category < ApplicationRecord

  has_many :skills, dependent: :destroy
  validates :name, uniqueness: { case_sensitive: false }

end
