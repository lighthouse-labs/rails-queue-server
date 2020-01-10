class AddProctorConfigToProgram < ActiveRecord::Migration[5.0]
  def change
    change_table :programs do |t|
      t.string :proctor_url
      t.string :proctor_write_token
      t.string :proctor_read_token
    end
  end
end
