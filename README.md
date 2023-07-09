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

## Run via Docker

docker build --name mdtranslator-rails
docker run -d -p 3000:3000 mdtranslator-rails

## Sentry.io Logging Support

If you would like to take advance of Sentry.io you can create your own account then pass in the appropriate values. Configuration settings can be found in `config/initializers/sentry.rb`. It will not be used if the ENV "SENTRY_DSN" value is not passed in.

Using PowerShell

```shell
$env:SENTRY_DSN = "https://{id_here}.ingest.sentry.io/{project_here}"
rails server
```
