
desc "Trigger deploy of curriculum (simulate webhook from GitHub)"
namespace :curriculum do
  task deploy: :environment do
    ContentRepository.all.each do |r|
      Content::Deploy.call(content_repository: r)
    end
  end
end