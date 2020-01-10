COHORT_PROGRAMMING_TEST_SQL = <<-SQL.gsub(/\s+/, " ").strip.freeze
  SELECT "programming_tests".* FROM "programming_tests"
  INNER JOIN "activities" ON "activities"."programming_test_id" = "programming_tests"."id"
  LEFT OUTER JOIN "programming_test_attempts" ON "programming_test_attempts"."programming_test_id" = "programming_tests"."id"
  WHERE "programming_test_attempts"."cohort_id" = ?
  OR "activities"."archived" IS NULL
  OR "activities"."archived" = 'f'
  ORDER BY "programming_tests"."day"
SQL

class ProgrammingTest < ApplicationRecord

  # autosave is important becaused on how these are created
  # https://github.com/lighthouse-labs/compass/pull/932#issuecomment-551342225
  has_many :test_activities, dependent: :nullify, autosave: false
  has_many :attempts, class_name: ProgrammingTestAttempt, dependent: :destroy

  validates :exam_code, presence: true
  validates :uuid, presence: true

  scope :active, -> {
    joins(:test_activities)
      .where(activities: { archived: [false, nil] })
      .order(:day)
  }

  scope :for_cohort, ->(cohort) {
    find_by_sql([COHORT_PROGRAMMING_TEST_SQL, cohort.id])
  }

  after_commit :fetch_config

  def type
    try(:config) && config["type"]
  end

  def attempt_for(student, cohort)
    attempts.where(student: student, cohort: cohort).order(:created_at).first
  end

  protected

  def fetch_config
    ProgrammingTestConfigWorker.perform_async(id)
  end

end
