require "rails_helper"

describe ApplicationHelper, type: :helper do

  let(:user) { build :user }

  describe '#integer_time_to_s' do
    it "should calculate the correct time (heh)" do
      allow(helper).to receive(:current_user).and_return(user)
      expect(helper.integer_time_to_s(900)).to eql "9:00"
      expect(helper.integer_time_to_s(1100)).to eql "11:00"
      expect(helper.integer_time_to_s(930)).to eql "9:30"
      expect(helper.integer_time_to_s(1130)).to eql "11:30"
      expect(helper.integer_time_to_s(959)).to eql "9:59"
    end
  end
end
