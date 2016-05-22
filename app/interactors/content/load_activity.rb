class Content::LoadActivity
  include Interactor

  before do
    @log      = context.log
    @records  = context.records
    @data     = context.data
  end

  def call
    d = @data
    uuid = d['uuid']

    # QUIZ
    quiz = load_quiz if quiz?

    # ACTIVITY
    activity = Activity.find_or_initialize_by(uuid: uuid)
    activity.assign_attributes(build_attributes(d))
    if quiz?
      activity = activity.becomes(QuizActivity)
      activity.quiz = quiz if quiz
    end

    @records.push activity
    activity
  end

  private

  def quiz?
    @data['type'] == 'Quiz'
  end

  # There's intentionally no AR mass assignment
  #   it would be problematic from a maintenance workflow standpoint - KV
  def build_attributes(d)
    attrs = {
      remote_content: true,
      section:        section(d['section']),
      type:           type(d['type']),
      name:           d['name'],
      instructions:   d['instructions'],
      duration:       d['duration'] || 20, # FIXME: should not default
      start_time:     d['start_time'] || 900,
      day:            d['day'],
      evaluates_code: d['evaluates_code'],
      media_filename: d['media_filename'],
      outcomes:       outcomes(d['outcomes'])
    }
  end

  # Turn array of outcome uuids into array of outcomes
  #   they are expected to be in the db already - KV
  def outcomes(o)
    return [] unless o
    o.map do |uuid|
      Outcome.find_by(uuid: uuid)
    end.compact
  end

  def section(s)
    Section.find_by(uuid: s) if s
  end

  def type(t)
    case t.strip.downcase
    when 'quiz'
      'QuizActivity'
    when 'exercise'
      'Assignment'
    when 'problem'
      'Assignment'
    when 'week outline'
      'Reading'
    when 'outline'
      'Reading'
    # FIXME: below categories should be changed/removed - KV
    when 'project'
      # FIXMe: projects should be moved into their own curriculum dir, perhaps
      'Reading'
    when 'folder description'
      'Reading'
    when 'module outline'
      'Reading'
    when 'day outline'
      'Reading'
    when 'weekend outline'
      'Reading'
    # FIXME: below categories should be changed/removed - KV
    when 'reading and questions'
      'Reading'
    # FIXME: below categories should be changed/removed - KV
    when 'stretch', 'stretch reading'
      'Reading'
    when 'practice'
      'Task'
    else
      t.strip
    end
  end

  def load_quiz
    Content::LoadQuiz.call(log: @log, data: @data, records: @records).quiz
  end

end