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
  task rbc_seed: :environment do
    begin
      @program = Program.create(name: "RBC Front-End Fundamentals with Javascript", weeks: 6, days_per_week: 2, curriculum_unlocking: 'weekly', has_interviews: false, has_projects: false, has_code_reviews: false, has_queue: false)
      @location_van = Location.create(name: "Vancouver", timezone: "Pacific Time (US & Canada)")
      @location_to = Location.create(name: "Toronto", timezone: "Eastern Time (US & Canada)")
      @repo = ContentRepository.cerate(github_username: "lighthouse-labs", github_repo: 'web-pt-frontend-curriculum', github_branch: 'rbc-corp-production')
      old_cohort = Cohort.create(name: "Stock Cohort", location: @location_to, start_date: Time.now.monday - 14.days, program: @program, code: "old", weekdays: '1,3')
      first_cohort = Cohort.create(name: "Stock Cohort", location: @location_to, start_date: Date.new(2018,5,14), program: @program, code: "royalbank", weekdays: '1,3')
      puts 'seeding complete for rbc corp'
    rescue StandardError => e
      if Rails.env.development?
        raise e
      else
        Raven.capture_exception(e)
      end
    end
  end
end
