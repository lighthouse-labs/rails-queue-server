Compass - by Lighthouse Labs
=========

[![Build Status](https://semaphoreci.com/api/v1/projects/cc21e629-c80a-4f2e-b372-0ef4226c2e09/2002019/badge.svg)](https://semaphoreci.com/lighthouse-labs/compass)
[![Code Climate](https://codeclimate.com/repos/5908c5f748708a0264000096/badges/2aace388b2ded83be3a6/gpa.svg)](https://codeclimate.com/repos/5908c5f748708a0264000096/feed)
[![Test Coverage](https://codeclimate.com/repos/5908c5f748708a0264000096/badges/2aace388b2ded83be3a6/coverage.svg)](https://codeclimate.com/repos/5908c5f748708a0264000096/coverage)
[![Issue Count](https://codeclimate.com/repos/5908c5f748708a0264000096/badges/2aace388b2ded83be3a6/issue_count.svg)](https://codeclimate.com/repos/5908c5f748708a0264000096/feed)

Welcome to Compass! Lighthouse Lab's website for hosting our curriculum to students and managing their education.

## Deployments

- [Web F/T site](https://web-compass.lighthouselabs.ca)
- [Web P/T site](https://web-pt.compass.lighthouselabs.ca)
- [Web P/T Frontend site](https://web-pt-frontend.compass.lighthouselabs.ca)
- [iOS P/T site](https://ios-pt.compass.lighthouselabs.ca) (deprecated)
- [iOS F/T site](https://ios.compass.lighthouselabs.ca) (deprecated)


## Table of Contents

1. [Setup](#setup)
  - [Github App Setup](#github-app-setup)
  - [Start the Server](#server)
  - [Getting the Queue to work](#queue)
  - [Setting up iOS or Part-time](#ios-and-part-time-support)
2. [Project Management Process](#pm-process)
  - [for Lead Dev](#for-lead-dev)
  - [for Contributors](#for-contributors-and-junior-devs)
3. [Deployment](#deployment)
4. [CSS UI Framework](#css-ui-framework)
5. [Linter](#linter)
6. [Testing](#testing)
7. [CodeClimate](#codeclimate)
8. [Built With](#built-with)

## Setup

Follow these steps in order please:

1. Clone the project
2. `bundle install`
3. Setup your `config/database.yml` based off `config/database.example.yml` (`cp` it)
  * _If you are using vagrant_ (which already has postgres on it): please remove `host: localhost` from both the `development` and `test` db settings. Also, please add `username: ` and `password: ` as empty keys under both sections.
6. Setup a `.env` file based on `.env.example` in the project root: `cp .env.example .env`
5. Setup new DNS Alias for `localhost`:
  * From your terminal, type in `sudo nano /etc/hosts` (Mac/Linux Only)
  * Note: if you are using a VM (Vagrant, etc), this should be done on your host (main) machine, not your virtual machine
  * Add the following entry as a new line at the end of the `/etc/hosts` file: `127.0.0.1 compass.local`.
  * Make sure the HOST env var is set correctly in `.env` (`HOST=compass.local:4000`)
  * Now you can go to the URL `http://compass.local:4000/` instead of `http://localhost:4000/` for when you are working on this app.
6. Create a [Developer level Oauth Application on Github](https://github.com/settings/developers)
  * Screenshot: http://d.pr/i/182yT/1rXSKzEe
  * Set the two client keys as GITHUB_KEY and GITHUB_SECRET in the env file
  * More details below, if you need them.
7. Generate a [GitHub personal access token](https://github.com/settings/tokens/new) for compass on localhost
  * Screenshot of mine: http://d.pr/i/1hjsW/3kWb5gGZ
  * It's needed b/c the curriculum repo with all the content is private and compass needs to use the GH API to access it when seeding/creating activities
  * Set the key as the `GITHUB_ADMIN_OAUTH_TOKEN` in your env file
8. `bin/rake db:setup`
  * This will create, schema load, and seed the db
  * The seed script will download the (private) curriculum repo in order to ingest the content. This means your github auth should be set appropriately, otherwise it will have access issues and fail.
9. Start the server, using `bin/serve`
11. Run `bin/fresh_sidekiq` in another terminal
  * Note: It will intentionally clear the queues (seeds cause a lot of tasks) before starting, so keep that in mind
10. Create an admin+teacher account for yourself. First sign up as a teacher using this URL:
  * <http://compass.local:4000/i/ggg> (teacher invite code URL)
  * Once you've authenticated successfully, `rails c` in and update the user (using `u = User.last`, set `u.admin = true`, then `u.save`)
11. It is recommended that you create/use another, fake github account to represent a student that can be logged in at the same time (in private browsing mode)
  * you can use our (`compass-test-student` GH account, account info available in intern docs)

## Github App Setup

User (student/teacher) Authentication can only happen through Github. Much like how Facebook has Apps that you need if you want to allow users to login through Facebook, we need to create an "app" on Github).

1. Create a Github application on your Github profile (for your dev environment): <https://github.com/settings/applications/new>
2. Specify `http://compass.local:4000/auth/github/callback` as the Callback URL (when they ask you)
3. After the app is created, it gives you some keys. Add the OAuth client ID and client secret as `GITHUB_KEY` and `GITHUB_SECRET` to your `.env` file
4. Kill and Restart your local server (`guard` or `rails s` or whatever) if running

## Server

1. Start the server using the command `bin/serve`.
  - This runs `bin/rails s -b 0.0.0.0 -p 4000`
  - You can change this to 3000 if you prefer (affects above GitHub changes)
2. Run `bin/fresh_sidekiq` in another terminal.
  - Note: This script will intentionally clear the queues for a fresh start.

## Assistance Queue

The Assistance Queue (found on path /assistance_requests) is reliant on Redis (though ActionCable).

To install Redis:

```
brew install redis
```

Run redis with `redis-server` in any directory

### iOS and Part Time Support

It is recommended that you create a second compass on your local machine so that you can quickly switch between iOS and web and any of the part time courses.

1. Setup [GitHub App](#github-app-setup) same as before
2. Follow the [Setup](#setup) above with some modifications:
  - On step 2, change `database.yml` to use a different db, for example, `compass_ios`
  - Stop just before you run `rake db:setup`
    - `db:setup` seeds the database with activities using activities from the [web curriculum repo](https://github.com/lighthouse-labs/2016-web-curriculum-activities).
3. Change the `seeds.rb` file to reflect the repo you want to seed from. In the *ContentRepository.find_or_create_by!(* line change github_repo to appropriate repo, for example: `github_repo: "iOS-Curriculum"` matches with https://github.com/lighthouse-labs/iOS-Curriculum
  - for iOS F/T: https://github.com/lighthouse-labs/iOS-Curriculum
  - for web P/T: https://github.com/lighthouse-labs/intro-to-web-development-curriculum
  - for iOS P/T: https://github.com/lighthouse-labs/iOS-Curriculum-Part-Time
  - for web P/T Frontend: https://github.com/lighthouse-labs/web-pt-frontend-curriculum
4. Continue with the rest of the steps (from step 9)

*if you are setting up a part-time curriculum*, there is a little bit more work you need to do. (configuration for part time needs to be fairly specific or it may not work.)

1.  in `seeds.rb` change `@program`
  ```rb
  p.weeks = 7
  p.days_per_week = 2
  p.weekends = false
  p.curriculum_unlocking = 'weekly'
  p.has_interviews = false
  p.has_projects = false
  ```

2. in `dev_seeds.rb` where `cohort_van` or `cohort_tor`, in `Cohort.create!(` add ` weekdays: '1, 3'` for Monday and Wednesday classes, for example

Reasoning:

  - Usually the part-time curriculum is 2 days per week. This is reflected by changing the `Program.days_per_week` column to 2.
  - Each program has a different length, for iOS part time`Program.weeks = 7`
  - Program should curriculum unlocking weekly, else it does not handle well if the start is not a Monday. Also allows students to look ahead
  - Program false flags on projects on interviews and projects (no interviews/projects)
  - Every cohort needs to setup for weekdays column, for example `'1,3'`, these should match up with the Program's days per week.

## Curriculum Development

Use the rake command `rake curriculum:deploy`. It is suggested that you test your markdown from the curriculum repo before you push that content. This rake command can be given an arg to bypass the process of downloading the curriculum content form github and instead use a local copy.

Example (from the compass dir):

```terminal
bin/rake curriculum:deploy REPO_DIR=/Users/kvirani/github/lighthouse/..../data
```

Alternatively, you can use the GitHub version of the curriculum but a different branch than the master branch:

```terminal
bin/rake curriculum:deploy BRANCH=my-cool-branch-name
```

## PM Process

We are using GitHub Projects to manage this repo.

**Setup**:

1. Use [GitHub Projects](https://github.com/lighthouse-labs/compass/projects/2) to see issues.
2. Download James' [Custom Plugin](https://lhl-git-time-tracker.herokuapp.com/)
  * Use this plugin to add time estimates/actuals to tickets
  * Keep in mind that it contains only issues not PRs. Issues in Review/QA should have relevant PR

### Rules / Process:

#### For lead dev

- Review the PRs in Review/QA pipeline
- Use "Review changes" feature to submit a request for changes, or merge+delete the branch+PR
- If the PR had feedback with request for changes, change its pipeline to Backlog as well
  - Add any missing labels while you are at it
  - BTW The labels are used by [github_changelog_generator](https://github.com/skywinder/github-changelog-generator) to group changes in the CHANGELOG


#### For contributors and junior devs

- When naming branches, please use the following format: `issue#-short-name`  eg: `231-switch-past-cohorts`
- Please Follow issue/PR templates
- Before you submit a PR, please
  - Run [linter](#linter)
  - Run [tests](#testing)
  - Double check your work
  - Check for [CodeClimate](#codeclimate) errors after pr is submitted

Note*: creating an new issue automatically adds a card to the github projects. In addition, submitting a PR moves a card into the Review/QA column when properly labeled (with `resolves #issue`)
## Deployment

**Setup**:

- Please install [github_changelog_generator](https://github.com/skywinder/github-changelog-generator) which is used to generate and update the [CHANGELOG.md](https://github.com/lighthouse-labs/compass/blob/master/CHANGELOG.md)
- Please create a new [personal access token](https://github.com/settings/tokens) for use with this (see below).

1. Create a tag (eg: [2017.07.10.0930](https://github.com/lighthouse-labs/compass/tree/2017.07.10.0930)): `git tag 2017.xx.xx.xxxx`
2. Push the tag: `git push --tags`
3. Run the `github_changelog_generator` with the `-t` parameter: `github_changelog_generator -t <your github token>` from the root of the project.
4. Push the change to the `CHANGELOG.md` to GitHub (master branch)
5. On GitHub, create a [new release](https://github.com/lighthouse-labs/compass/releases/new) using the same name as the tag
  * Paste the relevant contents from the CHANGELOG.md file for the release notes. ([Example](https://github.com/lighthouse-labs/compass/releases/tag/v2.0.2))
6. Push your local master to production: `git push compass2 master`
  * which points to remote: `dokku@compass.lighthouselabs.ca:compass2`
7. If there are migrations: SSH into VM and run migrations: `dokku run compass2 bin/rake db:migrate; dokku ps:restart compass2`
8. Let Ed Ops folks know about the deployment (`web-ed-ops-vancouver@lighthouselabs.ca` and `web-ed-ops-toronto@lighthouselabs.ca`)
9. Let all (web bootcamp) teachers know about the deployment by pasting the link to the release on GitHub on #web-curriculum in Slack

## CSS UI Framework

<https://github.com/wingrunr21/flat-ui-sass> was used to convert FlatUI Pro from LESS to SASS (located in `vendor/assets` )

## Linter

We also have the `rubocop` gem to lint locally, which can be run with `bin/rubocop`. To automatically fix simple lint errors such as indentation and white spacing, you can use `bin/rubocop -a`, however, there is some risk with this.

## Testing

**To run all tests:**

`bin/rspec`

**To run a specific file:**

`bin/rspec ./spec/models/user_spec.rb`

**To run a specific test:**

`bin/rspec ./spec/models/user_spec.rb -e "User has a valid factory"`

**Note:** Use `HEADLESS=0` when running feature specs to see your browser in action (sometimes useful for debugging or just plain entertainment).


## CodeClimate

Running tests with `COV=1` set will generate the `coverage/` folder (from the `simplecov` gem).
Opening up the `coverage/index.html` in the browser shows a filterable breakdown

In order to update the coverage number on CodeClimate, run this command (on master):

`CODECLIMATE_REPO_TOKEN= <% Test Reporter ID %> bundle exec codeclimate-test-reporter`

Where `<% Test Reporter ID %>` is from CodeClimate's website. Settings >> Test Coverage

Make sure gem `codeclimate-test-reporter` version is 1.0+

## Built With

This project is built with:
* Buby 2.4.3
* Rails 5.0.0.1
* Slim instead of ERB or haml or ...
* Postgres 9.x
* Bootstrap 4.something
* Capybara, selenium and chrome-headless for testing
