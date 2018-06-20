desc "Data Changes"
namespace :data do
  task disable_queue_days: :environment do
    begin
      program = Program.first
      if program.weeks == 10
        disable_queue_days_arr = %w[w5d1 w5d2 w5d3 w5d4 w5d5 w5e w10d1 w10d2 w10d3 w10d4 w10d5 w10e]
        program.disable_queue_days = disable_queue_days_arr
        puts 'updated program disable_queue_days' if program.save
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
  task blockchain_seed: :environment do
    begin
      @program = Program.create(name: "Blockchain for Developers", weeks: 12, days_per_week: 1, curriculum_unlocking: 'weekly', has_interviews: false, has_projects: false, has_code_reviews: false, has_queue: false)
      @location_van = Location.create(name: "Vancouver", timezone: "Pacific Time (US & Canada)")
      @location_to = Location.create(name: "Toronto", timezone: "Eastern Time (US & Canada)")
      @repo = ContentRepository.create(github_username: "lighthouse-labs", github_repo: 'pgp-blockchain-curriculum', github_branch: 'master')
      old_cohort = Cohort.create(name: "Stock Cohort", location: @location_to, start_date: Time.now.monday - 14.days, program: @program, code: "old", weekdays: '3')
      Cohort.create(name: "Pilot May 21", location: @location_to, start_date: Date.new(2018, 5, 21), program: @program, code: "block-pilot", weekdays: '3')
      Cohort.create(name: "Van Sep 5", location: @location_van, start_date: Date.new(2018, 9, 3), program: @program, code: "van-block", weekdays: '3')
      Cohort.create(name: "Tor Sep 5", location: @location_to, start_date: Date.new(2018, 9, 3), program: @program, code: "lhl-coin", weekdays: '3')
      Cohort.create(name: "Van Oct 31", location: @location_van, start_date: Date.new(2018, 10, 29), program: @program, code: "oct-coin", weekdays: '3')
      Cohort.create(name: "Tor Oct 31", location: @location_to, start_date: Date.new(2018, 10, 29), program: @program, code: "lhl-ico", weekdays: '3')
      puts 'seeding complete for blockchain'
    rescue StandardError => e
      if Rails.env.development?
        raise e
      else
        Raven.capture_exception(e)
      end
    end
  end
end
