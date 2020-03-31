class AddSettingsToPrograms < ActiveRecord::Migration[5.0]
  def change
    add_column :programs, :settings, :jsonb
  end
end