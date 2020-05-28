class TagAttribution < ApplicationRecord

  belongs_to :tag
  belongs_to :taggable, polymorphic: true

  scope :on_cohorts,  -> { where(taggable_type: 'Cohort') }
  scope :on_users,    -> { where(taggable_type: 'User') }
  scope :on_students, -> { on_users.where(taggable_id: Student.all.select(:id)) }
  scope :on_teachers, -> { on_users.where(taggable_id: Teacher.all.select(:id)) }

end
