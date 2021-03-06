class Teacher < User

  has_many :feedbacks

  # has_many :teaching_assistances, class_name: Assistance, foreign_key: :assistor_uid

  has_many :evaluations

  has_many :tech_interviews, class_name: TechInterview, foreign_key: :interviewer_id

  scope :filter_by_location, ->(location_id) {
    includes(:location)
      .where(locations: { id: location_id })
  }

  scope :filter_by_teacher, ->(teacher_id) {
    where(id: teacher_id)
  }

  scope :has_assisted_student, ->(uid) {
    includes(:teaching_assistances)
      .where(assistances: { assistee_uid: uid })
      .where('assistances.end_at IS NOT NULL')
  }

  scope :on_duty, -> { where(on_duty: true) }

  validates :bio,             length: { maximum: 1000 }
  validates :quirky_fact,     length: { maximum: 255 }
  validates :specialties,     length: { maximum: 255 }

  def self.filter_by(options)
    options.inject(all) do |result, (k, v)|
      attribute = k.gsub("_id", "")
      result = result.send("filter_by_#{attribute}", v)
    end
  end

  def self.mentors(location)
    where(mentor: true)
      .where(location: location)
  end

  def can_access_day?(_day)
    true
  end

  def prospect?
    false
  end

  def teaching_assistances
    Assistance.using(:master).assisted_by(self)
  end

  def busy?
    !teaching_assistances.in_progress.empty?
  end

  def current_enrollment_id
    github_username
  end

end
