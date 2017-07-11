desc "Daemon to create tech interviews"
namespace :daemons do
  task tech_interviews: :environment do
    loop do
      sleep((ENV['SLEEP'] || 15).to_i)
      begin
        TechInterviewCreator.new.run
      rescue StandardError => e
        if Rails.env.development?
          raise e
        else
          Raven.capture_exception(e)
        end
      end
    end
    Rails.logger.info 'Done with loop'
  end
end
