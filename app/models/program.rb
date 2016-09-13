class Program < ApplicationRecord

  has_many :cohorts
  has_many :recordings

  validates :name, presence: true

end
