namespace :curriculum do
  task deploy: :environment do
    ContentRepository.all.each do |r|
      Content::Deploy.call(content_repository: r)
    end
  end
end