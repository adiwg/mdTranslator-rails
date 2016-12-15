# Environment Confguration for use with RVM (Debian Jessie or Ubuntu 16.04 or greater)


## run rvm script first time if needed, but should be in .bash_profile (or equivilant)

source $HOME/.rvm/scripts/rvm

## install the correct ruby, in this case 2.1.10 (see Gemfile)

rvm install 2.1.10
rvm use 2.1.10

## install the bundler (if needed)

gem install bundler

## install gems needed

bundle install

## run application

rails server

