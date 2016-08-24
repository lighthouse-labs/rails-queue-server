class StudentStats

  def initialize(student)
    @student = student
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
    (@student.cohort.start_date - @student.created_at.to_date).to_i
  end

  def days_prepping_before_start
    if prep_started?
      (@student.cohort.start_date - prep_started_at.to_date).to_i
    end
  end

  def prep_total_stats
    return @prep_total_stats if @prep_total_stats

    activity_stats = prep_activity_stats
    quiz_stats     = prep_quiz_stats

    completed  = activity_stats[:completed] + quiz_stats[:completed]
    total      = activity_stats[:total]     + quiz_stats[:total]
    ratio      = total > 0 ? (completed.to_f / total.to_f) * 100 : 0

    @prep_total_stats = {
      completed: completed,
      total:     total,
      ratio:     ratio
    }
  end

  def prep_activity_stats
    return @prep_activity_stats if @prep_activity_stats

    total     = Activity.active.prep.countable_as_submission.count
    completed = @student.activity_submissions.proper.prep.count

    @prep_activity_stats = {
      completed: completed,
      total:     total,
      ratio:     total > 0 ? (completed.to_f / total.to_f) * 100 : 0
    }
  end

  def prep_quiz_stats
    return @prep_quiz_stats if @prep_quiz_stats
    @prep_quiz_stats = quiz_stats(Quiz.active.prep)
  end

  ## BOOTCAMP STATS

  def bootcamp_assistance_stats
    @bootcamp_assistance_stats = {
      requests:      @student.assistance_requests.count,
      assistances:   @student.assistances.completed.count,
      average_score: @student.assistances.completed.where.not(rating: nil).average(:rating).to_f
    }
  end

  # don't memo-ize since using it multiple times for diff data (nullable arg) - KV
  def bootcamp_activity_stats(cutoff=nil)

    activities  = Activity.active.bootcamp.countable_as_submission
    completions = @student.activity_submissions.proper.bootcamp

    if cutoff
      activities  = activities.until_day(cutoff)
      completions = completions.until_day(cutoff)
    end

    total_core     = activities.core.count
    completed_core = completions.core.count

    total_stretch     = activities.stretch.count
    completed_stretch = completions.stretch.count

    {
      core: {
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
  def bootcamp_quiz_stats(cutoff=nil)
    quizzes = Quiz.active
    if cutoff
      quizzes = quizzes.until_day(cutoff) # specific ones
    else
      quizzes = quizzes.bootcamp # all
    end
    quiz_stats(quizzes)
  end

  private

  def quiz_stats(quizzes)
    quiz_ids = quizzes.select(:id)
    all_submissions = @student.quiz_submissions.where(quiz_id: quiz_ids)
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
    else
      nil
    end
  end

end
