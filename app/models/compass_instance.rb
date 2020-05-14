class CompassInstance < ApplicationRecord
  has_many :assistance_requests

  def has_feature?(feature_flag)
    settings? && settings['features'].present? && settings['features'][feature_flag.to_s].to_s.casecmp('true').zero?
  end

end