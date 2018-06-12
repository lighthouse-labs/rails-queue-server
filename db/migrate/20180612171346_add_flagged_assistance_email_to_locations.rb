class AddFlaggedAssistanceEmailToLocations < ActiveRecord::Migration[5.0]
  def change
    add_column :locations, :flagged_assistance_email, :string
  end
end
