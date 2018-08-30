Rails.logger.info "SEEDING"

# Real shit
@program = Program.find_or_create_by(name: "Bootcamp") do |p|
  p.weeks = 10
  p.days_per_week = 5
  p.weekends = true
  p.curriculum_unlocking = 'weekly'
  p.has_projects = true
  p.has_interviews = true
  p.has_code_reviews = true
  p.has_queue = true
  p.has_advanced_lectures = true
end
@location_van = Location.find_or_create_by!(name: "Vancouver", timezone: "Pacific Time (US & Canada)")
@location_to = Location.find_or_create_by!(name: "Toronto", timezone: "Eastern Time (US & Canada)")
@location_cal = Location.find_or_create_by!(name: "Calgary", timezone: "Mountain Time (US & Canada)")

# Note: assumed that you (your github profile) will have access to this curriculum content repo
#       and have set your GITHUB_ADMIN_OAUTH_TOKEN in the .env file

# repo_name = "iOS-Curriculum"
# repo_name = "web-pt-frontend-curriculum"
repo_name = "2016-web-curriculum-activities"

@repo = ContentRepository.find_or_create_by!(
  github_username: "lighthouse-labs",
  github_repo: repo_name
)

require Rails.root.join('db/seeds/outcomes/sync').to_s

ContentRepository.all.each do |r|
  Content::Deploy.call(content_repository: r)
end

# Fake shit
if Rails.env.development?
  require Rails.root.join('db/seeds/dev_seeds').to_s
end

Rails.logger.info "DONE DONE!"
