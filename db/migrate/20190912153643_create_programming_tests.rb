class CreateProgrammingTests < ActiveRecord::Migration[5.0]
  def change
    create_table :programming_tests do |t|
      t.string :exam_code
      t.string :uuid
      t.json :config

      t.timestamps
    end
  end
end
