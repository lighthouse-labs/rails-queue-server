class AddWeekdaysToCohort < ActiveRecord::Migration
  def up
    add_column :cohorts, :weekdays, :string
    add_column :programs, :days_per_week, :integer

    Cohort.update_all(weekdays: ENV['WEEKDAYS'] || 5)
    Program.update_all(days_per_week: ENV['DAYS_PER_WEEK'])
  end

  def down
    remove_column :cohorts, :weekdays
    remove_column :programs, :days_per_week
  end
end
