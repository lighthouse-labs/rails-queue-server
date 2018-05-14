class Workbook < ApplicationRecord

  ## ASSOCIATIONS

  belongs_to :content_repository
  has_many :work_modules

  ## VALIDATIONS

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :uuid, presence: true, uniqueness: true

  ## SCOPES

  scope :active, -> { where(archived: [false, nil]) }

  ## INSTANCE METHODS

  def to_param
    slug
  end

end
