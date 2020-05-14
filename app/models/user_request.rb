class UserRequest < AssistanceRequest
  validates :requestor, presence: true

  before_create :limit_one_per_user

  private

  def limit_one_per_user
    if UserRequest.requested_by(requestor['uid']).open_or_in_progress_requests.exists?
      errors.add :base, 'Limit one open/in progress request per user'
      false
    end
  end

end
