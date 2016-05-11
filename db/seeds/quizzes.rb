# Load quizzes from db/seeds/quizzes/*.yml files
# Issue: Deletes all QuizActivities but does not generate any :(
# QuizActivities to be generated in prep_seeds.rb

if Rails.env.development?
  puts "Purging quiz data (development only)"

  QuizActivity.destroy_all
  QuizSubmission.destroy_all
end

# for tracking and preventing accidental dupe uuids in the data
#   ie copy/paste mistakes
@question_uuids = []
@quiz_uuids = []

def generate_questions(question_data)
  questions = []
  question_data.each do |question_attributes|
    uuid = question_attributes['uuid']
    abort("\n\n---\nHALT! Question UUID required") if uuid.blank?
    abort("\n\n---\nHALT! Dupe Question UUID found. Check your data, as this is potentially disasterous!") if @question_uuids.include?(uuid)

    attrs = question_attributes.merge({active: true})
    if attrs['outcome']
      attrs['outcome'] = Outcome.find_by_uuid(attrs['outcome'])
    end

    if question = Question.find_by(uuid: uuid)
      if question.answers.any?
        puts "Skipping Question #{question.id} as it has answers"
      else
        question.options.destroy_all
        question.update! attrs
        comma
      end
    else
      question = Question.create!(attrs)
      dot
    end

    @question_uuids << uuid
    questions << question
  end
  questions # created or found questions are returned
end

puts "Loading quiz data"

dir = Rails.root.join('db/seeds/quizzes').to_s + '/**/*.yml'

Dir.glob(dir).each do |file|
  quiz_data = YAML.load_file(file)

  print "Quiz #{file}: "; STDOUT.flush

  question_data = quiz_data.delete 'questions'

  uuid = quiz_data['uuid']
  abort("\n\n---\nHALT! Quiz UUID required") if uuid.blank?
  abort("\n\n---\nHALT! Dupe Quiz UUID found. Check your data, as this is potentially disasterous!") if @quiz_uuids.include?(uuid)

  if quiz = Quiz.find_by(uuid: quiz_data['uuid'])
    quiz.update! quiz_data
    comma # updated
  else
    quiz = Quiz.create! quiz_data
    dot # created
  end

  @quiz_uuids << uuid

  print "\n - Questions: "; STDOUT.flush
  questions = generate_questions(question_data)
  # delta updates/creates to the habtm/join table
  quiz.questions = questions
  puts "\n--"
end

puts "DONE"

