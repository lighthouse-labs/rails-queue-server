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
    @core_duration_in_hours ||= work_module_items.active.core.calc_total_duration
  end

  def stretch_duration_in_hours
    # add 10% for buffer
    @stretch_duration_in_hours ||= work_module_items.active.stretch.calc_total_duration
  end

  def total_duration_in_hours
    # add 10% for buffer
    @total_duration_in_hours ||= work_module_items.active.calc_total_duration
  end

end
