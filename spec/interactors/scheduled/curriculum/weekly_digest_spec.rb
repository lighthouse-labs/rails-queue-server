require "rails_helper"

describe Scheduled::Curriculum::WeeklyDigest do

  let(:program) { create :program }
  subject(:context) { Scheduled::Curriculum::WeeklyDigest.call(program: program) }

  # context "when given a valid program" do
  context 'when there is no feedback to report on' do
    it 'still sends email to the curriculum team' do
      expect(CurriculumTeamMailer).to receive(:weekly_digest).and_call_original
      context
    end
  end

  # FIXME: Need to add in program into each activity once we fix activity->program association
  context 'when there is feedback to report on' do
    let(:activity_a) { create :activity }
    let(:activity_b) { create :activity }
    let(:activity_c) { create :activity }
    let(:activity_d) { create :activity }

    # Feedback against activity_a (broad spectrum)
    let!(:great_feedback_a)  { create :activity_feedback, activity: activity_a, rating: 5 }
    let!(:medium_feedback_a) { create :activity_feedback, activity: activity_a, rating: 3 }
    let!(:low_feedback_a)    { create :activity_feedback, activity: activity_a, rating: 2 }
    let!(:poor_feedback_a)   { create :activity_feedback, activity: activity_a, rating: 1 }

    let!(:old_poor_feedback_a) { create :activity_feedback, activity: activity_a, rating: 1, created_at: 8.days.ago }

    # Feedback against activity_b (mixed feedback)
    let!(:poor_feedback_b) { create :activity_feedback, activity: activity_b, rating: 1 }
    let!(:good_feedback_b) { create :activity_feedback, activity: activity_b, rating: 4 }
    let!(:poor_feedback_without_details_b) { create :activity_feedback, activity: activity_b, rating: 1, detail: '' }

    # Feedback against activity_c (only positive)
    let!(:good_feedback_c) { create :activity_feedback, activity: activity_c, rating: 4 }


    it 'sends email to the curriculum team' do
      expect(CurriculumTeamMailer).to receive(:weekly_digest).once.with(an_instance_of(Hash), program).and_call_original
      context
    end


    context 'context.feedbacks' do

      it "excludes activities that have only positive ratings" do
        expect(context.feedbacks).to_not include(activity_c)
      end

      it "contains activities that have at least one negative rating" do
        expect(context.feedbacks).to include(activity_a)
        expect(context.feedbacks).to include(activity_b)
      end

      it "contains feedback with rating 1" do
        expect(context.feedbacks[activity_a]).to include(poor_feedback_a)
        expect(context.feedbacks[activity_b]).to include(poor_feedback_b)
      end

      it "contains feedback with rating 2" do
        expect(context.feedbacks[activity_a]).to include(low_feedback_a)
      end

      it "contains feedback with rating 3" do
        expect(context.feedbacks[activity_a]).to include(medium_feedback_a)
      end

      # WHICH FEEDBACK SHOULD BE EXCLUDED?

      it "excludes feedback with rating 4" do
        expect(context.feedbacks[activity_b]).to_not include(good_feedback_b)
      end

      it "excludes feedback with rating 5" do
        expect(context.feedbacks[activity_a]).to_not include(great_feedback_a)
      end

      it "excludes feedback that is older than 7 days" do
        expect(context.feedbacks[activity_a]).to_not include(old_poor_feedback_a)
      end

      it "excludes feedback without detail" do
        expect(context.feedbacks[activity_b]).to_not include(poor_feedback_without_details_b)
      end

    end
  end
end