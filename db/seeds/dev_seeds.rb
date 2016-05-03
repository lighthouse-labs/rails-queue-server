# Note: this is a temporary file, until "real" seeding of curriculum content
#       is fully and properly coupled with the curriculum repo
#  - KV

if Rails.env.development?

  puts "Legacy dev-only seed data coming at ya (development - only)!"

  cohort_van = Cohort.find_by(code: 'van')
  cohort_van ||= Cohort.create! name: "Current Cohort Van", location: @location_van, start_date: Date.today - 7.days, program: @program, code: "van"
  
  cohort_tor = Cohort.find_by(code: 'toto')
  cohort_tor ||= Cohort.create! name: "Current Cohort Tor", location: @location_to, start_date: Date.today - 14.days, program: @program, code: "toto"

  1.upto(8).each do |week|
    1.upto(5).each do |day|

      day = "w#{week}d#{day}"

      DayInfo.find_or_create_by!(day: day)

      [900, 1100, 1500, 1900, 2200].each do |time|
        params = {
          name: Faker::Commerce.product_name,
          day: day,
          start_time: time,
          duration: rand(60..180),
          instructions: Faker::Lorem.paragraphs.join("<br/><br/>")
        }

        if time == 900
          Lecture.create!(params)
        else
          Assignment.create!(params)
        end

      end
    end
  end

  User.where(last_name: 'The Fake').destroy_all

  10.times do |i|
    Student.create!(
      first_name: Faker::Name.first_name,
      last_name: "The Fake",
      email: Faker::Internet.email,
      cohort: cohort_van,
      phone_number: '123-123-1234',
      github_username: 'useruser',
      location: @location_van,
      uid: 1000 + i,
      token: 2000 + i,
      completed_registration: true
    )
  end

  10.times do |x|
    Teacher.create!(
      first_name: Faker::Name.first_name,
      last_name:  "The Fake",
      email: Faker::Internet.email,
      uid: 1000 + x,
      token: 2000 + x,
      completed_registration: true,
      company_name: Faker::Company.name,
      bio: Faker::Lorem.sentence,
      specialties: Faker::Lorem.sentence,
      quirky_fact: Faker::Lorem.sentence,
      phone_number: '123-123-1234',
      github_username: 'useruser',
      location: @location_van,
    )
  end

  10.times do |i|
    Student.create!(
      first_name: Faker::Name.first_name,
      last_name:  "The Fake",
      email: Faker::Internet.email,
      cohort: cohort_tor,
      uid: 1011 + i,
      token: 2011 + i,
      completed_registration: true,
      phone_number: '123-123-1234',
      github_username: 'useruser',
      location: @location_to,
    )
  end

end