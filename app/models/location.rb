class Location < ApplicationRecord

  has_many :users
  has_many :cohorts
  has_many :programs

end