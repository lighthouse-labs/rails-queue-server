class RequestQueueSerializer < ActiveModel::Serializer

  root false

  def attributes
    attrs = super
    attrs.tap do
      attrs[:active_assistances] = active_assistances
      attrs[:requests] = requests
      attrs[:code_reviews] = code_reviews
      attrs[:active_evaluations] = active_evaluations
      attrs[:evaluations] = evaluations
      attrs[:active_tech_interviews] = active_tech_interviews
      attrs[:tech_interviews] = tech_interviews
      attrs[:all_students] = students
    end
  end

  protected

  def active_assistances
    object[:assistances].collect do |assistance|
      AssistanceSerializer.new(assistance).as_json
    end
  end

  def requests
    object[:requests].collect do |request|
      AssistanceRequestSerializer.new(request).as_json
    end
  end

  def code_reviews
    object[:code_reviews].collect do |code_review|
      CodeReviewSerializer.new(code_review).as_json
    end
  end

  def active_evaluations
    object[:active_evaluations].collect do |evaluation|
      EvaluationSerializer.new(evaluation).as_json
    end
  end

  def evaluations
    object[:evaluations].collect do |evaluation|
      EvaluationSerializer.new(evaluation).as_json
    end
  end

  def active_tech_interviews
    object[:active_tech_interviews].collect do |interview|
      TechInterviewSerializer.new(interview).as_json
    end
  end

  def tech_interviews
    object[:tech_interviews].collect do |interview|
      TechInterviewSerializer.new(interview).as_json
    end
  end

  def students
    object[:students].collect do |student|
      UserSerializer.new(student).as_json
    end
  end

end
