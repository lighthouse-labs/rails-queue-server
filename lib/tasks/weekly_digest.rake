
desc "Trigger weekly email digest of negative curriculum feedback"
namespace :weekly_digest do
  task deploy: :environment do
    WeeklyDigest::Deploy.call
  end

end
