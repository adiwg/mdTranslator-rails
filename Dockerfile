# Use a smaller base image
FROM ruby:2.7.8-buster AS base
RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    build-essential

# Set the working directory
WORKDIR /app

# Install dependencies
COPY Gemfile Gemfile.lock ./
RUN gem install bundler:2.3.9 && bundle config set --local without 'development test' && bundle install --jobs 4 --retry 3

# Copy the rest of the application files
COPY . .

# Precompile assets
RUN bundle exec rails assets:precompile RAILS_ENV=production

# Use a smaller base image for the final container
FROM ruby:2.7.8-alpine
RUN apk add nodejs
# RUN apt-get update && apt-get install -y --no-install-recommends

# Set the working directory
WORKDIR /app

# Copy the compiled assets and dependencies from the first stage
COPY --from=base /app /app
COPY --from=base /usr/local/bundle /usr/local/bundle

EXPOSE 3000

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
