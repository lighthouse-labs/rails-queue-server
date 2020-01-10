class AddPrepAssistanceUrlToProgram < ActiveRecord::Migration[5.0]
  def change
    add_column :programs, :prep_assistance_url, :string
  end
end
