class MoveActivityTestIntoActivitiesTable < ActiveRecord::Migration
  def up
    add_column :activities, :initial_code, :text
    add_column :activities, :test_code, :text

    ActivityTest.all.each do |at|
      if a = at.activity
        a.update(initial_code: at.initial_code, test_code: at.test)
      end
    end
  end

  def down
    remove_column :activities, :initial_code
    remove_column :activities, :test_code
  end
end
