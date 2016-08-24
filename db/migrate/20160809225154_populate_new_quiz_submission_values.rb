class PopulateNewQuizSubmissionValues < ActiveRecord::Migration
  def up
    QuizSubmission.find_each(batch_size: 100) do |qs|
      quiz  = qs.quiz

      total     = quiz.questions.active.count
      correct   = qs.answers.correct.count
      skipped   = total - qs.answers.count
      incorrect = total - skipped - correct

      stats = {
        total:     total,
        correct:   correct,
        incorrect: incorrect,
        skipped:   skipped
      }

      # intentionally avoid save lifecylce (timestamp updating, validations, callbacks, etc)
      QuizSubmission.where(id: qs.id).update_all(stats)

    end
  end
  def down
    # nothing to do
  end
end
