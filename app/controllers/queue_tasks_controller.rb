class QueueTasksController < ApplicationController

  before_action :teacher_required, except: :day_activities

  def show
    queue_tasks = current_user.admin? ? QueueTask.open_or_in_progress_tasks : QueueTask.teachers_queue_or_in_progress(current_user)
    queue_tasks += Evaluation.incomplete.student_priority
    queue_tasks += TechInterview.in_progress
    render json: queue_tasks, each_serializer: QueueTaskSerializer, root: 'tasks'
  end

  def students
    # Can filter for what students the teacher has access to in the future
    cohorts = Program.first.cohorts.is_active
    students = Student.joins(:cohort).merge(cohorts).distinct.to_a
    render json: students, each_serializer: QueueStudentSerializer, root: 'students'
  end

  def cohorts
    # Can filter for what students the teacher has access to in the future
    cohorts = Program.first.cohorts.is_active
    render json: cohorts, each_serializer: QueueCohortStatusSerializer, root: 'cohorts'
  end

  def teachers
    teachers = Teacher.on_duty
    render json: teachers, each_serializer: UserSerializer, root: 'teachers'
  end

  def day_activities
    render json: current_user.visible_bootcamp_activities.assistance_worthy.pluck(:name, :day, :id).group_by { |d| d[1] }
  end

  private

  def teacher_required
    unless teacher?
      respond_to do |format|
        format.html { redirect_to(:root, alert: 'Not allowed.') }
        format.json { render json: { error: 'Not Allowed.' } }
      end
    end
  end

end
