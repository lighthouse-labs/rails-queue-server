class RunActivityStatsFirstTime < ActiveRecord::Migration
  def up
    ActivityStatsUpdater.new.run
  end
  def down
    say 'nothing to do :)'
  end
end
