class TransitionBackRemoveUneededColumns < ActiveRecord::Migration[5.0]
  def up
    remove_column :activities, :schedule1_stretch if ActiveRecord::Base.connection.column_exists?(:activities, :schedule1_stretch)
    remove_column :activities, :schedule3_stretch if ActiveRecord::Base.connection.column_exists?(:activities, :schedule3_stretch)
    remove_column :activities, :schedule1_body if ActiveRecord::Base.connection.column_exists?(:activities, :schedule1_body)
    remove_column :activities, :schedule3_body if ActiveRecord::Base.connection.column_exists?(:activities, :schedule3_body)
    remove_column :quizzes, :schedule1 if ActiveRecord::Base.connection.column_exists?(:quizzes, :schedule1)
    remove_column :quizzes, :schedule3 if ActiveRecord::Base.connection.column_exists?(:quizzes, :schedule3)
    remove_column :sections, :schedule1_start if ActiveRecord::Base.connection.column_exists?(:sections, :schedule1_start)
    remove_column :sections, :schedule1_end if ActiveRecord::Base.connection.column_exists?(:sections, :schedule1_end)
    remove_column :sections, :schedule3_start if ActiveRecord::Base.connection.column_exists?(:sections, :schedule3_start)
    remove_column :sections, :schedule3_end if ActiveRecord::Base.connection.column_exists?(:sections, :schedule3_end)
    remove_column :tech_interview_templates, :schedule1_week if ActiveRecord::Base.connection.column_exists?(:tech_interview_templates, :schedule1_week)
    remove_column :tech_interview_templates, :schedule3_week if ActiveRecord::Base.connection.column_exists?(:tech_interview_templates, :schedule3_week)
    remove_column :cohorts, :schedule if ActiveRecord::Base.connection.column_exists?(:cohorts, :schedule)
    remove_column :activities, :schedule1 if ActiveRecord::Base.connection.column_exists?(:activities, :schedule1)
    remove_column :activities, :schedule3 if ActiveRecord::Base.connection.column_exists?(:activities, :schedule3)
    remove_column :activities, :schedule1_sequence if ActiveRecord::Base.connection.column_exists?(:activities, :schedule1_sequence)
    remove_column :activities, :schedule3_sequence if ActiveRecord::Base.connection.column_exists?(:activities, :schedule3_sequence)
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "This migration cannot be reversed."
  end
end
