# WIP


if Rails.env.development?
  puts "Purging Prep stuff (development only) ..."
  Activity.where.not(section_id: nil).delete_all # remote prep activities
  Prep.delete_all # remove prep sections
end

puts "Loading prep data ..."

default_activity_attributes = { 
  remote_content: true, 
  content_repository: ContentRepository.first, 
  duration: 15,
  allow_submissions: false,
}


prep_content = {
  'Module 1: Welcome' => {
    slug: 'prep-mod-1-welcome',
    activities: [
      {
        name: 'Welcome',
        type: 'Reading',
        content_file_path: 'data/Prep Module 1 - Welcome/00__Welcome__Outline.md',
        duration: 15,
      },
      {
        name: 'Our Philosophy',
        type: 'Reading',
        content_file_path: 'data/Prep Module 1 - Welcome/01__Our Philosophy__Reading.md',
        duration: 30,
      },
    ]
  },
  'Module 2: Dev Environment' => {
    slug: 'prep-mod-2-dev-env',
    activities: [
      {
        name: 'Tools of the Trade',
        type: 'Reading',
        content_file_path: 'data/Prep Module 2 - Dev Environment/00__Tools of the Trade__Module Outline.md',
        duration: 15,
      },
      {
        name: 'Sublime Code Editor',
        type: 'Task',
        content_file_path: 'data/Prep Module 2 - Dev Environment/02__Sublime Code Editor__Task.md',
        duration: 15,
      },
      {
        name: 'Using Sublime',
        type: 'Assignment',
        content_file_path: 'data/Prep Module 2 - Dev Environment/03__Creating and Editing Text Files Using Sublime__Practice.md',
        duration: 60,
      },
      {
        name: 'The Command Line',
        type: 'Reading',
        content_file_path: 'data/Prep Module 2 - Dev Environment/04__Intro to Command Line__Reading.md',
        duration: 60,
      },
      {
        name: 'Virtual Machines',
        type: 'Reading',
        content_file_path: 'data/Prep Module 2 - Dev Environment/05__Virtual Machines__Reading.md',
        duration: 30,
      },
      {
        name: 'Setup Your VM',
        type: 'Task',
        content_file_path: 'data/Prep Module 2 - Dev Environment/06__VM Setup__Exercise.md',
        duration: 75,
      },
      {
        name: 'How your dev VM works',
        type: 'Video',
        remote_content: false,
        content_repository: nil,
        media_filename: 'vagrant-dev-environment',
        duration: 30,
      },
      {
        name: 'Javascripting in Vagrant',
        type: 'Assignment',
        content_file_path: 'data/Prep Module 2 - Dev Environment/07__Javascripting in Vagrant__Exercise.md',
        duration: 180,
      },
    ]
  },
  'Module 3: Version Control' => {
    slug: 'prep-mod-3-version-control',
    activities: [
      {
        name: 'Version Control and Git',
        type: 'Reading',
        content_file_path: 'data/Prep Module 3 - Version Control/00__Version Control and Git__Outline.md',
        duration: 15,
      },
      {
        name: 'Intro to Version Control',
        type: 'Reading',
        content_file_path: 'data/Prep Module 3 - Version Control/01__Version Control__Reading.md',
        duration: 60,
      },
      {
        name: 'Try Git',
        type: 'Assignment',
        content_file_path: 'data/Prep Module 3 - Version Control/02__Try Git__Practice.md',
        duration: 120,
      },
      {
        name: 'Git It',
        type: 'Assignment',
        content_file_path: 'data/Prep Module 3 - Version Control/03__Git It__Practice.md',
        duration: 120,
      },
      {
        name: 'Github and Tips',
        type: 'Assignment',
        content_file_path: 'data/Prep Module 3 - Version Control/04__Github And Tips__Reading.md',
        duration: 30,
      },
      {
        name: 'Push Javasripting to Github',
        type: 'Assignment',
        content_file_path: 'data/Prep Module 3 - Version Control/05__Push Javascripting to Github__Exercise.md',
        duration: 45,
      },
    ]
  },
  'Module 4: Intro to Programming' => {
    slug: 'prep-mod-4-coding-101',
    activities: [
      {
        name: 'Fundamentals of Programming',
        type: 'Reading',
        content_file_path: 'data/Prep Module 4 - Programming Fundamentals/00__Fundamentals of Programming__Module Outline.md',
        duration: 90,
      },
      {
        name: 'Variables, Types and Operators',
        type: 'Assignment',
        content_file_path: 'data/Prep Module 4 - Programming Fundamentals/01__Variables, Types and Operators__Exercise.md',
        duration: 90,
      },
      {
        name: 'Code Reuse and Functions',
        type: 'Assignment',
        content_file_path: 'data/Prep Module 4 - Programming Fundamentals/02__Code Reuse and Functions__Exercise.md',
        duration: 90,
      },
      {
        name: 'Arrays',
        type: 'Assignment',
        content_file_path: 'data/Prep Module 4 - Programming Fundamentals/03__Arrays__Exercise.md',
        duration: 90,
      },
      {
        name: 'Conditional Execution',
        type: 'Assignment',
        content_file_path: 'data/Prep Module 4 - Programming Fundamentals/04__Conditional Execution__Exercise.md',
        duration: 90,
      },
      {
        name: 'Looping and Repetition',
        type: 'Assignment',
        content_file_path: 'data/Prep Module 4 - Programming Fundamentals/05__Looping and Repetition__Exercise.md',
        duration: 90,
      },
      {
        name: 'Loopy Lighthouse',
        type: 'Assignment',
        content_file_path: 'data/Prep Module 4 - Programming Fundamentals/06__Loopy Lighthouse__Problem.md',
        duration: 180,
      },
      {
        name: 'Objects and Functions',
        type: 'Assignment',
        content_file_path: 'data/Prep Module 4 - Programming Fundamentals/07__Objects and Functions__Exercise.md',
        duration: 180,
      },
    ]
  },
  'Module 5: The Browser' => {
    slug: 'prep-mod-5-browser',
    activities: [
      {
        name: 'The Browser - An Introduction',
        type: 'Reading',
        content_file_path: 'data/Prep Module 5 - The Browser/00__The Browser__Module Outline.md',
        duration: 15,
      },
      {
        name: 'Use Google Chrome',
        type: 'Task',
        content_file_path: 'data/Prep Module 5 - The Browser/01__Use Google Chrome__Task.md',
        duration: 30,
      },
      {
        name: 'Intro to HTML',
        type: 'Reading',
        content_file_path: 'data/Prep Module 5 - The Browser/02__How an HTML Page is Put Together__Reading.md',
        duration: 45,
      },
      {
        name: 'First Web Page',
        type: 'Assignment',
        content_file_path: 'data/Prep Module 5 - The Browser/03__First Web Page__Exercise.md',
        duration: 45,
      },
      {
        name: 'Chrome DevTools',
        type: 'Assignment',
        content_file_path: 'data/Prep Module 5 - The Browser/04__Chrome DevTools__Exercise.md',
        duration: 150,
      },
    ]
  },
  'Module 6: NodeJS' => {
    slug: 'mod5-node',
    activities: [
      {
        name: 'Coming Soon',
        type: 'Assignment',
        remote_content: false,
        instructions: 'Stay tuned :)',
        duration: 0,
      },
    ]
  },
  'Module 7: Stretch' => {
    slug: 'mod7-stretches',
    activities: [
      {
        name: 'Coming Soon',
        type: 'Assignment',
        remote_content: false,
        instructions: 'Stay tuned :)',
        duration: 0,
      },
    ]
  },
}

puts "Creating Prep modules"
i = 1
prep_content.each do |section_name, section_detail|
  print "Creating #{section_name} "; STDOUT.flush
  activities = section_detail[:activities]
  section =  Prep.create! name: section_name, slug: section_detail[:slug], order: i
  i += 1

  activities.each do |activity_attributes|
    section.activities.create! default_activity_attributes.merge(activity_attributes)
    dot
  end
  puts " DONE"
end
