DAY_FEEDBACK_AFTER   = (ENV['DAY_FEEDBACK_AFTER'] || 64_800).to_i # seconds since beginning of day

DAY_REGEX = /\A(w\dd\d)|(w\de)|(prep\d)\z/
