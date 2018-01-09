desc "Data Changes"
namespace :data do
  task disable_queue_days: :environment do
    begin
      program = Program.first
      if program.weeks == 10
        disable_queue_days_arr = ['w5d1','w5d2','w5d3','w5d4','w5d5','w5e','w10d1','w10d2','w10d3','w10d4','w10d5','w10e']
        program.disable_queue_days = disable_queue_days_arr
        puts 'updated program disable_queue_days'if program.save
      else
        puts "Program not yet set at 10 weeks, run this after program has been set at 10 weeks"
      end
    rescue StandardError => e
      if Rails.env.development?
        raise e
      else
        Raven.capture_exception(e)
      end
    end
  end
end
