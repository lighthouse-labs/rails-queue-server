# Note: this is a temporary file, until "real" seeding of curriculum content
#       is fully and properly coupled with the curriculum repo
#  - KV

if Rails.env.development?

  locations = [@location_van, @location_to]

  puts "Legacy dev-only seed data coming at ya (development - only)!"

  cohort_van = Cohort.find_by(code: 'van')
  cohort_van ||= Cohort.create! name: "Current Cohort Van", location: @location_van, start_date: Time.zone.today - 7.days, program: @program, code: "van"

  cohort_tor = Cohort.find_by(code: 'toto')
  cohort_tor ||= Cohort.create! name: "Current Cohort Tor", location: @location_to, start_date: Time.zone.today - 14.days, program: @program, code: "toto"

  cohort_van_finished = Cohort.find_by(code: 'vanc')
  cohort_van_finished ||= Cohort.create! name: "Previous Cohort Van", location: @location_van, start_date: Time.zone.today - 67.days, program: @program, code: "vanc"

  User.where(last_name: 'The Fake').destroy_all

  @teachers = []
  10.times do |x|
    @teachers << Teacher.create!(
      first_name:             Faker::Name.first_name,
      last_name:              'The Fake',
      email:                  Faker::Internet.email,
      uid:                    1000 + x,
      token:                  2000 + x,
      completed_registration: true,
      company_name:           Faker::Company.name,
      bio:                    Faker::Lorem.sentence,
      specialties:            Faker::Lorem.sentence,
      quirky_fact:            Faker::Lorem.sentence,
      phone_number:           Faker::PhoneNumber.phone_number,
      github_username:        Faker::Internet.user_name,
      avatar_url:             "http://fillmurray.com/#{50+x}/#{50+x}",
      location:               locations.sample
    )
  end

  Cohort.all.each do |cohort|
    10.times do |i|
      student = Student.create!(
        first_name:             Faker::Name.first_name,
        last_name:              "The Fake",
        email:                  Faker::Internet.email,
        cohort:                 cohort,
        phone_number:           Faker::PhoneNumber.phone_number,
        github_username:        Faker::Internet.user_name,
        location:               cohort.location,
        uid:                    1000 + i,
        token:                  2000 + i,
        completed_registration: true
      )

      10.times do |_y|
        teacher = @teachers.sample
        # create a sampled assistance request
        ar = AssistanceRequest.create!(
          requestor:           student,
          start_at:            Time.zone.today - 10.minutes,
          assistance_start_at: Time.zone.today - 10.minutes,
          assistance_end_at:   Time.zone.today - 8.minutes,
          type:                nil,
          assistance:          Assistance.create(
            assistor: teacher,
            assistee: student,
            start_at: Time.zone.today - 10.minutes,
            end_at:   Time.zone.today - 8.minutes,
            notes:    Faker::Lorem.sentence,
            rating:   [1, 2, 3, 4].sample
          ),
          reason:              Faker::Lorem.sentence
        )
        # create a student feedback on this AssistanceRequest
        Feedback.create!(
          student:      student,
          teacher:      teacher,
          notes:        Faker::Lorem.sentence,
          rating:       [1, 2, 3, 4].sample,
          feedbackable: ar.assistance
        )
      end # 10 loop for assistance

      # student submissions
      # HACK does not prevent duplicate submissions
      Activity.where(allow_submissions: true).where.not(evaluates_code: true).order('RANDOM()').limit(10).each do |activity|
        ActivitySubmission.create!(
          user:       student,
          github_url: Faker::Internet.url('github.com'),
          activity:   activity
        )
      end


    end # 10 loop for students
  end # locations

  Cohort.find_by(code: 'vanc').students.each do |student|
    # Project.all.each do |project|
    #   Evaluation.create!(
    #     project_id: project.order,
    #     student_id: student.id,
    #     teacher_id: @teachers.sample.id,
    #     github_url: Faker::Internet.url('github.com'),
    #     teacher_notes: Faker::Lorem.sentence,
    #     student_notes: Faker::Lorem.sentence,
    #     cohort_id: student.cohort.id,
    #     final_score: [1, 2, 3].sample + (rand()*100).floor/100.0,
    #     evaluation_rubric: Faker::Lorem.sentence,
    #     evaluation_checklist: Faker::Lorem.sentence,
    #     evaluation_guide: Faker::Lorem.sentence,
    #     last_sha1: Faker::Number.number(10),
    #     result: 'Accepted',
    #     state: 'accepted'
    #   )
    # end

    TechInterviewTemplate.all.each do |ti|
      t = TechInterview.create!(
        tech_interview_template_id: ti.id,
        interviewee_id: student.id,
        interviewer_id: @teachers.sample.id,
        started_at: Time.zone.today - 10.days,
        completed_at: Time.zone.today - 10.days,
        total_answered: ti.questions.count,
        total_asked: ti.questions.count,
        average_score: 0,
        feedback: Faker::Lorem.sentence,
        internal_notes: Faker::Lorem.sentence,
        cohort_id: student.cohort.id
      )
      TechInterviewQuestion.where(tech_interview_template_id: ti.id).each do |q|
        res = TechInterviewResult.create!(
          tech_interview_id: t.id,
          tech_interview_question_id: q.id,
          question: q.question,
          notes: Faker::Lorem.sentence,
          score: [1, 2, 3, 4].sample,
          sequence: q.sequence
        )
        t.average_score += res.score
      end
      t.average_score /= t.total_asked
      t.save!
    end
  end

end
