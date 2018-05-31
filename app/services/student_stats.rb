class StudentStats

  def initialize(student, cohort = nil)
    @student = student
    @cohort  = cohort || student.cohort
  end

  ## PREP STATS

  def prep_started?
    !!prep_started_at
  end

  def prep_started_at
    @prep_started_at ||= @student.activity_submissions.prep.order(id: :asc).first.try(:created_at)
  end

  # in minutes
  def prep_time_spent
    @student.activity_submissions.prep.sum(:time_spent)
  end

  def days_idle_before_prep
    if prep_started?
      (prep_started_at.to_date - @student.created_at.to_date).to_i
    end
  end

  def days_registered_before_start
    (@cohort.start_date - @student.created_at.to_date).to_i
  end

  def days_prepping_before_start
    (@cohort.start_date - prep_started_at.to_date).to_i if prep_started?
  end

  def prep_total_stats
    return @prep_total_stats if @prep_total_stats

    activity_stats = prep_activity_stats
    quiz_stats     = prep_quiz_stats

    completed  = activity_stats[:core][:completed] + quiz_stats[:completed]
    total      = activity_stats[:core][:total]     + quiz_stats[:total]
    ratio      = total > 0 ? (completed.to_f / total.to_f) * 100 : 0

    @prep_total_stats = {
      completed: completed,
      total:     total,
      ratio:     ratio
    }
  end

  def prep_activity_stats
    return @prep_activity_stats if @prep_activity_stats

    activities  = Activity.active.prep.countable_as_submission
    completions = @student.activity_submissions.proper.prep

    total_core     = activities.core.count
    completed_core = completions.core.count

    total_stretch     = activities.stretch.count
    completed_stretch = completions.stretch.count

    @prep_activity_stats = {
      core:    {
        completed: completed_core,
        total:     total_core,
        ratio:     total_core > 0 ? (completed_core.to_f / total_core.to_f) * 100 : 0
      },
      stretch: {
        completed: completed_stretch,
        total:     total_stretch,
        ratio:     total_stretch > 0 ? (completed_stretch.to_f / total_stretch.to_f) * 100 : 0
      }
    }
  end

  def prep_quiz_stats
    return @prep_quiz_stats if @prep_quiz_stats
    @prep_quiz_stats = quiz_stats(Quiz.active.prep, nil)
  end

  ## BOOTCAMP STATS

  def bootcamp_assistance_stats
    cohort_id = @cohort.id

    @bootcamp_assistance_stats = {
      requests:           @student.assistance_requests.genuine.where(cohort_id: cohort_id).count,
      assistances:        @student.assistances.completed.where(cohort_id: cohort_id).count,
      assistances_length: @student.assistances.completed.average_length.to_i,
      average_score:      @student.assistances.completed.where(cohort_id: cohort_id).where.not(rating: nil).average(:rating).to_f.round(2)
    }
  end

  # don't memo-ize since using it multiple times for diff data (nullable arg) - KV
  def bootcamp_activity_stats(options = {})
    cutoff_day   = options.delete :cutoff_day
    for_day      = options.delete :for_day
    for_week     = options.delete :for_week

    activities  = Activity.active.bootcamp.countable_as_submission
    completions = @student.activity_submissions.proper.bootcamp.where(cohort_id: @cohort.id)

    if cutoff_day
      activities  = activities.until_day(cutoff_day)
      completions = completions.until_day(cutoff_day)
    elsif for_day
      activities  = activities.for_day(for_day)
      completions = completions.for_day(for_day)
    elsif for_week
      activities  = activities.for_week(for_week)
      completions = completions.for_week(for_week)
    end

    total_core     = activities.core.count
    completed_core = completions.core.count

    total_stretch     = activities.stretch.count
    completed_stretch = completions.stretch.count

    {
      core:    {
        completed: completed_core,
        total:     total_core,
        ratio:     total_core > 0 ? (completed_core.to_f / total_core.to_f) * 100 : 0
      },
      stretch: {
        completed: completed_stretch,
        total:     total_stretch,
        ratio:     total_stretch > 0 ? (completed_stretch.to_f / total_stretch.to_f) * 100 : 0
      }
    }
  end

  # not memoizing it since using it multiple times for diff data (nullable arg) - KV
  def bootcamp_quiz_stats(options = {})
    cutoff_day = options.delete :cutoff_day

    quizzes = Quiz.active
    quizzes = if cutoff_day
                quizzes.until_day(cutoff_day) # specific ones
              else
                quizzes.bootcamp # all
              end
    quiz_stats(quizzes, @cohort.id)
  end

  private

  def quiz_stats(quizzes, cohort_id = nil)
    quiz_ids = quizzes.select(:id)
    all_submissions = @student.quiz_submissions.where(quiz_id: quiz_ids)
    all_submissions = all_submissions.where(cohort_id: cohort_id) if cohort_id
    quiz_submissions = all_submissions.where(initial: true)
    quiz_ratio = quiz_submissions.any? ? (quiz_submissions.count.to_f / quiz_ids.count) * 100 : 0
    quiz_average = average_score_for_submissions(quiz_submissions)

    {
      completed: quiz_submissions.count,
      total:     quiz_ids.count,
      average:   quiz_average,
      ratio:     quiz_ratio,
      attempts:  all_submissions.count
    }
  end

  def average_score_for_submissions(submissions)
    if submissions.any?
      # (submissions.average('correct::float / total::float').to_f * 100).round(2)
      ((submissions.sum('correct').to_f / submissions.sum('total').to_f) * 100).round(2)
    end
  end

end
