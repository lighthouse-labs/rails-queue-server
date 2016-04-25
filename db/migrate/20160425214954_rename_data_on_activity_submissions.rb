class RenameDataOnActivitySubmissions < ActiveRecord::Migration
  def change
    rename_column :activity_submissions, :data, :code_evaluation_results
  end
end
