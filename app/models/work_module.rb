class WorkModule < ApplicationRecord

  default_scope { order(order: :asc) }

  ## ASSOCIATIONS

  belongs_to :workbook
  has_many :work_module_items

  ## VALIDATIONS

  validates :name, presence: true
  validates :uuid, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  ## SCOPES

  scope :active, -> { where(archived: [false, nil]) }

end
