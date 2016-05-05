c1 = Category.create!(name: "Functionality")
skills1 = []
skills1 << Skill.create!(name: "Validations")
skills1 << Skill.create!(name: "Associations")
skills1 << Skill.create!(name: "Redirecting")

outcome1 = Outcome.create!(text: "Rails ActiveModel Validations")
outcome2 = Outcome.create!(text: "Rails ActiveModel Associations")
outcome3 = Outcome.create!(text: "Rails Controller Redirects")

skills1[0].outcomes << outcome1
skills1[1].outcomes << outcome2
skills1[2].outcomes << outcome3

skills1.each {|skill| c1.skills << skill}
c1.save!

skills2 = []
c2 = Category.create!(name: "Code")
skills2 << Skill.create!(name: "Formatting")
skills2 << Skill.create!(name: "Variable Naming")
skills2 << Skill.create!(name: "Efficiency")

outcome4 = Outcome.create!(text: "Ruby Style: Formatting")
outcome5 = Outcome.create!(text: "Ruby Style: Variable Names")
outcome6 = Outcome.create!(text: "Ruby Efficiency")

skills2[0].outcomes << outcome4
skills2[1].outcomes << outcome5
skills2[2].outcomes << outcome6

skills2.each {|skill| c2.skills << skill}
c2.save!

p = Project.create!(name: "Generic Ruby Project", description: "This project is as generic as can be!", slug:"generic-ruby-project")
p.outcomes << outcome4
p.outcomes << outcome5
p.outcomes << outcome6

p.save!

a1 = Activity.create!(name: "Pouring the Foundations", duration: 10, start_time: 900, day: "w1d3")
a2 = Activity.create!(name: "Building the Walls", duration: 10, start_time: 1000, day: "w1d3")
a3 = Activity.create!(name: "Building the Roof", duration: 10, start_time: 1100, day: "w1d3")

a1.outcomes << outcome1
a2.outcomes << outcome2
a3.outcomes << outcome3

p.activities << a1
p.activities << a2
p.activities << a3

p.save!
