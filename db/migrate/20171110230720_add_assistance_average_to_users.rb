class AddAssistanceAverageToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :assistance_average, :float
  end
end
