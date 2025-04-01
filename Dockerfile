FROM ruby:3.2.0-slim

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs

# Set working directory
WORKDIR /app

# Copy Gemfile and install dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the rest of the application
COPY . .

# Set environment variables
ENV RACK_ENV=production
ENV POSTGRES_HOST=db

# Expose port
EXPOSE 9292

# Start the application
CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0"] 