class ContentRepository < ApplicationRecord

  has_many :activities
  has_many :deployments

  def to_s
    full_name
  end

  def full_name
    "#{github_username}/#{github_repo}"
  end

end
