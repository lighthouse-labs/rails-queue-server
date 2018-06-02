class WorkModuleItem < ApplicationRecord

  ## ASSOCIATIONS

  belongs_to :work_module
  belongs_to :activity

  ## VALIDATIONS

  validates :work_module, presence: true
  validates :activity, presence: true

  ## SCOPES

  scope :active,  -> { where(archived: [false, nil]) }
  scope :core,    -> { where(stretch: [false, nil]) }
  scope :stretch, -> { where(stretch: true) }

end
