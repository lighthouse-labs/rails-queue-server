
desc "Trigger deploy of curriculum (simulate webhook from GitHub)"
namespace :curriculum do
  task deploy: :environment do
    branch = ENV['BRANCH'] || 'master'
    ContentRepository.all.each do |r|
      Content::Deploy.call(content_repository: r, branch: branch)
    end
  end
end