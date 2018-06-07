
desc "Trigger weekly email digest of negative curriculum feedback"
namespace :weekly_digest do
  
  task deploy: :environment do
    programs = Program.all
    programs.each do |program|
      Scheduled::Curriculum::WeeklyDigest.call(program: program)
    end
  end

end
