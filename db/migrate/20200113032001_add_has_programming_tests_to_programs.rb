class AddHasProgrammingTestsToPrograms < ActiveRecord::Migration[5.0]
  def change
    add_column :programs, :has_programming_tests, :boolean
  end
end
