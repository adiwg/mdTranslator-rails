# Use a smaller base image
FROM ruby:2.7.7-slim AS base
RUN apt-get update -q && apt-get install -y --no-install-recommends \
    nodejs \
    build-essential

# Set the working directory
WORKDIR /app

# Install dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' && bundle install --jobs 4 --retry 3

# Copy the rest of the application files
COPY . .

# Precompile assets
RUN bundle exec rails assets:precompile RAILS_ENV=production

# Use a smaller base image for the final container
FROM ruby:2.7.7-slim
RUN apt-get update -q && apt-get install -y --no-install-recommends \
    nodejs

# Add non-root user
RUN useradd -ms /bin/bash safeuser

# Set the working directory
WORKDIR /app

# Copy the compiled assets and dependencies from the first stage
COPY --from=base /app /app
COPY --from=base /usr/local/bundle /usr/local/bundle

# Change owner to safeuser
RUN chown -R safeuser:safeuser /app/log /app/tmp

# Switch to non-root user
USER safeuser

ENV RAILS_SERVE_STATIC_FILES=true

EXPOSE 8080

# Start the Rails server
# CMD ["rails", "server", "-b", "0.0.0.0", "-p", "8080", "-e", "production"]
