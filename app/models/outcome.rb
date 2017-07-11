class Outcome < ApplicationRecord

  belongs_to :skill

  has_many :item_outcomes, dependent: :destroy
  has_many :activities, through: :item_outcomes, source: :item, source_type: 'Activity'
  has_many :projects, through: :item_outcomes, source: :item, source_type: 'Project'
  has_many :questions, dependent: :destroy

  accepts_nested_attributes_for :item_outcomes, reject_if: proc { |ao| ao[:item_type].blank? }, allow_destroy: true

  validates :text, uniqueness: { case_sensitive: false }

  scope :search, ->(query) { where("lower(text) LIKE :query", query: "%#{query.downcase}%") }
  scope :excluding_knowledge, -> { where.not(taxonomy: 'knowledge') }

end
