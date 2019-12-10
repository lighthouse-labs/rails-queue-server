class PopulateProgramPrepAssistanceUrl < ActiveRecord::Migration[5.0]
  def change
    Program.where({prep_assistance: true, name: ["Bootcamp"] }).update_all({prep_assistance_url: "http://web-prep-help.lighthouselabs.ca/", prep_assistance: nil})
  end
end
