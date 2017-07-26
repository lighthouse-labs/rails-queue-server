desc "Dequeues assistance requests and tech interviews"
namespace :queue do
  task clear: :environment do
    begin
      AssistanceRequestAndTechInterviewDestroyer.new.run
    rescue StandardError => e
      if Rails.env.development?
        raise e
      else
        Raven.capture_exception(e)
      end
    end
  end
end
