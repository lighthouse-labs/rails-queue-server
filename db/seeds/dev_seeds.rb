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
      avatar_url:             "http://fillmurray.com/#{50+x*10}/#{50+x*10}",
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
        avatar_url:             "http://placecage.com/#{50+i*10}/#{50+i*10}",
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
          assistor_id:         teacher.id,
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

  # Needed for project evals
  rubric = {
    "project_organization"=>{"name"=>"Project Organization","order"=>10,"rankings"=>{"exceptional"=>Faker::Lorem.sentence,"acceptable"=>Faker::Lorem.sentence,"needs_work"=>Faker::Lorem.sentence,"unsatisfactory"=>Faker::Lorem.sentence}}, 
    "version_control"=>{"name"=>"Version Control","order"=>20,"rankings"=>{"exceptional"=>Faker::Lorem.sentence,"acceptable"=>Faker::Lorem.sentence,"needs_work"=>Faker::Lorem.sentence,"unsatisfactory"=>Faker::Lorem.sentence}}, 
    "functional_requirements"=>{"name"=>"Functional Requirements","order"=>30,"rankings"=>{"exceptional"=>Faker::Lorem.sentence,"acceptable"=>Faker::Lorem.sentence,"needs_work"=>Faker::Lorem.sentence,"unsatisfactory"=>Faker::Lorem.sentence}}, 
    "user_experience"=>{"name"=>"User Experience","order"=>40,"rankings"=>{"exceptional"=>Faker::Lorem.sentence,"acceptable"=>Faker::Lorem.sentence,"needs_work"=>Faker::Lorem.sentence,"unsatisfactory"=>Faker::Lorem.sentence}}, 
    "code_structure"=>{"name"=>"Code Style","order"=>50,"rankings"=>{"exceptional"=>Faker::Lorem.sentence,"acceptable"=>Faker::Lorem.sentence,"needs_work"=>Faker::Lorem.sentence,"unsatisfactory"=>Faker::Lorem.sentence}}, 
    "commenting"=>{"name"=>"Commenting","order"=>60,"rankings"=>{"exceptional"=>Faker::Lorem.sentence,"acceptable"=>Faker::Lorem.sentence,"needs_work"=>Faker::Lorem.sentence,"unsatisfactory"=>Faker::Lorem.sentence}}, 
    "code_best_practices"=>{"name"=>"JavaScript, HTML and CSS Best Practices","order"=>70,"rankings"=>{"exceptional"=>Faker::Lorem.sentence,"acceptable"=>Faker::Lorem.sentence,"needs_work"=>Faker::Lorem.sentence,"unsatisfactory"=>Faker::Lorem.sentence}}, 
    "code_modularity"=>{"name"=>"Code Modularity and Reusability","order"=>80,"rankings"=>{"exceptional"=>Faker::Lorem.sentence,"acceptable"=>Faker::Lorem.sentence,"needs_work"=>Faker::Lorem.sentence,"unsatisfactory"=>Faker::Lorem.sentence}}, 
    "solution_techniques"=>{"name"=>"Solution Techniques","order"=>90,"rankings"=>{"exceptional"=>Faker::Lorem.sentence,"acceptable"=>Faker::Lorem.sentence,"needs_work"=>Faker::Lorem.sentence,"unsatisfactory"=>Faker::Lorem.sentence}}
  }

  # Left out 1 to simulate projects being accepted
  score = ["2", "3", "4"]

  # Seeds for completed cohort only
  Cohort.find_by(code: 'vanc').students.each do |student|
    Project.all.each do |project|
      e = Evaluation.create!(
        project_id: project.id,
        student_id: student.id,
        teacher_id: @teachers.sample.id,
        github_url: Faker::Internet.url('github.com'),
        teacher_notes: Faker::Lorem.sentence,
        student_notes: Faker::Lorem.sentence,
        started_at: Time.zone.today - 20.days,
        completed_at: Time.zone.today - 10.days,
        cohort_id: student.cohort.id,
        final_score: [1, 2, 3].sample + (rand()*100).floor/100.0,
        evaluation_rubric: rubric,
        evaluation_checklist: Faker::Lorem.sentence,
        evaluation_guide: Faker::Lorem.sentence,
        last_sha1: Faker::Number.number(10),
        result: {"commenting": {"score": score.sample,"feedback": Faker::Lorem.sentence}, 
                "code_structure": {"score": score.sample,"feedback": Faker::Lorem.sentence}, 
                "code_modularity": {"score": score.sample,"feedback": Faker::Lorem.sentence}, 
                "user_experience": {"score": score.sample,"feedback": Faker::Lorem.sentence}, 
                "version_control": {"score": score.sample,"feedback": Faker::Lorem.sentence}, 
                "code_best_practices": {"score": score.sample,"feedback": Faker::Lorem.sentence}, 
                "solution_techniques": {"score": score.sample,"feedback": Faker::Lorem.sentence}, 
                "project_organization": {"score": score.sample,"feedback": Faker::Lorem.sentence}, 
                "functional_requirements": {"score": score.sample,"feedback": Faker::Lorem.sentence}},
        state: 'accepted'
      )
      EvaluationTransition.create!(
        to_state: 'accepted',
        metadata: {},
        sort_key: 20,
        evaluation_id: e.id,
        most_recent: true,
        created_at: Time.zone.today - 10.days,
        updated_at: Time.zone.today - 10.days
      )
    end

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
