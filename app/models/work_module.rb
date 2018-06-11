class WorkModule < ApplicationRecord

  default_scope { order(sequence: :asc) }

  ## ASSOCIATIONS

  belongs_to :workbook
  has_many :work_module_items, { inverse_of: :work_module, dependent: :destroy }, -> { order(sequence: :asc) }
  has_many :activities, { through: :work_module_items }, -> { order(work_module_items: { sequence: :asc }) }

  ## VALIDATIONS

  validates :name, presence: true
  validates :uuid, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  ## SCOPES

  scope :active, -> { where(archived: [false, nil]) }

  ## INSTANCE METHODS

  def core_duration_in_hours
    # add 10% for buffer
    @core_duration_in_hours ||= sum_duration_for(work_module_items.active.core)
  end

  def stretch_duration_in_hours
    # add 10% for buffer
    @stretch_duration_in_hours ||= sum_duration_for(work_module_items.active.stretch)
  end

  def total_duration_in_hours
    # add 10% for buffer
    @total_duration_in_hours ||= sum_duration_for(work_module_items.active)
  end

  private

  def sum_duration_for(items)
    items.inject(0) do |sum, item|
      if item.activity&.active?
        sum + (item.activity.average_time_spent || item.activity.duration || 0)
      else
        sum
      end
    end / 60.0
  end

end
