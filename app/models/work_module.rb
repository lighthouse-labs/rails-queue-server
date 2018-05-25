class WorkModule < ApplicationRecord

  default_scope { order(order: :asc) }

  ## ASSOCIATIONS

  belongs_to :workbook
  has_many :work_module_items, -> { order(order: :asc) }
  has_many :activities, { through: :work_module_items }, -> { order(work_module_items: { order: :asc }) }

  ## VALIDATIONS

  validates :name, presence: true
  validates :uuid, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  ## SCOPES

  scope :active, -> { where(archived: [false, nil]) }

  ## INSTANCE METHODS

  def core_duration_in_hours
    # add 10% for buffer
    @core_duration_in_hours ||= (activities.active.core.sum(:duration) / 60.0) * 1.1
  end

  def stretch_duration_in_hours
    # add 10% for buffer
    @stretch_duration_in_hours ||= (activities.active.stretch.sum(:duration) / 60.0) * 1.1
  end

  def total_duration_in_hours
    # add 10% for buffer
    @total_duration_in_hours ||= (activities.active.sum(:duration) / 60.0) * 1.1
  end

end
