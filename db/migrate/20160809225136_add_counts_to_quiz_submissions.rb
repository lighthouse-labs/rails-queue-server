class AddCountsToQuizSubmissions < ActiveRecord::Migration
  def change
    add_column :quiz_submissions, :total, :integer
    add_column :quiz_submissions, :correct, :integer
    add_column :quiz_submissions, :incorrect, :integer
    add_column :quiz_submissions, :skipped, :integer
  end
end
