require 'rails_helper'

describe ActivitySubmission do
  it 'has a valid factory' do
    expect(build(:activity_submission)).to be_valid
    expect(build(:activity_submission_with_link)).to be_valid
  end
end