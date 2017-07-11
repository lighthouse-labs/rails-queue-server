class ActivitySubmissionSerializer < ActiveModel::Serializer

  attributes :github_url, :formatted_code_evaluation_results, :finalized
  has_one :activity

end
