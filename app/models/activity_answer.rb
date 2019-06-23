class ActivityAnswer < ApplicationRecord
  belongs_to :activity
  belongs_to :user

  # Don't update the answer text if already toggled previously (not allowed)
  # Note: allows empty string ("") for new_answer_text
  def update_state(new_answer_text, new_toggled)
    self.answer_text = new_answer_text if new_answer_text && !toggled?
    self.toggled ||= true if new_toggled
    save!
  end

end
