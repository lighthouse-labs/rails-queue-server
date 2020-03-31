class AddHasAssistanceRequestHangoutsToPrograms < ActiveRecord::Migration[5.0]
  def change
    add_column :programs, :has_assistance_hangouts, :boolean
  end
end
