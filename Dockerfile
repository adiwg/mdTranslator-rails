FROM ruby:2.7.5
MAINTAINER Derek Williams <djwilliams@usgs.gov>
RUN apt-get update && apt-get install -y \ 
  nodejs 
COPY . /app
COPY Gemfile Gemfile.lock ./ 
RUN gem install bundler -v 2.3.8 && bundle install --jobs 4 --retry 5
COPY . ./
EXPOSE 3000
#in order to run in production set the secret_key_base environment variable on the next line
# export secret_key_base=[secret_key_base]
# CMD ["bundle", "exec", "rails", "server", "-e", "production", "-b", "0.0.0.0"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
