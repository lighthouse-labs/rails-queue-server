class ActivityFeedback < ApplicationRecord

  belongs_to :activity
  belongs_to :user

  validates :user, presence: true
  validates :activity, presence: true
  validate :at_least_some_feedback

  default_scope -> { order(created_at: :desc) }

  def positive?
    sentiment == 1
  end

  def negative?
    sentiment == -1
  end

  def ok?
    sentiment == 0
  end

  private

  def at_least_some_feedback
    errors.add(:base, "Need at least some feedback (rating and/or detail) please!") if self.rating.blank? && self.detail.blank?
  end

end
