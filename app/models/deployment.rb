class Deployment < ApplicationRecord

  belongs_to :content_repository, -> { with_deleted }
  default_scope -> { order(created_at: :desc) }

  def prev
    content_repository.deployments.where('created_at < ?', created_at).order(created_at: :desc).first
  end

  def completed?
    status == 'completed'
  end

  def started?
    status == 'started'
  end

  def github_compare_link_against(deployment)
    base_sha = deployment.try(:sha) || 'master'
    "https://github.com/#{content_repository.full_name}/compare/#{base_sha}...#{sha}\#files_bucket"
  end

end
