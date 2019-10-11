require 'rails_helper'

describe Cohort do
  it "has a valid factory" do
    expect(build(:cohort)).to be_valid
  end

  it "is invalid without a name" do
    expect(build(:cohort, name: nil)).to have(1).errors_on(:name)
  end

  it "is invalid without a start date" do
    expect(build(:cohort, start_date: nil)).to have(1).errors_on(:start_date)
  end

  it "is invalid without weekdays when part time" do
    expect(build(:cohort, weekdays: nil, program: build(:program, days_per_week: 2))).to have(1).errors_on(:weekdays)
  end

  it "is valid with weekdays when part time" do
    expect(build(:cohort, weekdays: '1, 3', program: build(:program, days_per_week: 2))).to be_valid
  end

  it "is valid without weekdays when full time" do
    expect(build(:cohort, weekdays: nil)).to be_valid
  end
end
