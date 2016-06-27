
desc "Trigger deploy of curriculum (simulate webhook from GitHub)"
namespace :curriculum do
  task deploy: :environment do
    branch = ENV['BRANCH'] || 'master'
    ContentRepository.all.each do |r|
      Content::Deploy.call(content_repository: r, branch: branch)
    end
  end

  task update_outcomes: :environment do
    require Rails.root.join('db/seeds/outcomes/sync').to_s
  end
end