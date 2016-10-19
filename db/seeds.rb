puts "SEEDING"

# Real shit
@program = Program.find_or_create_by(name: "Web Immersive") do |p|
  p.weeks = 8
end
@location_van = Location.find_or_create_by!(name: "Vancouver")
@location_to = Location.find_or_create_by!(name: "Toronto")

# Note: assumed that you (your github profile) will have access to this curriculum content repo
#       and have set your GITHUB_ADMIN_OAUTH_TOKEN in the .env file
@repo = ContentRepository.find_or_create_by!(
  github_username: "lighthouse-labs",
  github_repo: "2016-web-curriculum-activities"
)

require Rails.root.join('db/seeds/outcomes/sync').to_s

ContentRepository.all.each do |r|
  Content::Deploy.call(content_repository: r)
end

# Fake shit
if Rails.env.development?
  require Rails.root.join('db/seeds/dev_seeds').to_s
end

puts "DONE DONE!"
