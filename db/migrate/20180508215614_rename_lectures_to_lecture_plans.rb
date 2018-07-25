class RenameLecturesToLecturePlans < ActiveRecord::Migration[5.0]

  def up
    Activity.where(type: 'Lecture').update_all(type: 'LecturePlan')
  end

  def down
    Activity.where(type: 'LecturePlan').update_all(type: 'Lecture')
  end

end
