# Load quizzes from db/seeds/quizzes/*.yml files
# Issue: Deletes all QuizActivities but does not generate any :(
# QuizActivities to be generated in prep_seeds.rb

if Rails.env.development?
  puts "Purging quiz data (development only) ..."
  
  QuizActivity.destroy_all
  QuizSubmission.destroy_all
  Option.delete_all
  Question.delete_all
  Quiz.delete_all
end

puts "Loading quiz data ..."

dir = Rails.root.join('db/seeds/quizzes').to_s + '/*.yml'

Dir.glob(dir).each do |file|
  print "Parsing file #{file} ... "; STDOUT.flush
  questions = []
  quiz_data = YAML.load_file(file)
  quiz = Quiz.create! name: quiz_data['name']
  quiz_data['questions'].each do |question_attributes|
    quiz.questions << Question.create!(question_attributes.merge({active: true}))
  end
end

puts "DONE"

