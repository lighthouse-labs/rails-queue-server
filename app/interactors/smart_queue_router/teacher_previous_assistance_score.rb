class SmartQueueRouter::TeacherPreviousAssistanceScore

  include Interactor

  before do
    @teachers = context.teachers
    @requestor = context.assistance_request.requestor
    @successfull_assistance_weight = context.successfull_assistance_weight
    @negative_assistance_weight = context.negative_assistance_weight
  end

  def call
    puts 'negative assistance score++++++++++++++++++++++++++++++'

    @teachers.each do |_uid, teacher|
      assistances =  Assistance.completed.assisted_by(teacher[:object]).requested_by(@requestor['uid'])
      break if assistances.empty?
      successfull_assistances = assistances.with_feedback_greater_than(2).count || 0
      negative_assistances = assistances.with_feedback_less_than(2).count || 0

      success_score = normalize(successfull_assistances) * @successfull_assistance_weight
      negative_score = -1 * normalize(negative_assistances) * @negative_assistance_weight
      teacher[:routing_score].total += success_score + negative_score
      teacher[:routing_score].summary['TeacherPreviousAssistanceScore_successfull'] = success_score
      teacher[:routing_score].summary['TeacherPreviousAssistanceScore_negative'] = negative_score
    end
  end

  private

  def normalize(quantity)
    half_point = 5 # 5 assistances will normalize to 0.5
    return -1 / (quantity/half_point + 1) + 1
  end

end
