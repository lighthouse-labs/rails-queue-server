class Tag < ApplicationRecord

  belongs_to :parent_tag, class_name: Tag, optional: true
  has_many :tag_attributions, -> { order('tag_attributions.id DESC') }

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def to_s
    name
  end

end
