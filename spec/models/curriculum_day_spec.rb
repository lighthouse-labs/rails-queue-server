require 'rails_helper'

describe CurriculumDay, type: :model do
  # Note: start date must be a monday and tests below assume this
  let(:start_date) { Date.new(2018, 4, 2) }
  let(:program) { create :program }
  let(:cohort) { create :cohort, start_date: start_date, program: program }

  describe '#date' do
    context "for part time programs with weekends" do
      let(:program) { create :program, days_per_week: 2, weekends: true }
      let(:cohort) { create :cohort, start_date: start_date, program: program, weekdays: '1,3' }

      describe 'when initialized as a weekend ("w01e")' do
        subject(:curriculum_day) { CurriculumDay.new('w01e', cohort) }
        it 'it picks the correct saturday date for weekends' do
          expect(curriculum_day.date).to eq(Date.new(2018, 4, 7)) # saturday
        end
      end
    end

    describe '#unlocked?' do
      context "for a cohort over the holiday break 2019" do
        let(:program) { create :program, weeks: 12, weekends: true, curriculum_unlocking: 'weekly' }
        let(:cohort) { create :cohort, start_date: Date.new(2019, 11, 25), program: program }
        let(:timezone) { 'Pacific Time (US & Canada)' }

        describe 'when initialized as "w04e"' do
          subject(:curriculum_day) { CurriculumDay.new('w04e', cohort) }
          it 'it picks the correct saturday date for weekend' do
            expect(curriculum_day.date).to eq(Date.new(2019, 12, 21)) # saturday
          end

          it 'should be unlocked after that date' do
            travel_to Time.new(2019, 12, 27, 12, 00, 00) do
              expect(curriculum_day.unlocked?(timezone)).to eq(true)
            end
          end

          it 'should be unlocked after that date' do
            travel_to Time.new(2019, 12, 30, 12, 00, 00) do
              expect(curriculum_day.unlocked?(timezone)).to eq(true)
            end
          end
        end
      end

      context "for a cohort over the holiday break 2020" do
        let(:program) { create :program, weeks: 12, weekends: true, curriculum_unlocking: 'weekly' }
        let(:cohort) { create :cohort, start_date: Date.new(2020, 11, 25), program: program }
        let(:timezone) { 'Pacific Time (US & Canada)' }

        describe 'when initialized as "w12d5"' do
          subject(:curriculum_day) { CurriculumDay.new('w12d5', cohort) }
          it 'should be locked in January' do
            travel_to Time.new(2021, 1, 1, 12, 00, 00) do
              expect(curriculum_day.unlocked?(timezone)).to eq(false)
            end
          end

          it 'should be unlocked after that date' do
            travel_to Time.new(2021, 4, 30, 12, 00, 00) do
              expect(curriculum_day.unlocked?(timezone)).to eq(true)
            end
          end
        end
      end
    end

    context "when initialized as a w01d1 type string" do
      describe "where we are on 'w01d3'" do
        subject(:curriculum_day) do
          CurriculumDay.new('w01d3', cohort)
        end

        it "is 3 days into the cohorts start date" do
          expect(subject.date).to eq(Date.new(2018, 4, 4))
        end
      end

      describe "where we are past the length of the cohort using 'w11d3'" do
        subject(:curriculum_day) do
          CurriculumDay.new('w11d3', cohort)
        end

        it "is the correct date, even though it goes beyond the length of program" do
          expect(subject.date).to eq(Date.new(2018, 6, 13))
        end
      end
    end

    context "when initialized as a Date" do
      describe "where we are on w01d2" do
        subject(:curriculum_day) do
          CurriculumDay.new(Date.new(2018, 4, 3), cohort)
        end

        it "is the same date that was initialized" do
          expect(subject.date).to eq(Date.new(2018, 4, 3))
        end
      end

      describe "where we are on w4d5" do
        subject(:curriculum_day) do
          CurriculumDay.new(Date.new(2018, 4, 27), cohort)
        end

        it "is the same date that was initialized" do
          expect(subject.date).to eq(Date.new(2018, 4, 27))
        end
      end
    end
  end

  describe '#to_s' do
    context "with programs <10 weeks long" do
      let(:program) { create :program, weeks: 8 }

      describe "when on the first day" do
        subject { CurriculumDay.new(Date.new(2018, 4, 2), cohort) }

        it "is 'w1d1'" do
          expect(subject.to_s).to eq('w1d1')
        end
      end

      describe "any time before the first day" do
        subject { CurriculumDay.new(Date.new(2018, 3, 23), cohort) }

        it "is 'w1d1'" do
          expect(subject.to_s).to eq('w1d1')
        end
      end

      describe "any time after the final day" do
        subject { CurriculumDay.new(Date.new(2019, 4, 4), cohort) }

        # FIXME: OMG this is broken. Fix the logic cuz the test looks right! -KV
        it "is 'w8e'" do
          expect(subject.to_s).to eq('w8e')
        end
      end

      describe "on the second weekend's Saturday" do
        subject { CurriculumDay.new(Date.new(2018, 4, 14), cohort) }

        # FIXME: OMG this is broken. Fix the logic cuz the test looks right! -KV
        it "is 'w2e'" do
          expect(subject.to_s).to eq('w2e')
        end
      end

      describe "on the second weekend's Sunday" do
        subject { CurriculumDay.new(Date.new(2018, 4, 15), cohort) }

        # FIXME: OMG this is broken. Fix the logic cuz the test looks right! -KV
        it "is 'w2e'" do
          expect(subject.to_s).to eq('w2e')
        end
      end
    end

    context "with programs >=10 weeks long" do
      let(:program) { create :program, weeks: 12 }

      describe "when on the first day" do
        subject { CurriculumDay.new(Date.new(2018, 4, 2), cohort) }

        it "is 'w01d1'" do
          expect(subject.to_s).to eq('w01d1')
        end
      end

      describe "any time before the first day" do
        subject { CurriculumDay.new(Date.new(2018, 3, 23), cohort) }

        it "is 'w01d1'" do
          expect(subject.to_s).to eq('w01d1')
        end
      end

      describe "any time after the final day" do
        subject { CurriculumDay.new(Date.new(2019, 4, 4), cohort) }

        # FIXME: OMG this is broken. Fix the logic cuz the test looks right! -KV
        it "is 'w12e'" do
          expect(subject.to_s).to eq('w12e')
        end
      end

      describe "on the second weekend's Saturday" do
        subject { CurriculumDay.new(Date.new(2018, 4, 14), cohort) }

        # FIXME: OMG this is broken. Fix the logic cuz the test looks right! -KV
        it "is 'w02e'" do
          expect(subject.to_s).to eq('w02e')
        end
      end

      describe "on the second weekend's Sunday" do
        subject { CurriculumDay.new(Date.new(2018, 4, 15), cohort) }

        # FIXME: OMG this is broken. Fix the logic cuz the test looks right! -KV
        it "is 'w02e'" do
          expect(subject.to_s).to eq('w02e')
        end
      end

      describe "on the eleventh week's Tuesday" do
        subject { CurriculumDay.new(Date.new(2018, 6, 12), cohort) }

        # FIXME: OMG this is broken. Fix the logic cuz the test looks right! -KV
        it "is 'w11d2'" do
          expect(subject.to_s).to eq('w11d2')
        end
      end
    end
  end
end
