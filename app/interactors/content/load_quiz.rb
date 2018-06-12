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
    abort("\n\n---\nHALT! Quizes need questions investigate activity with this uuid #{d['uuid']}") if d['questions'].nil?

    quiz = Quiz.find_or_initialize_by(uuid: uuid)
    quiz.assign_attributes(name: d['name'],
                           day:  d['day'])
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
        active:             true,
        uuid:               uuid,
        question:           d['question'],
        options_attributes: d['options_attributes']
      }
      attrs[:outcome] = Outcome.find_by(uuid: d['outcome']) if d['outcome']

      if question = Question.find_by(uuid: uuid)
        update_options(question, attrs)
        attrs.delete :options_attributes
        question.assign_attributes attrs
      else
        question = Question.new(attrs)
      end

      questions << question
      @records.push question
    end
    questions # created or found questions are returned
  end

  private

  def update_options(question, data)
    if question.options.size > data[:options_attributes].size
      @log.warn "Skipping Question #{question.id} as it has fewer options and I don't know how to handle that :("
      return
    end

    # mark the question as dirty (this is a hack) so our log is at least
    # showing that the Q was updated, even though it wont show the details correctly
    #  - KV

    question.options.each_with_index do |option, i|
      option.assign_attributes data[:options_attributes][i]
    end

    # grab the last x (new_count) items from the array in the data
    #  since we need to create those new question options
    new_count = data[:options_attributes].size - question.options.size
    if new_count > 0
      data[:options_attributes][-new_count..-1].each do |new_option_data|
        question.options.new new_option_data
      end
    end
  end

end
