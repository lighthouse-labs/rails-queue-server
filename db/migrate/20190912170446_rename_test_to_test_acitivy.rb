class RenameTestToTestAcitivy < ActiveRecord::Migration[5.0]
  def up
    execute "UPDATE activities SET type = 'TestActivity' WHERE type = 'Test'"
  end

  def down 
    execute "UPDATE activities SET type = 'Test' WHERE type = 'TestActivity'"
  end
end
