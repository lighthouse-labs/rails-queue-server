class Section < ApplicationRecord

  has_many :activities
  has_many :activity_submissions, through: :activities
  belongs_to :content_repository # when remote content

  default_scope { order(order: :asc) }

  scope :archived,  -> { where(archived: true) }
  scope :active,    -> { where(archived: [false, nil]) }

  validates :slug, presence: true, uniqueness: true

  def to_param
    slug
  end

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
