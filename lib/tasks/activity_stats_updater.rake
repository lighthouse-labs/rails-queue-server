namespace :jobs do
  task activity_stats_updater: :environment do
    ActivityStatsUpdater.new.run
  end
end
