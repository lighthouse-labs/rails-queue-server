
desc "Trigger weekly email digest of negative curriculum feedback"
namespace :scheduled do

  namespace :curriculum do
  
    task weekly_digest: :environment do
      programs = Program.all
      programs.each do |program|
        Scheduled::Curriculum::WeeklyDigest.call(program: program)
      end
    end

  end
end
