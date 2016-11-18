FROM ruby:2.1.10
MAINTAINER Derek Williams <djwilliams@usgs.gov>
RUN apt-get update && apt-get install -y \ 
  build-essential \ 
  nodejs \
  postgresql \
  postgresql-contrib \
  libpq-dev
RUN gem install rails -v 4.1.1
COPY . /app
COPY Gemfile Gemfile.lock ./ 
RUN gem install bundler && bundle install --jobs 20 --retry 5
COPY . ./
EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]