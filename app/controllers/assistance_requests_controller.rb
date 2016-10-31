class AssistanceRequestsController < ApplicationController

  #before_action :selected_cohort_locations, only: [:index, :queue]
  before_action :teacher_required, only: [:index, :destroy, :start_assistance, :end_assistance, :queue]

  def index
    @all_locations = Location.where("id IN (?)", Cohort.all.map(&:location_id).uniq).map{|l| LocationSerializer.new(l, root: false).as_json}

    render component: "RequestQueue",
      props: {
        locations: @all_locations,
        user: UserSerializer.new(current_user).as_json
      }
  end

  def queue
    my_active_assistances = Assistance.assisted_by(current_user).currently_active
    requests = AssistanceRequest.where(type: nil).open_requests.oldest_requests_first.requestor_cohort_in_locations([params[:location]])
    code_reviews = CodeReviewRequest.open_requests.oldest_requests_first.requestor_cohort_in_locations([params[:location]])
    my_active_evaluations = Evaluation.where(teacher: current_user).where(state: "in_progress").newest_active_evaluations_first
    evaluations = Evaluation.open_evaluations.oldest_first.student_location(current_user.location)
    my_active_interviews = TechInterview.in_progress.interviewed_by(current_user)
    interviews = can_tech_interview? ? TechInterview.oldest_first.queued.interviewee_location(current_user.location) : []
    all_students = Student.in_active_cohort.active.order_by_last_assisted_at

    # For satellite mentors, show them their local students under All Students
    if current_user.location.try(:satellite?)
      all_students = all_students.where(location_id: current_user.location_id)
    else
      all_students = all_students.cohort_in_locations([params[:location]])
    end

    render json: RequestQueueSerializer.new(assistances: my_active_assistances,
                                            requests: requests,
                                            code_reviews: code_reviews,
                                            active_evaluations: my_active_evaluations,
                                            evaluations: evaluations,
                                            active_tech_interviews: my_active_interviews,
                                            tech_interviews: interviews,
                                            students: all_students).as_json
  end

  def status
    respond_to do |format|
      format.json {
        # Fetch most recent student initiated request
        ar = current_user.assistance_requests.where(type: nil).newest_requests_first.first
        res = {}
        if ar.try(:open?)
          res[:state] = :waiting
          res[:position_in_queue] = ar.position_in_queue
        elsif ar.try(:in_progress?)
          res[:state] = :active
          res[:assistor] = {
              id: ar.assistance.assistor.id,
              first_name: ar.assistance.assistor.first_name,
              last_name: ar.assistance.assistor.last_name
          }
        else
          res[:state] = :inactive
        end
        render json: res
      }
      format.all { redirect_to(assistance_requests_path) }
    end
  end

  def destroy
    ar = AssistanceRequest.find params[:id]
    status = ar.try(:cancel) ? 200 : 409

    respond_to do |format|
      format.json { render(:nothing => true, :status => status) }
      format.all { redirect_to(assistance_requests_path) }
    end
  end

  private

  def selected_cohort_locations
    locations_cookie = cookies[:cohort_locations]
    # The length thing is a hacky/lazy of getting around a JSON parse exception - KV
    #   http://stackoverflow.com/questions/8390256/a-json-text-must-at-least-contain-two-octets
    @selected_locations = locations_cookie && locations_cookie.to_s.length >= 2 ? JSON.parse(locations_cookie) : []
  end

  def teacher_required
    redirect_to(:root, alert: 'Not allowed') unless teacher?
  end

end
