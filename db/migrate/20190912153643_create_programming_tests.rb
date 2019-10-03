class CreateProgrammingTests < ActiveRecord::Migration[5.0]
  def change
    create_table :programming_tests do |t|
      t.string :exam_code, null: false
      t.string :uuid, null: false
      t.json :config

      t.timestamps
    end
  end
end
