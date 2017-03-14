class AddDayToAssistancesAndRequests < ActiveRecord::Migration[5.0]
  def up

    add_column :assistances, :day, :string
    add_column :assistance_requests, :day, :string

    say "AssistanceRequests: #{AssistanceRequest.count} ..."
    AssistanceRequest.find_each(batch_size: 1000) do |r|
      # they all have it, but just to be safe
      if r.cohort
        d = CurriculumDay.new(r.created_at, r.cohort).to_s
        r.update_columns(day: d)
        print '.'; STDOUT.flush
      end
    end
    puts ''

    say "Assistances: #{Assistance.count} ..."
    Assistance.find_each(batch_size: 1000) do |a|
      # they all have it, but just to be safe
      if a.cohort
        d = CurriculumDay.new(a.start_at, a.cohort).to_s
        a.update_columns(day: d)
        print '.'; STDOUT.flush
      end
    end
    puts ''
  end

  def down
    remove_column :assistances, :day
    remove_column :assistance_requests, :day
  end

end
