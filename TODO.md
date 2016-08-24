## HIGH P

X activity test refactor
X student can view until EOW
X activity type of stretch
X "setup for day1" module in prep
X deploy to production
X W1/W2/W3: reorder lecture and breakout to be at top / lowest seq
X W1: Create `evaluates_code=true` problems
  - D1: min values
  - D1: joining concepts
  - D1: password obfuscator


- editorconfig for instructors
- Remove TODOs from W1 and W2

- W2E - add HTML/CSS/jQuery intros / review
- W3E - Khan Academy intro to SQL (etc - from original compass)

- Outcome sync and project content for W2 projects

- W1: Pair programming exercises
- Prep: activity/problem whichSchool should have aside on `return` vs `console.log`
- handle github url for submission (might have broken in v2.0 due to KV's recent changes for prep course activities, none of which have this `allow_submissions=true` boolean)

- fix issue with multiple/dupe quizzes

- W4/W5/W6: reorder lecture and breakout to be at top / lowest seq
- W7/W8: reorder lecture and breakout to be at top / lowest seq

- projects
- associate first 2  (W2's) projects' outcomes and activities

- Self evaluation form every day
- Ability for mentors to add notes
- Ability for mentors to easily see student record


- tech interview UI/UX
- tech interview content

- removal (archival) of activities, sections/projects, questions, quizzes

### UI improvements

X make nav bar a diff colour
X activities#index
  X list lectures/breakouts above first, then activities, then events
  X inline-note activities

- quiz results in activities#show page: http://d.pr/i/1fzuP/WQxo4Mth
- Mocha results and List errors : http://d.pr/i/19P9B/uO4HpLYf

### Content:



- W1: Linter exercise
- W1: JS Mock test for Friday/Weekend
- W1: ESLint file/command in vagrant machine

- For code eval exercises: explain how they work wrt linting -- http://d.pr/i/1lfcz/1Dw5him2

### OTHER:

X disable outcome management for remotely sync'd activities
- disable editing of activity that is sync'd (but needs show page)

- cancel assistance should not destroy it, but rather change state to cancelled
  - This is how AssistanceRequests are handled (`cancelled_at=Time.now`) but not Assistances

- offline assistance creates request (it shouldn't :)
  - puts reason as "offline assistance requested"

```sql
  SQL (0.4ms)  INSERT INTO "assistance_requests" ("requestor_id", "reason", "created_at", "updated_at", "start_at") VALUES ($1, $2, $3, $4, $5) RETURNING "id"  [["requestor_id", 10], ["reason", "Offline assistance requested"], ["created_at", "2016-06-26 22:44:46.372680"], ["updated_at", "2016-06-26 22:44:46.372680"], ["start_at", "2016-06-26 22:44:46.381570"]]
```

- when logging offline assistance for person X, if you do it again the modal contains the old/prev form values (logged by James Sapara; noticed by KV during local testing also!).

- ability to select activity from (autocomplete?) dropdown when creating offline assistance. When completing request-based assistance it should be shown as well but pre-select the activityID in the request so that assister can leave it or change it based on what the interaction was actually about.

- lecture feedback needs to be prompted after the message (include in email sent to students, also remove the link from being added to the message body... lol)

- allow teachers to attempt `evaluates_code=true` exercises

- handle quiz modifications when answers are there (tough?)
- curr deployment notifications
- curr deployment index/show pages for admin
- move outcome content into curriculum repo
- Switch to resque (redis already there)
- disallow `if()` in eslint (needs space) - eslint settings in prep.js.coffee
- move in-browser code eval js code into more obvious location (currently in prep.js.coffee). Also extract the eslint settings into a diff file
- fix and bring back search (removed from nav bar) once it can work better with what days are actually visible to students (doesn't use day filter correctly due to weekly unlocking of content)
- remove happy/sad stats from each day (for mentors)
-