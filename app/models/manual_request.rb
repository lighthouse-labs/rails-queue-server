class ManualRequest < AssistanceRequest
  validates :requestor, presence: true

end
