class Project < Section
  validates :name, :description, presence: true

  before_save :set_slug

  def complete?(user)
    self.activities.each do |activity|
      return false unless user.completed_activity(activity)
    end
  end

  private

  def set_slug
    self.slug = self.name.gsub(/\s+/, "").downcase
  end
end
