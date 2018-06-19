class AddFlaggedAssistanceEmailToLocations < ActiveRecord::Migration[5.0]
  def change
    add_column :locations, :flagged_assistance_email, :string

    Location.where(name: %w{Vancouver Calgary Victoria Kelowna}).update_all(flagged_assistance_email: "compass-feedback-west@lighthouselabs.ca")
    Location.where(name: %w{Toronto Montreal Halifax London}).update_all(flagged_assistance_email: "compass-feedback-east@lighthouselabs.ca")
  end
end
