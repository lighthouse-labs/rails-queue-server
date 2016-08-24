class AddUserToPrepAssistanceRequest < ActiveRecord::Migration
  def change
    add_reference :prep_assistance_requests, :user, index: true, foreign_key: true
  end
end
