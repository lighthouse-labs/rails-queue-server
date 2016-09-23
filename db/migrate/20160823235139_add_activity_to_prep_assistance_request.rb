class AddActivityToPrepAssistanceRequest < ActiveRecord::Migration
  def change
    add_reference :prep_assistance_requests, :activity, index: true, foreign_key: true
  end
end
