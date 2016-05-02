puts "SEEDING"

def dot
  print '.'; STDOUT.flush
end
def comma
  print ','; STDOUT.flush
end

# Note: assumed that you (your github profile) will have access to this curriculum content repo
#       and have set your GITHUB_ADMIN_OAUTH_TOKEN in the .env file
$github_username = "lighthouse-labs"
$github_repo = "2016-web-curriculum-activities"
$github_ref = "master"

class ExternalResource
  @@client = nil

  def self.init
    return @@client if @@client
    @@client = Octokit::Client.new(access_token: ENV['GITHUB_ADMIN_OAUTH_TOKEN'])
    @@client.login
    @@client
  end

  def self.fetch(file_path)
    if file_path
      self.init
      begin
        return @@client.contents($github_username+"/"+$github_repo, path: file_path, accept: 'application/vnd.github.V3.raw', ref: $github_ref)
      rescue Octokit::NotFound => e
        puts "NOT FOUND:\n#{file_path}"
      end
    end
    return nil
  end

  def self.fetch_frontmatter(file_path)
    if raw_content = self.fetch(file_path)
      if matches = raw_content.lstrip.match(/^---(.*?)---.*/m)
        return YAML.load(matches[1])
      end
    end
    return {}
  end
end

# Real shit
@program = Program.find_or_create_by!(name: "Web Immersive")
@location_van = Location.find_or_create_by!(name: "Vancouver")
@location_to = Location.find_or_create_by!(name: "Toronto")

@repo = ContentRepository.find_or_create_by!(
  github_username: $github_username,
  github_repo: $github_repo
)

require Rails.root.join('db/seeds/outcomes/sync').to_s
require Rails.root.join('db/seeds/quizzes').to_s
require Rails.root.join('db/seeds/prep').to_s

# Fake shit
if Rails.env.development?
  # require Rails.root.join('db/seeds/dev_seeds').to_s
end

puts "DONE DONE!"
