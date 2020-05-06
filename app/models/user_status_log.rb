class UserStatusLog < ApplicationRecord

  belongs_to :user

  validates :status, inclusion: { in: %w[on_duty off_duty busy not_busy] }
  scope :today, -> { where(created_at: DateTime.now.beginning_of_day..DateTime.now.end_of_day) }

  def on_duty?
    status == 'on_duty'
  end

  def off_duty?
    status == 'off_duty'
  end

end
