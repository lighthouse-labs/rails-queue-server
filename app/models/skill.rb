class Skill < ApplicationRecord

  belongs_to :category
  has_many :outcomes, dependent: :destroy
  has_many :activities, through: :outcomes

  accepts_nested_attributes_for :outcomes, reject_if: proc { |outcome| outcome[:text].blank? }, allow_destroy: true

  validates :name, uniqueness: { case_sensitive: false }

  scope :search, ->(query) { where("lower(name) LIKE :query", query: "%#{query.downcase}%") }

end
