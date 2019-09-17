class RevertTransitionChanges < ActiveRecord::Migration[5.0]
  def change
    rename_column :tech_interview_templates, :schedule2_week, :week if ActiveRecord::Base.connection.column_exists?(:tech_interview_templates, :schedule2_week)
    rename_column :sections, :schedule2_start, :start_day if ActiveRecord::Base.connection.column_exists?(:sections, :schedule2_start)
    rename_column :sections, :schedule2_end, :end_day if ActiveRecord::Base.connection.column_exists?(:sections, :schedule2_end)
    rename_column :quizzes, :schedule2, :day if ActiveRecord::Base.connection.column_exists?(:quizzes, :schedule2)
    rename_column :activities, :schedule2_body, :instructions if ActiveRecord::Base.connection.column_exists?(:activities, :schedule2_body)
    rename_column :activities, :schedule2_stretch, :stretch if ActiveRecord::Base.connection.column_exists?(:activities, :schedule2_stretch)
    rename_column :activities, :schedule2_sequence, :sequence if ActiveRecord::Base.connection.column_exists?(:activities, :schedule2_sequence)
    rename_column :activities, :schedule2, :day if ActiveRecord::Base.connection.column_exists?(:activities, :schedule2)
  end
end
