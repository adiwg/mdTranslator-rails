FROM ruby:2.7.8-slim-buster
MAINTAINER Derek Williams <djwilliams@usgs.gov>

WORKDIR /app

RUN apt-get update && apt-get upgrade -y && apt-get install -y curl nodejs yarn
# RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
# RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

COPY Gemfile Gemfile.lock ./ 
RUN gem install bundler -v 2.3.9 && bundle install --jobs 4 --retry 5
COPY . .

RUN rake assets:precompile

CMD ["bundle", "exec", "rails", "server"]
