class Workbook < ApplicationRecord

  ## ASSOCIATIONS

  belongs_to :content_repository
  has_many :work_modules

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
    end
  end

  ## INSTANCE METHODS

  def to_param
    slug
  end

end
