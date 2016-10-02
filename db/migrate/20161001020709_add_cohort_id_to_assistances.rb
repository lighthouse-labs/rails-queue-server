class AddCohortIdToAssistances < ActiveRecord::Migration[5.0]
  def up
    add_column :assistances, :cohort_id, :integer
    add_index :assistances, :cohort_id

    puts 'Updating assistances with cohort_id'
    Assistance.find_each(batch_size: 100) do |assistance|
      if assistance.assistee.try :cohort_id?
        assistance.update_columns(cohort_id: assistance.assistee.cohort_id)
        print '.'; STDOUT.flush
      end
    end
    puts 'Done'
  end
  def down
    remove_column :assistances, :cohort_id
  end
end
