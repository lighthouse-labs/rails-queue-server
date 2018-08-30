class Lecture < ApplicationRecord

  include PgSearch

  default_scope { order(created_at: :desc) }

  belongs_to :presenter, class_name: Teacher
  belongs_to :cohort
  belongs_to :activity

  pg_search_scope :by_keywords,
                  against: [:subject, :body],
                  using:   {
                    tsearch: {
                      dictionary: "english",
                      any_word:   true,
                      prefix:     true
                    }
                  }

  scope :for_cohort, ->(cohort) { where(cohort_id: cohort.id) }
  scope :video_is_s3, -> { where(file_type: "S3") }
  scope :most_recent_first, -> { order("lectures.created_at ASC") }
  scope :for_teacher, ->(teacher) { where(presenter: teacher) }
  scope :filter_by_presenter_location, ->(location) {
    joins(presenter: :location)
      .where(users: { location_id: location })
      .references(:teacher, :location)
  }
  scope :advanced_topics, -> { joins(:activity).where(activities: { advanced_topic: true }) }
  scope :until_day, ->(day) { joins(:activity).where("activities.day <= ?", day) }
  scope :with_video, -> { where("lectures.file_type = 'S3' OR lectures.youtube_url LIKE :prefix", prefix: "https://%") }

  validates :activity, presence: true
  validates :cohort, presence: true
  validates :presenter, presence: true
  validates :subject, presence: true, length: { maximum: 100 }
  validates :day, presence: true, format: { with: DAY_REGEX, allow_blank: true }
  validates :body, presence: true
  validate :ensure_program_has_recordings_bucket, if: :is_s3?, on: :create

  ## INSTANCE METHODS

  def s3?
    file_type == "S3" && s3_video_key?
  end

  def manageable_by?(user)
    user.admin? || (user == presenter)
  end

  # Link expires after an hour
  def s3_url
    return nil unless s3?
    @s3_url ||= self.class.s3_presigner.presigned_url(
      :get_object,
      bucket:     program.recordings_bucket,
      key:        s3_object_key,
      expires_in: 3600
    )
  end

  def program
    cohort&.program || Program.first
  end

  ## CLASS METHODS

  def self.s3_presigner
    @s3_presigner ||= Aws::S3::Presigner.new(
      client: s3_client
    )
  end

  def self.s3_client
    @s3_client ||= Aws::S3::Client.new(
      region:            ENV['REC_AWS_REGION'],
      access_key_id:     ENV['REC_AWS_ACCESS_KEY'],
      secret_access_key: ENV['REC_AWS_SECRET_KEY']
    )
  end

  ## PRIVATE METHODS

  def ensure_program_has_recordings_bucket
    errors.add :program, 'associated program must specify recordings bucket' unless program&.recordings_bucket?
  end

  def s3_object_key
    f = program.recordings_folder
    s = f ? f + '/' : ''
    s + s3_video_key
  end

end
