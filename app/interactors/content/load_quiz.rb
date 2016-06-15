class Content::LoadQuiz
  include Interactor

  before do
    @log     = context.log
    @repo    = context.repo
    @data    = context.data
    @records = context.records
  end

  def call
    d = @data
    uuid = d['uuid']
    abort("\n\n---\nHALT! Quiz UUID required") if uuid.blank?

    quiz = Quiz.find_or_initialize_by(uuid: uuid)
    quiz.assign_attributes({
      name: d['name'],
      day: d['day']
    })
    questions = build_questions(d['questions'])
    quiz.questions = questions

    @records.push quiz
    context.quiz = quiz
  end

  def build_questions(question_data)
    questions = []
    question_data.each do |d|
      uuid = d['uuid']
      abort("\n\n---\nHALT! Question UUID required") if uuid.blank?
      # abort("\n\n---\nHALT! Dupe Question UUID found. Check your data, as this is potentially disasterous!") if @question_uuids.include?(uuid)

      attrs = {
        active: true,
        uuid: uuid,
        question: d['question'],
        options_attributes: d['options_attributes']
      }
      attrs[:outcome] = Outcome.find_by(uuid: d['outcome']) if d['outcome']

      if question = Question.find_by(uuid: uuid)
        if question.answers.any?
          # TODO: need to handle this better before going live
          #  Should be able to update questions that already have answers (the reality of once this is live)
          #  - KV
          @log.warn "Skipping Question #{question.id} as it has answers"
        else
          question.options.each { |o| o.mark_for_destruction }
          question.assign_attributes attrs
        end
      else
        question = Question.new(attrs)
      end

      questions << question
      @records.push question
    end
    questions # created or found questions are returned
  end

end