class SmartQueueRouter::TeacherTagScore

  include Interactor

  before do
    @teachers = context.teachers
    @requestor = context.assistance_request.requestor
    @assistance_request = context.assistance_request
  end

  def call
    tags = @requestor['tags']
    tags ||= []
    tags.each do |tag|
      tag = Tag.using(@assistance_request.compass_instance.name).find_by(id: tag['id'])
      next unless tag
      @teachers.each do |_id, teacher|
        if teacher[:object].tagged_with?(tag)
          # bonus
          score = (1 * tag.match_bonus_multiplier) if tag.match_bonus_multiplier?
        else
          # penalty
          score = (-1 * tag.mismatch_penalty_multiplier) if tag.mismatch_penalty_multiplier?
        end
        teacher[:routing_score].total += score if score
        teacher[:routing_score].summary["TeacherTagScore_#{tag.name}"] = score
      end
    end
  end

end
