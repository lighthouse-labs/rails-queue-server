class Location < ApplicationRecord

  has_many :users
  has_many :cohorts
  has_many :programs

  belongs_to :supported_by_location, class_name: 'Location' # nullable

  scope :active, -> { where(active: true) }

  def education_manager_location
    Location.find_by(id: supported_by_location_id) || self
  end

end
