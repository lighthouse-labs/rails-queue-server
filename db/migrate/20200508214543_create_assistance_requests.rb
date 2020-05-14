class CreateAssistanceRequests < ActiveRecord::Migration[5.0]
  def change
    create_table    :assistance_requests do |t|
      
      t.jsonb       :requestor # :full_name, avatar_url, socials, info(location day), info_url, access
      t.jsonb       :request   # reason, resource uuid, resource_link, resource_name, post_url, info(day)
      t.datetime    :start_at
      t.datetime    :canceled_at
      t.references  :assistance, foreign_key: true
      t.references  :compass_instance, foreign_key: true
      t.string      :type

      t.timestamps
    end
  end
end
