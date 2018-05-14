class CreateWorkbooks < ActiveRecord::Migration[5.0]
  def change
    create_table :workbooks do |t|
      t.string :uuid, null: false
      t.string :name, null: false
      t.string :slug
      t.string :content_file_path
      t.references :content_repository, foreign_key: true
      t.boolean :archived

      t.timestamps
    end
    add_index :workbooks, :slug, unique: true
    add_index :workbooks, :uuid, unique: true

  end
end
