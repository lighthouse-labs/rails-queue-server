class Content::HandleGithubWebhookPayload
  include Interactor

  def call
    payload = JSON.parse(context.payload)

    owner, repo = payload['repository']['full_name'].split('/')
    @repo = ContentRepository.find_by(github_username: owner, github_repo: repo)

    context.fail!(error: "Repository #{payload['repository']['full_name']} not found") unless @repo

    # only care about pushes to master
    return true unless payload['ref'] == 'refs/heads/master'

    Content::Deploy.call(content_repository: @repo, sha: payload['after'])
  end

end
