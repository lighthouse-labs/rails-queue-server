class AddNoteToActivitySubmissions < ActiveRecord::Migration
  def change
    add_column :activity_submissions, :note, :text
  end
end
