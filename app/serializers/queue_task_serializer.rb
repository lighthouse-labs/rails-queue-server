class QueueTaskSerializer < ActiveModel::Serializer

  root false
  format_keys :lower_camel

  attributes  :id,
              :teacher,
              :state,
              :started_at,
              :type,
              :task_object

  protected

  def teacher
    # add more so serializer can be used on evaluations and tech interviews
    if object.is_a? QueueTask
      teacher = object.user
    elsif object.is_a? TechInterview
      teacher = object.interviewer
    elsif object.is_a? Evaluation
      teacher = object.teacher
    end
    UserSerializer.new(teacher).as_json
  end

  def task_object
    if object.is_a? QueueTask
      NationalQueueAssistanceRequestSerializer.new(object.assistance_request).as_json
    elsif object.is_a? TechInterview
      TechInterviewSerializer.new(object).as_json
    elsif object.is_a? Evaluation
      EvaluationSerializer.new(object).as_json
    end
  end

  def state
    object.state
  end

  def started_at
    if object.is_a? QueueTask
      object.assistance_request&.start_at
    else 
      object.started_at
    end
  end

  def type
    if object.is_a? QueueTask
      "Assistance"
    elsif object.is_a? TechInterview
      'TechInterview'
    elsif object.is_a? Evaluation
      'ProjectEvaluation'
    end
  end

end
