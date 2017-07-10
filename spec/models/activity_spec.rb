require 'rails_helper'

describe Activity do

  it "has a valid factory" do
    expect(build(:activity)).to be_valid
  end

  it "should calculate the end time of an activity" do
    activity = create(:activity, start_time: 900, duration: 90)
    activity.end_time.should eql 1030

    activity = create(:activity, start_time: 1100, duration: 30)
    activity.end_time.should eql 1130

    activity = create(:activity, start_time: 1130, duration: 30)
    activity.end_time.should eql 1200

    activity = create(:activity, start_time: 1130, duration: 40)
    activity.end_time.should eql 1210
  end

  before(:each) do
    @activity = build(:activity)
  end

  it "should be invalid without name" do
    @activity.name = nil
    expect(@activity).to be_invalid
    expect(@activity).to have(1).errors_on(:name)
  end
  it "should be valid without duration" do
    @activity.duration = nil
    expect(@activity).to be_valid
  end
  it "should be valid without a start_time" do
    @activity.start_time = nil
    expect(@activity).to be_valid
  end
  it "should be invalid without sequence" do
    @activity.sequence = nil
    expect(@activity).to be_invalid
    expect(@activity).to have(1).errors_on(:sequence)
  end
  it "should be invalid with an improper day" do
    @activity.day = 'week1day2'
    expect(@activity).to be_invalid
    expect(@activity).to have(1).errors_on(:day)
  end
end
