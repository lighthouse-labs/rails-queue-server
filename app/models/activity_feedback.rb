class ActivityFeedback < ActiveRecord::Base

  belongs_to :activity
  belongs_to :user

  validates :user, presence: true
  validates :activity, presence: true

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

end
