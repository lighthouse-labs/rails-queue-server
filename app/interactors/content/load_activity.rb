class Content::LoadActivity

  include Interactor

  before do
    @log      = context.log
    @repo     = context.repo
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
    # sequence is a required field and in some cases may not be present (if activity is created and archived in the same step, it will never be given a sequence. default to 99 in that case) - KV
    activity.sequence ||= 99

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
      remote_content:            true,
      content_repository:        @repo,
      content_file_path:         d['file_path'],
      section:                   section(d['section']),
      type:                      type(d['type']),
      name:                      d['name'],
      duration:                  d['duration'],
      stretch:                   d['stretch'],
      homework:                  d['homework'],
      cs:                        d['cs'],
      archived:                  d['archived'],
      start_time:                d['start_time'],
      day:                       d['day'],
      evaluates_code:            d['evaluates_code'],
      allow_submissions:         d['allow_submissions'],
      media_filename:            d['media_filename'],
      outcomes:                  outcomes(d['outcomes']),
      test_code:                 d['test_code'],
      initial_code:              d['initial_code'],
      milestone:                 d['milestone'],
      advanced_topic:            d['advanced_topic'],
      background_image_url:      d['bg_image_url'],
      background_image_darkness: d['bg_image_darkness']
    }
    # if sequence is not specified, do not change the existing one
    attrs[:sequence] = d['sequence'] if d['sequence']
    attrs.merge!(split_instructions_and_teacher_notes(d))
    attrs
  end

  # We expect activities (esp lecture activities) to have Teacher Notes
  #  as a heading. We split the instructions from the teacher notes based on that
  def split_instructions_and_teacher_notes(d)
    content = d['markdown']

    separated = content.split(/^#+\s*Teacher Notes\s*$/)

    # return hash with both attributes (latter may be nil)
    {
      instructions:  separated[0],
      teacher_notes: separated[1] ? separated[1].lstrip : nil
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

  def section(uuid)
    uuid &&
      (scan_for_record_by_uuid(uuid) || Section.find_by(uuid: uuid))
  end

  def scan_for_record_by_uuid(uuid)
    @records.detect { |r| r.uuid == uuid }
  end

  def type(t)
    t = case t.strip.downcase
        when 'quiz'
          'QuizActivity'
        when 'exercise'
          'Assignment'
        when 'walkthrough'
          'Walkthrough'
        when 'problem'
          'Problem'
        when 'challenge'
          'Challenge'
        # FIXME: below categories should be changed/removed - KV
        when 'project'
          # FIXME: projects should be moved into their own curriculum dir, perhaps
          'Reading'
        when 'note', 'week outline', 'outline', 'folder description', 'module outline', 'day outline', 'weekend outline'
          'PinnedNote'
        # FIXME: below categories should be changed/removed - KV
        when 'reading and questions'
          'Reading'
        # FIXME: below categories should be changed/removed - KV
        when 'stretch', 'stretch reading'
          'Reading'
        when 'practice'
          'Task'
        when 'lecture'
          'LecturePlan'
        when 'breakout'
          'LecturePlan'
        else
          # make sure this is a valid Activity type, and if so, roll with it
          t.strip.gsub(/\s+/, '_').classify
        end

    # Note: assumes all models are eager loaded
    # this is done in deploy.rb (main interactor) via:
    #     Rails.application.eager_load!
    # - KV
    t if Object.const_defined?(t) && t.constantize.superclass == Activity
  end

  def load_quiz
    Content::LoadQuiz.call(repo: @repo, log: @log, data: @data, records: @records).quiz
  end

end
