class Content::Deploy

  include Interactor

  before do
    @repo   = context.content_repository
    @sha    = context.sha
    @branch = context.branch || 'master'

    # @repo_dir is usually nil, but can be set and in that case it wont download it from github
    # useful for local curriculum change testing (before pushing changes)
    @repo_dir = context.repo_dir

    Rails.application.eager_load! # needed later
  end

  def call
    @log_path = setup_logger
    deployment do
      repo_dir = @repo_dir || download_and_extract_repo_archive

      # The records array gets appended to and eventually consumed by other services, below
      # It will contain AR instances (some loaded, others built, as needed)
      # - KV
      records = []

      load_prep_records(repo_dir, records)
      load_project_records(repo_dir, records)
      load_teacher_records(repo_dir, records)
      load_activity_records(repo_dir, records)
      load_interview_records(repo_dir, records)

      results = persist_changes(records)
      publish_deploy_summary(results)
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
    Content::LoadPrepSections.call(log: @log, repo_dir: repo_dir, records: records, repo: @repo)
  end

  def load_project_records(repo_dir, records)
    if Dir.exist?(File.join(repo_dir, '_Projects').to_s)
      Content::LoadProjects.call(log: @log, repo_dir: repo_dir, records: records, repo: @repo)
    else
      Rails.logger.info 'Projects not found. Skipping.'
    end
  end

  def load_teacher_records(repo_dir, records)
    if Dir.exist?(File.join(repo_dir, 'Teacher Resources').to_s)
      Content::LoadTeacherSections.call(log: @log, repo_dir: repo_dir, records: records, repo: @repo)
    else
      Rails.logger.info 'Teacher resources not found. Skipping.'
    end
  end

  def load_interview_records(repo_dir, records)
    if Dir.exist?(File.join(repo_dir, '_Interviews').to_s)
      Content::LoadInterviews.call(log: @log, repo_dir: repo_dir, records: records, repo: @repo)
    else
      Rails.logger.info 'Interview templates not found. Skipping.'
    end
  end

  def load_activity_records(repo_dir, records)
    Content::LoadActivities.call(log: @log, repo_dir: repo_dir, records: records, repo: @repo)
  end

  def download_and_extract_repo_archive
    result = Content::DownloadRepoArchive.call(log: @log, repo: @repo, sha: @sha, branch: @branch)
    # If triggered via rake command (non github hook, sha is fetched when downloading repo - KV
    @sha ||= result.sha
    @deployment.update!(sha: @sha, branch: @branch) unless @deployment.sha?
    result.repo_dir
  end

  def persist_changes(records)
    Content::Commit.call(log: @log, records: records, repo: @repo)
  end

  def publish_deploy_summary(results)
    Content::PublishDeploySummary.call(log:        @log,
                                       deployment: @deployment,
                                       updated:    results.updated,
                                       created:    results.created,
                                       archived:   results.archived)
  end

  def deploy_started
    @deployment = context.deployment = @repo.deployments.create!(sha: @sha, log_file: @log_path, branch: @branch)
    @log.info "Commencing deployment (id: #{@deployment.id})"
  end

  def deploy_failed(e)
    @deployment.update!(status: 'failed', error_message: e.message)
    @log.error "Deployment failed (id: #{@deployment.id})"
  end

  def deploy_successful
    @deployment.update!(status: 'completed', completed_at: Time.now, summary_file: '')
    @repo.update! last_sha: @sha
    @log.info "Deployment #{@sha} successful (id: #{@deployment.id})"
  end

  def setup_logger
    relative_path = File.join('log', 'content_deployments', @repo.full_name.tr('/', '_'))
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
