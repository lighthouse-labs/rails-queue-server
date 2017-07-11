class ActivityTest < ApplicationRecord

  belongs_to :activity

  # validates :activity, presence: true
  validates :test, presence: true

end
