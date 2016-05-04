class AddTimeSpentToActivitySubmissions < ActiveRecord::Migration
  def change
    add_column :activity_submissions, :time_spent, :integer
  end
end
