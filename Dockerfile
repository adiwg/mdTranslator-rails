FROM ruby:2.1.10
MAINTAINER Derek Williams <djwilliams@usgs.gov>
RUN apt-get update && apt-get install -y \ 
  nodejs 
RUN gem install rails -v 4.1.1
COPY . /app
COPY Gemfile Gemfile.lock ./ 
RUN gem install bundler && bundle install --jobs 20 --retry 5
COPY . ./
EXPOSE 3000
#in order to run in production set the secret_key_base environment variable on the next line
# export secret_key_base=[secret_key_base]
# CMD ["bundle", "exec", "rails", "server", "-e", "production", "-b", "0.0.0.0"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]