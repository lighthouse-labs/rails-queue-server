class QueueCohortStatusSerializer < ActiveModel::Serializer

  format_keys :lower_camel

  attributes :id, :name, :week, :active_student_count

  has_many :interview_statuses, serializer: QueueTechInterviewProgressSerializer

  def interview_statuses
    templates = TechInterviewTemplate.where("tech_interview_templates.week <= ?", object.week)
    templates.each do |template|
      template.instance_variable_set(:@cohort, object)
      template.define_singleton_method :cohort do
        @cohort
      end
    end
    templates
  end


  def active_student_count
    students.count
  end

  private

  def students
    Student.active.where(cohort_id: object, location_id: object.current_location)
  end

end

