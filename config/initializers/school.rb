DAY_FEEDBACK_AFTER = (ENV['DAY_FEEDBACK_AFTER'] || 64_800).to_i # seconds since beginning of day

# w##d[1-5] or w##e, also enforces no trailing text
DAY_REGEX = /\A(w\d{1,2}d[1-5]\z)|(w\d{1,2}e\z)/
TEN_WEEK_DAY_REGEX = /\A(w\d{2}d[1-5]\z)|(w\d{2}e\z)/
