class SinglePrivateCohortForAlumni < ActiveRecord::Migration[5.0]
  def up

    # "limited" cohorts is a pretty special case for giving curriculum access to previous alumni
    # since it will contain ALL previous alumni from that location/branch, then this list will be too large
    # disallow teachres and studenst alike to view this list.
    #  - KV Aug 29, 2016

    p = Program.first

    l = Location.find_by(name: 'Vancouver')
    c = Cohort.create!(
      name: 'Previous Alumni (West)',
      code: 'previous-alumni-west',
      location: l,
      limited: true,
      start_date: '2016-01-04',
      program: p
    )

    l = Location.find_by(name: 'Toronto')
    c = Cohort.create!(
      name: 'Previous Alumni (East)',
      code: 'previous-alumni-east',
      location: l,
      limited: true,
      start_date: '2016-01-04',
      program: p
    )

  end

  def down
    c = Cohort.where(code: ['previous-alumni-west', 'previous-alumni-east']).destroy_all
  end
end
