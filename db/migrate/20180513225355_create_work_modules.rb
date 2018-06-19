class CreateWorkModules < ActiveRecord::Migration[5.0]
  def change
    create_table :work_modules do |t|
      t.string :uuid, null: false
      t.string :name, null: false
      t.string :slug
      t.references :workbook, foreign_key: true
      t.integer :order
      t.boolean :archived
      t.string  :content_file_path
      t.timestamps
    end
    add_index :work_modules, :uuid, unique: true
    add_index :work_modules, :slug, unique: true
  end
end
