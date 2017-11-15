class Location < ApplicationRecord

  has_many :users
  has_many :cohorts
  has_many :programs

  belongs_to :supported_by_location, class_name: 'Location' # nullable

  def em_location
    if self.supported_by_location_id != nil
      Location.find(self.supported_by_location_id)
    else
      self
    end
  end

end
