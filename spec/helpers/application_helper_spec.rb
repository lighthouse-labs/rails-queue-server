require "rails_helper"

describe ApplicationHelper, type: :helper do
  let(:calgary) { create :location, timezone: 'Mountain Time (US & Canada)', name: 'Calgary' }
  let(:student) { build :student }
  let(:satellite_student) { build :student, location: calgary }

  describe '#integer_time_to_s' do
    it "should calculate the correct time (heh)" do
      allow(helper).to receive(:current_user).and_return(student)
      expect(helper.integer_time_to_s(900)).to eql "9:00"
      expect(helper.integer_time_to_s(1100)).to eql "11:00"
      expect(helper.integer_time_to_s(930)).to eql "9:30"
      expect(helper.integer_time_to_s(1130)).to eql "11:30"
      expect(helper.integer_time_to_s(959)).to eql "9:59"
    end

    it "should take into account different timezones" do
      allow(helper).to receive(:current_user).and_return(satellite_student)
      expect(helper.integer_time_to_s(900)).to eql "10:00"
      expect(helper.integer_time_to_s(1100)).to eql "12:00"
      expect(helper.integer_time_to_s(930)).to eql "10:30"
      expect(helper.integer_time_to_s(1130)).to eql "12:30"
      expect(helper.integer_time_to_s(959)).to eql "10:59"
    end
  end
end
