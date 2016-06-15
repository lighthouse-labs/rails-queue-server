class Deployment < ActiveRecord::Base

  belongs_to :content_repository

  def prev
    content_repository.deployments.where('created_at < ?', created_at).order(created_at: :desc).first
  end

  def github_compare_link_against(deployment)
    base_sha = deployment.try(:sha) || 'master'
    "https://github.com/#{content_repository.full_name}/compare/#{base_sha}...#{sha}"
  end


end
