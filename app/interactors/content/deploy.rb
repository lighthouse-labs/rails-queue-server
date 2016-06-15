# TODO:
# - create summary html file
# - email notification of summary file

class Content::Deploy
  include Interactor

  before do
    @repo = context.content_repository
    @sha  = context.sha

    Rails.application.eager_load! # needed later
  end

  def call

    @log_path = setup_logger
    deployment do
      repo_dir = download_and_extract_repo_archive

      # The records array gets appended to and eventually consumed by other services, below
      # It will contain AR instances (some loaded, others built, as needed)
      # - KV
      records = []

      load_prep_records(repo_dir, records)
      load_activity_records(repo_dir, records)
      results = persist_changes(records)
      create_summary_file(results)
    end
  end

  private

  def deployment
    deploy_started
    ActiveRecord::Base.transaction do
      yield
    end
    deploy_successful
  rescue Exception => e
    deploy_failed(e)
    raise e
  end

  def load_prep_records(repo_dir, records)
    Content::LoadPrepSections.call(log: @log, repo_dir: repo_dir, records: records)
  end

  def load_activity_records(repo_dir, records)
    Content::LoadActivities.call(log: @log, repo_dir: repo_dir, records: records, repo: @repo)
  end

  def download_and_extract_repo_archive
    result = Content::DownloadRepoArchive.call(log: @log, repo: @repo, sha: @sha)
    # If triggered via rake command (non github hook, sha is fetched when downloading repo - KV
    @sha ||= result.sha
    @deployment.update!(sha: @sha) unless @deployment.sha?
    result.repo_dir
  end

  def persist_changes(records)
    Content::Commit.call(log: @log, records: records, repo: @repo)
  end

  def create_summary_file(results)
    Content::CreateSummaryFile.call({
      log:        @log,
      deployment: @deployment,
      updated:    results.updated,
      created:    results.created,
      archived:   results.archived
    })
  end

  def deploy_started
    @deployment = context.deployment = @repo.deployments.create!(sha: @sha, log_file: @log_path)
    @log.info "Commencing deployment (id: #{@deployment.id})"
  end

  def deploy_failed(e)
    @deployment.update!(status: 'failed', error_message: e.message )
    @log.error "Deployment failed (id: #{@deployment.id})"
  end

  def deploy_successful
    @deployment.update!(status: 'completed', completed_at: Time.now, summary_file: '')
    @repo.update! last_sha: @sha
    @log.info "Deployment #{@sha} successful (id: #{@deployment.id})"
  end

  def setup_logger
    relative_path = File.join('log', 'content_deployments', @repo.full_name.gsub('/', '_'))
    file_name = "#{Time.now.to_i}.log"

    dir = Rails.root.join(relative_path)
    FileUtils.mkdir_p dir

    relative_path = File.join(relative_path, file_name)

    @log = Logging.logger['content::deploy']
    @log.level = :debug

    @log.add_appenders \
        Logging.appenders.stdout,
        Logging.appenders.file(File.join(dir, file_name))

    @log.info "Log file name: #{relative_path}"

    relative_path
  end


end