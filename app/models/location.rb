class Location < ApplicationRecord
  has_many :users
  has_many :cohorts
  has_many :programs

  belongs_to :supported_by_location, class_name: 'Location' # nullable
end
