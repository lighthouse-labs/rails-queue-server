class OutcomeResult < ActiveRecord::Base
  belongs_to :user
  belongs_to :outcome
  belongs_to :source, polymorphic: true

  before_validation :populate_source

  validates :user, presence: true
  validates :outcome, presence: true
  # BTW rating is intentionally nullable (when student says they didn't see that) - KV

  protected

  def populate_source
    self.source_name ||= self.source_type
  end
end
