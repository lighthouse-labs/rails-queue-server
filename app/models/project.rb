class Project < Section
  validates :name, :description, presence: true

  before_save :set_slug

  def set_slug
    self.slug = self.name.gsub(/\s+/, "").downcase
  end
end
