class AddNameAndDayToProgrammingTests < ActiveRecord::Migration[5.0]
  def change
    change_table :programming_tests do |t|
      t.string :name
      t.string :day
    end
  end
end
