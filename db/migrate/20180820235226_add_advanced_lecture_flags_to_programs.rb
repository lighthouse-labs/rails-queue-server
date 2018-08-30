class AddAdvancedLectureFlagsToPrograms < ActiveRecord::Migration[5.0]
  def up
    add_column :programs, :has_advanced_lectures, :boolean
    add_column :activities, :advanced_topic, :boolean

    Program.all.each do |program|
      if program.weeks == 10
        if program.update(has_advanced_lectures: true)
          say "Updated program #{program.id} to have advanced lectures"
        else
          say "Failed to update program #{program.id}"
        end
      end
    end
  end

  def down
    remove_column :programs, :has_advanced_lectures
    remove_column :activities, :advanced_topic
  end
end
