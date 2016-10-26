Compass - by Lighthouse Labs
=========

[![wercker status](https://app.wercker.com/status/6070c1bb6d7619eb6e874b177dc3f995/m/ "wercker status")](https://app.wercker.com/project/bykey/6070c1bb6d7619eb6e874b177dc3f995) [![Code Climate](https://codeclimate.com/github/lighthouse-labs/laser_shark.png)](https://codeclimate.com/github/lighthouse-labs/laser_shark) [![Code Climate](https://codeclimate.com/github/lighthouse-labs/laser_shark/coverage.png)](https://codeclimate.com/github/lighthouse-labs/laser_shark/code?sort=covered_percent&sort_direction=desc) [![Dependency Status](https://gemnasium.com/lighthouse-labs/laser_shark.svg)](https://gemnasium.com/lighthouse-labs/laser_shark)


## Ruby / Rails

This project is built with :
* ruby 2.3.0 (mentioned in the Gemfile)
* rails 5.0.0.1
* slim instead of erb/haml
* postgres 9.x
* bootstrap 3.something with FlatUI
* phantomjs (use `brew` to install) for integration test driver
  * Please make sure your phantomjs brew package is up2date: `brew update && brew upgrade phantomjs`
* poltergeist for phantomjs driver

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
  * Add the following entry as a new line at the end of the `/etc/hosts` file: `127.0.0.1 compass.dev`.
  * Make sure the HOST env var is set correctly in `.env` (`HOST=compass.dev:3000`)
  * Now you can go to the URL `http://compass.dev:3000/` instead of `http://localhost:3000/` for when you are working on this app.
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
9. Start the server, using `bin/rails s -b 0.0.0.0`
10. Create an admin+teacher account for yourself. First sign up as a teacher using this URL:
  * <http://compass.dev:3000/i/ggg> (teacher invite code URL)
  * Once you've authenticated successfully, `rails c` in and update the user to `admin=true` status
  * Save without validation (`user.save(validate: false)`) - FIXME: so this is not necessary
11. It is recommended that you create/use another, fake github account to represent a student that can be logged in at the same time (in private browsing mode)

## Github App Setup

User (student/teacher) Authentication can only happen through Github. Much like how Facebook has Apps that you need if you want to allow users to login through Facebook, we need to create an "app" on Github).

1. Create a Github application on your Github profile (for your dev environment): <https://github.com/settings/applications/new>
2. Specify `http://compass.dev:3000/auth/github/callback` as the Callback URL (when they ask you)
3. After the app is created, it gives you some keys. Add the OAuth client ID and client secret as `GITHUB_KEY` and `GITHUB_SECRET` to your `.env` file
4. Kill and Restart your local server (`guard` or `rails s` or whatever) if running

## Server

Start the server using the command `bin/rails s -b 0.0.0.0`.

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

## CSS UI Framwork

<https://github.com/wingrunr21/flat-ui-sass> was used to convert FlatUI Pro from LESS to SASS (located in `vendor/assets` )

## Custom markdown

**To make code selectable in the browser use:**


\`\`\`ruby-selectable
Some selectable text
Some selectable text
Some selectable text
\`\`\`

\`\`\`selectable
Some selectable text here
Some selectable text here
Some selectable text here
\`\`\`

**To make a toggleable answer section:**

```
???ruby
Some ruby code herecode
Some ruby code herecode
Some ruby code herecode
???
```

or

```
???ruby-selectable
Some ruby code herecode
Some ruby code herecode
Some ruby code herecode
???
```

