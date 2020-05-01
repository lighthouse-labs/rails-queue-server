class QueueTechInterviewProgressSerializer < ActiveModel::Serializer

  format_keys :lower_camel

  attributes :id, :week

  has_many :incomplete_student_ids
  has_many :completed_student_ids

  def incomplete_student_ids
    interviews = tech_interviews.select(:interviewee_id)
    students.where.not(id: interviews).map &:id
  end

  def completed_student_ids
    student_ids = students.select(:id)
    interviews = tech_interviews.where(interviewee_id: student_ids).map(&:interviewee_id).uniq
  end

  private

  def students
    if defined? object.cohort.current_location
      Student.active.where(cohort_id: object.cohort, location_id: object.cohort.current_location)
    else
      Student.active.where(cohort_id: object.cohort)
    end
  end

  def tech_interviews
    object.tech_interviews.where(cohort_id: object.cohort).completed
  end

end
