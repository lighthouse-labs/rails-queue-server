require "rails_helper"

describe ApplicationHelper do

  describe '#integer_time_to_s' do
    it "should calculate the correct time (heh)" do
      expect(integer_time_to_s(900)).to eql "9:00"
      expect(integer_time_to_s(1100)).to eql "11:00"
      expect(integer_time_to_s(930)).to eql "9:30"
      expect(integer_time_to_s(1130)).to eql "11:30"
      expect(integer_time_to_s(959)).to eql "9:59"
    end
  end
end
