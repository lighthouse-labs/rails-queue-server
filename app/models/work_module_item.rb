class WorkModuleItem < ApplicationRecord

  default_scope { order(sequence: :asc) }

  ## ASSOCIATIONS

  belongs_to :work_module
  belongs_to :activity

  ## VALIDATIONS

  validates :work_module, presence: true
  validates :activity, presence: true

  ## SCOPES

  scope :active,  -> { where(archived: [false, nil]) }
  scope :core,    -> { where(stretch: [false, nil]) }
  scope :stretch, -> { where(stretch: true) }

  ## CLASS METHODS / ADDITIONAL SCOPES

  def self.calc_total_duration
    all.inject(0) do |sum, item|
      if item.activity&.active?
        sum + (item.activity.average_time_spent || item.activity.duration || 0)
      else
        sum
      end
    end / 60.0
  end

end
