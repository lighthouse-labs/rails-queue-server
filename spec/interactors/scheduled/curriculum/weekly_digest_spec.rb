require "rails_helper"

describe Scheduled::Curriculum::WeeklyDigest do
  program = Program.find_or_create_by(name: "Bootcamp") do |p|
    p.weeks = 10
    p.days_per_week = 5
    p.weekends = true
    p.curriculum_unlocking = 'weekly'
    p.has_projects = true
    p.has_interviews = true
    p.has_code_reviews = true
    p.has_queue = true
    p.curriculum_team_email = "curriculum@team.com"
  end

  subject(:context) { Scheduled::Curriculum::WeeklyDigest.call(program: program) }

  describe ".call" do

    context "when given a valid program" do
      it "successfully sends an email to the curriculum team" do
        expect(context).to be_a_success
      end
    end

  end
  
end