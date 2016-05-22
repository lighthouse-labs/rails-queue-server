class ContentRepository < ActiveRecord::Base

  has_many :activities
  has_many :deployments

  def to_s
    full_name
  end

  def full_name
    "#{github_username}/#{github_repo}"
  end

  def compare_link_with_sha(sha)
    "https://github.com/#{full_name}/compare/#{last_sha}...#{sha}"
  end

end
