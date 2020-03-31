class AddConferenceTypeToAssistances < ActiveRecord::Migration[5.0]
  def change
    add_column :assistances, :conference_type, :string
  end
end
