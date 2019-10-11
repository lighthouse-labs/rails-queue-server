class Content::HandleGithubWebhookPayload

  include Interactor

  def call
    payload = JSON.parse(context.payload)

    owner, repo = payload['repository']['full_name'].split('/')
    @repo = ContentRepository.find_by(github_username: owner, github_repo: repo)

    context.fail!(error: "Repository #{payload['repository']['full_name']} not found") unless @repo

    # only care about pushes to the branch we care about, usually master
    branch_ref = @repo.github_branch ? "refs/heads/#{@repo.github_branch}" : 'refs/heads/master'
    return true unless payload['ref'] == branch_ref

    sha = payload['after']

    CurriculumDeploymentWorker.perform_async(
      @repo.id,
      nil,
      sha
    )
  end

end
