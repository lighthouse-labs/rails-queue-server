#######
# OUTCOMES SEEDING
# This file imports/updates outcomes from a CSV
#
# It's called via the main db/seeds.rb file when running bin/rake db:seed
# It is non-desctructive and creates/updates Outcome, Skill and
# Category records. It requires all these records to have a uuid.
#  -RD
########

require_relative "./lib/sheet"

csv = Rails.root.join("db/seeds/outcomes/Lighthouse Learning Outcomes - Graduate Learning Outcomes.csv")

s = Sheet.new(csv)

Rails.logger.info "Starting Outcomes Sync"

# force: runs even if some lines in spreadsheet are invalid
#        (will skip those lines)
# print: prints to console each line that is added

s.sync(force: true,
       print: true)

Rails.logger.info "Done"

def debug_print
  Category.all.each do |c|
    Rails.logger.debug c.name
    c.skills.each do |s|
      Rails.logger.debug "\t" + s.name
      s.outcomes.each do |o|
        Rails.logger.debug "\t\t" + o.text
      end
    end
  end
end
