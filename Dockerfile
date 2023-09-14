# Use a smaller base image
FROM ruby:2.7.7-slim AS base
RUN apt-get update -q && apt-get install -y --no-install-recommends \
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
FROM ruby:2.7.7-slim

# Add non-root user
RUN useradd -ms /bin/bash safeuser

# Set the working directory
WORKDIR /app

# Copy the compiled assets and dependencies from the first stage
COPY --from=base /app /app
COPY --from=base /usr/local/bundle /usr/local/bundle

# Switch to non-root user
USER safeuser

EXPOSE 8080

# Start the Rails server
CMD ["rails", "server", "-b", "127.0.0.1", "-p", "8080"]
