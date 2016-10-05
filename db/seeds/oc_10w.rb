name = "Intro to App Development"
code = 'okanagan-college-oct'

@program = Program.find_by(name: name) ||
  Program.create!(
    name: name,
    days_per_week: 2,
    weeks: 10,
    weekends: false,
    curriculum_unlocking: 'weekly',
    has_interviews: false,
    has_projects: false,
    has_code_reviews: false
  )

@location = Location.find_or_create_by!(name: "Kelowna")

@repo = ContentRepository.find_or_create_by!(
  github_username: "lighthouse-labs",
  github_repo: "curriculum-app-dev-10w-intro"
)

@cohort = Cohort.find_by(code: code) ||
  Cohort.create!(
    code: code,
    name: 'Oct 11 - OC',
    weekdays: '2,4',
    program: @program,
    location: @location,
    start_date: '2016-10-11'
  )


ContentRepository.all.each do |r|
  Content::Deploy.call(content_repository: r, repo_dir: '/Users/kvirani/github/curriculum-intro-to-app-dev-10w-pt/data')
end
