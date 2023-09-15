# mdTranslator-rails

Rails API for mdTranslator: [mdtranslator.adiwg.org](http://mdtranslator.adiwg.org)


# Environment Confguration for use with RVM (Debian Jessie or Ubuntu 16.04 or greater)

*Assumes rvm is installed*

## run rvm script first time if needed, but should be in .bash_profile (or equivilant)

source $HOME/.rvm/scripts/rvm

## install the correct ruby, in this case 2.1.10 (see Gemfile)

rvm install 2.1.10
rvm use 2.1.10

## install the bundler (if needed)

gem install bundler

## install gems needed

bundle install

## OPTIONAL for production - set SECRET_KEY_BASE environment variable##

export SECRET_KEY_BASE=[your secret key base]

*see http://stackoverflow.com/questions/23180650/how-to-solve-error-missing-secret-key-base-for-production-environment-rai or other resources*

## run application

rails server

## Browse to web app

http://localhost:3000

Click on "demo" link to do some metadata translations

## Bonus! Forget all that and just run a Docker

docker run -d -p 8080:8080 mdtoolkit/mdtranslator-rails:2.18.2

## Other

`bundle` to install
`bundle exec rails server` to run the server

## How to add a new writer

Once the writer has been added to the mdTranslator, including the command line interface, follow these instructions:

1. Navigate to `app/views/api/v3/demos/show.html.erb`
2. Add an `<option>` tag to the `<select>` dropdown menu. Note that the lists for the readers and writers is above where it says "Select a Reader" or "Select a Writer" (at first glance of the code this can be confusing).
3. Navigate to `app/models/option.rb`
4. Add your writer to the list of writers. Be sure it matches the format used to identify that writer from the CLI.