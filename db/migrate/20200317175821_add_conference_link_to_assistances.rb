class AddConferenceLinkToAssistances < ActiveRecord::Migration[5.0]
  def change
    add_column :assistances, :conference_link, :string
  end
end
