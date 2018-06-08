require "rails_helper"

describe Scheduled::Curriculum::WeeklyDigest do

  let(:program) { create :program }
  let(:activity_a) { create :activity }
  let(:activity_b) { create :activity }
  let(:activity_y) { create :activity }
  let(:activity_z) { create :activity }
  let(:cohort) { create :cohort, program: program }
  let(:student) { create :student, cohort: cohort }
  let(:teacher) { create :teacher }
  let(:feedback_a) { create :feedback, feedbackable_id: activity_a, rating: 3 }
  let(:feedback_b) { create :feedback, feedbackable_id: activity_b, rating: 1 }
  let(:feedback_y) { create :feedback, feedbackable_id: activity_y, rating: 4 }
  let(:feedback_z) { create :feedback, feedbackable_id: activity_z, rating: 5 }

  subject(:context) { Scheduled::Curriculum::WeeklyDigest.call(program: program) }

  describe ".call" do

    context "when given a valid program" do
      it "successfully sends an email to the curriculum team" do
        expect(context).to be_a_success
      end
    end

    # context "when there are are negative feedbacks," do
    #   it "feedbacks with rating <= 3 are in the digest email" do
    #     expect(context.activity).to include(activity_a)
    #     expect(context).to include(feedback_b)
    #   end
    # end

    # context "when there are are positive feedbacks," do
    #   it "feedbacks with rating > 3 are not in the digest email" do
    #     expect(context.feedbacks).not_to include(feedback_y)
    #     expect(context.feedbacks).not_to include(feedback_z)
    #   end
    # end

  end
  
end