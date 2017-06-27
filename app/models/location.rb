class Location < ApplicationRecord

  has_many :users
  has_many :cohorts
  has_many :programs

  belongs_to :supported_by_location, class_name: 'Location' # nullable
  has_many :satellite_locations, class_name: "Location",  foreign_key: "supported_by_location_id"

  def satellite?
    !!supported_by_location
  end

end
