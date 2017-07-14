class AssistanceRequestDestroyer
  def run
    Rails.logger.info "Running..."

    remove_assistance_requests
    remove_tech_interviews

    Rails.logger.info "Complete!"
  end

  private

  def remove_assistance_requests
    Rails.logger.info "Removing Assistance Requests"
    assistance_requests = AssistanceRequest.where(assistance_id: nil, canceled_at: nil)

    Rails.logger.info "#{assistance_requests.count} entries found."
    assistance_requests.delete_all
  end

  def remove_tech_interviews
    Rails.logger.info "Removing Tech Interviews"
    interviews = TechInterview.where(started_at: nil)

    Rails.logger.info "#{interviews.count} entries found."
    interviews.delete_all
  end

end
