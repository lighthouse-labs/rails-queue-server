class ActivitySubmissionWithOptionalFeedback
  include ActiveModel::Model

  # For form object
  # Validation, creation, etc of actual AR instances is done in interactor via controller 
  #    - KV

  attr_accessor(
    :note,
    :time_spent,
    :rating,
    :detail,
    :github_url,
    :activity
  )

end
