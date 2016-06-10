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

        # don't create if already there
        if time == 900
          Lecture.create!(params) unless Lecture.where(day: day).any?
        # else
          # Assignment.create!(params) unless Assignment.where(day: day, start_time: time).any?
        end

      end
    end
  end

  User.where(last_name: 'The Fake').destroy_all

  @teachers = []
  10.times do |x|
    @teachers << Teacher.create!(
      first_name: Faker::Name.first_name,
      last_name: 'The Fake',
      email: Faker::Internet.email,
      uid: 1000 + x,
      token: 2000 + x,
      completed_registration: true,
      company_name: Faker::Company.name,
      bio: Faker::Lorem.sentence,
      specialties: Faker::Lorem.sentence,
      quirky_fact: Faker::Lorem.sentence,
      phone_number: Faker::PhoneNumber.phone_number,
      github_username: Faker::Internet.user_name,
      location: locations.sample,
    )
  end

  Cohort.all.each do |cohort|
    10.times do |i|
      Student.create!(
        first_name: Faker::Name.first_name,
        last_name: "The Fake",
        email: Faker::Internet.email,
        cohort: cohort,
        phone_number: Faker::PhoneNumber.phone_number,
        github_username: Faker::Internet.user_name,
        location: cohort.location,
        uid: 1000 + i,
        token: 2000 + i,
        completed_registration: true
      )

      10.times do |y|
          teacher = @teachers.sample
          # create a sampled assistance request
          ar = AssistanceRequest.create!(
            requestor: student,
            assistor_id: teacher.id,
            start_at: Date.today - 10.minutes,
            assistance_start_at: Date.today - 10.minutes,
            assistance_end_at: Date.today - 8.minutes,
            type: nil,
            assistance: Assistance.create(
              assistor_id: teacher.id,
              assistee_id: student.id,
              start_at: Date.today - 10.minutes,
              end_at: Date.today - 8.minutes,
              notes: Faker::Lorem.sentence,
              rating: [1,2,3,4].sample
            ),
            reason: Faker::Lorem.sentence
          )
          # create a student feedback on this AssistanceRequest
          Feedback.create!(
            student_id: student.id,
            teacher_id: teacher.id,
            notes: Faker::Lorem.sentence,
            rating: [1,2,3,4].sample,
            feedbackable_id: ar.assistance.id,
            feedbackable_type: 'Assistance'
          )
        end # 10 loop for assistance

        # student submissions
        # HACK does not prevent duplicate submissions
        assignments.sample(10).each do |activity|
          ActivitySubmission.create!(
            user: student,
            github_url: Faker::Internet.url('github.com'),
            activity: activity
          )
        end
      end # 10 loop for students
    end # locations
  end

end