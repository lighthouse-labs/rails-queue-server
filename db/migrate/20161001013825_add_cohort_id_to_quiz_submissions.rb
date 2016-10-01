class AddCohortIdToQuizSubmissions < ActiveRecord::Migration[5.0]
  def up
    add_column :quiz_submissions, :cohort_id, :integer
    add_index :quiz_submissions, :cohort_id
    
    puts 'Updating quiz submissions with cohort_id'
    QuizSubmission.find_each(batch_size: 100) do |submission|
      if submission.quiz.try(:bootcamp?) && submission.user.try(:cohort_id?)
        submission.update_columns(cohort_id: submission.user.cohort_id)
        print '.'; STDOUT.flush
      end
    end
    puts 'Done'

  end
  def down
    remove_column :quiz_submissions, :cohort_id
  end
end
