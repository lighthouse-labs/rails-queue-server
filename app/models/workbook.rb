class Workbook < ApplicationRecord

  ## ASSOCIATIONS

  belongs_to :content_repository
  has_many :work_modules
  has_many :work_module_items, through: :work_modules
  has_many :activities, through: :work_module_items

  ## VALIDATIONS

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :uuid, presence: true, uniqueness: true

  ## SCOPES

  scope :publicly_available, -> { where(public: true) }
  scope :unlocks_on_day, ->(day) { where(unlock_on_day: day.to_s) }
  scope :until_day, ->(day) { where("workbooks.unlock_on_day <= ?", day.to_s) }
  scope :prep, -> { where(unlock_on_day: [nil, '']) }
  scope :active, -> { where(archived: [false, nil]) }

  ## CLASS METHODS (SCOPES)

  def self.available_to(user)
    workbooks = Workbook.active
    if user.nil?
      workbooks.publicly_available
    elsif user.is_a?(Student)
      workbooks.until_day(user.curriculum_day)
    elsif user.prospect?
      workbooks.prep
    else
      workbooks
    end
  end

  def next_activity(activity)
    current_item = work_module_items.active.where(activity_id: activity).first
    next_item = current_item.work_module.work_module_items.active.where('work_module_items.sequence > ?', current_item.sequence).first ||
                work_modules.active.where('work_modules.sequence > ?', current_item.work_module.sequence).first&.work_module_items&.active&.first
    next_item&.activity
  end

  def previous_activity(activity)
    current_item = work_module_items.where(activity_id: activity).first
    prev_item = current_item.work_module.work_module_items.active.where('work_module_items.sequence < ?', current_item.sequence).last ||
                work_modules.active.where('work_modules.sequence < ?', current_item.work_module.sequence).last&.work_module_items&.active&.last
    prev_item&.activity
  end

  ## INSTANCE METHODS

  def to_param
    slug
  end

  def total_duration
    activities.active.sum(:duration)
  end

end
