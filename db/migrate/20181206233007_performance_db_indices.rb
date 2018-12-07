class PerformanceDbIndices < ActiveRecord::Migration[5.0]
  def change
    add_index :users, :location_id
    add_index :users, :location_id, name: 'active_users_by_location', where: "completed_registration = 't' AND deactivated_at IS NULL"
    add_index :users, :cohort_id, name: 'active_students_by_cohort', where: "completed_registration = true AND deactivated_at IS NULL AND type = 'Student'"

    add_index :assistance_requests, :id, name: 'open_requests_by_id', where: 'canceled_at IS NULL AND type IS NULL AND assistance_id IS NULL'

    add_index :cohorts, :start_date
    add_index :cohorts, :location_id
  end
end
