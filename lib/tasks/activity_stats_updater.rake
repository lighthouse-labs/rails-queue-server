
desc "Trigger deploy of curriculum (simulate webhook from GitHub)"
namespace :jobs do
  task activity_stats_updater: :environment do
    ActivityStatsUpdater.new.run
  end
end
