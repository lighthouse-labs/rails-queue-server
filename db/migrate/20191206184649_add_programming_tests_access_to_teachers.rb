class AddProgrammingTestsAccessToTeachers < ActiveRecord::Migration[5.0]
  def change
    change_table :users do |t|
      t.boolean :can_view_programming_tests, default: false, null: false
    end
  end
end
