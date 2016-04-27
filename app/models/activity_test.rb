class ActivityTest < ActiveRecord::Base
  belongs_to :activity

  # validates :activity, presence: true
  validates :test, presence: true
  
end