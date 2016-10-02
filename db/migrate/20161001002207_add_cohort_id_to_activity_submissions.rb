class AddCohortIdToActivitySubmissions < ActiveRecord::Migration[5.0]
  def up
    add_column :activity_submissions, :cohort_id, :integer
    add_index :activity_submissions, :cohort_id

    puts 'Updating submissions with cohort_id'
    ActivitySubmission.find_each(batch_size: 100) do |submission|
      if submission.user.try :cohort_id?
        if submission.activity && submission.activity.day?
          submission.update_columns(cohort_id: submission.user.cohort_id)
          print '.'; STDOUT.flush
        end
      end
    end
    puts 'Done'
  end

  def down
    remove_column :activity_submissions, :cohort_id
  end
end
