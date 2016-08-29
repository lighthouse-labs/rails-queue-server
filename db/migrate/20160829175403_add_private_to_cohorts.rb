class AddPrivateToCohorts < ActiveRecord::Migration[5.0]
  def change
    # Note: decided to call it "limited" not "secret" - KV

    # "limited" cohorts is a pretty special case for giving curriculum access to previous alumni
    # since it will contain ALL previous alumni from that location/branch, then this list will be too large
    # disallow teachres and studenst alike to view this list.
    #  - KV Aug 29, 2016
    add_column :cohorts, :limited, :boolean
  end
end
