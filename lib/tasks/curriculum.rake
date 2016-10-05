
desc "Trigger deploy of curriculum (simulate webhook from GitHub)"
namespace :curriculum do
  task deploy: :environment do
    branch = ENV['BRANCH'] || 'master'

    # repo_dir would be nil for production, where it will go grab the repo from github
    # if not nil, it will skip the whole download step
    # useful for local curriculum change testing (before pushing changes)
    # - KV
    repo_dir = ENV['REPO_DIR']
    ContentRepository.all.each do |r|
      Content::Deploy.call(content_repository: r, branch: branch, repo_dir: repo_dir)
    end
  end

  task update_outcomes: :environment do
    require Rails.root.join('db/seeds/outcomes/sync').to_s
  end
end
