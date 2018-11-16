class CurriculumDeploymentWorker

  include Sidekiq::Worker

  # Don't want it to retry a failed deployment. Move on!
  # https://github.com/mperham/sidekiq/wiki/Error-Handling
  sidekiq_options retry: false

  def perform(repo_id, branch, sha)
    repo = ContentRepository.find repo_id

    Content::Deploy.call(
      content_repository: repo,
      branch:             branch,
      sha:                sha
    )
  end

end
