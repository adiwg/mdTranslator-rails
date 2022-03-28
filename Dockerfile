FROM ruby:2.7.5
MAINTAINER Derek Williams <djwilliams@usgs.gov>

WORKDIR /app
RUN apt-get update && apt-get install -y nodejs

COPY Gemfile Gemfile.lock ./ 
RUN gem install bundler -v 2.3.8 && bundle install --jobs 4 --retry 5
COPY . .

CMD ["bundle", "exec", "rails", "server"]
