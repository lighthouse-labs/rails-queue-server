class AddFeedbackEmailToLocations < ActiveRecord::Migration[5.0]
  def up
    add_column :locations, :feedback_email, :string

    Location.where(name: ['Vancouver', 'Kelowna', 'Victoria', 'Calgary']).each do |l|
      # shouldn't fail validation but if it does it's okay (graceful)
      l.update feedback_email: 'compass-feedback-west@lighthouselabs.ca'
    end

    Location.where(name: ['Toronto', 'Montreal', 'Halifax']).each do |l|
      # shouldn't fail validation but if it does it's okay (graceful)
      l.update feedback_email: 'compass-feedback-east@lighthouselabs.ca'
    end
  end

  def down
    remove_column :locations, :feedback_email
  end
end
