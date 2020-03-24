class AddHasZoomConferencesToPrograms < ActiveRecord::Migration[5.0]
  def change
    add_column :programs, :has_zoom_conferences, :boolean
  end
end
