class AddFlagToAssistances < ActiveRecord::Migration[5.0]
  def change
    add_column :assistances, :flag, :boolean
  end
end
