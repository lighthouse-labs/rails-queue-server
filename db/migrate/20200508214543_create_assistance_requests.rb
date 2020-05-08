class CreateAssistanceRequests < ActiveRecord::Migration[5.0]
  def change
    create_table    :assistance_requests do |t|
      t.string      :requestor_uid
      t.string      :assistor_uid

      t.datetime    :start_at
      t.references  :assistance, foreign_key: true
      t.references  :compass_instance, foreign_key: true
      t.datetime    :canceled_at
      t.string      :type
      t.integer     :activity_submission_id
      t.text        :reason
      t.integer     :activity_id
      t.integer     :cohort_id
      t.string      :day

      t.timestamps
      t.index     :requestor_uid
      t.index     :assistor_uid
    end
  end
end
