puts "SEEDING"

def dot
  print '.'; STDOUT.flush
end
def comma
  print ','; STDOUT.flush
end

# Real shit
@program = Program.find_or_create_by!(name: "Web Immersive")
@location_van = Location.find_or_create_by!(name: "Vancouver")
@location_to = Location.find_or_create_by!(name: "Toronto")

# Note: assumed that you (your github profile) will have access to this curriculum content repo
#       and have set your GITHUB_ADMIN_OAUTH_TOKEN in the .env file
@repo = ContentRepository.find_or_create_by!(
  github_username: 'lighthouse-labs', 
  github_repo: '2016-web-curriculum-activities'
)

require Rails.root.join('db/seeds/quizzes').to_s
require Rails.root.join('db/seeds/prep').to_s

# Fake shit
if Rails.env.development?
  # require Rails.root.join('db/seeds/dev_seeds').to_s
end

puts "DONE DONE!"