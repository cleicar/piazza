# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=2.7.3
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Rails app lives here
WORKDIR /app

# Set production environment
ENV RAILS_ENV="development" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle"
    # BUNDLE_WITHOUT="development"

# Throw-away build stage to reduce size of final image
FROM base as build

# COPY --from=gems /Users/cleivianecosta/.asdf/installs/ruby/2.7.3/lib/ruby/gems/2.7.0/gems/ /usr/local/bundle

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libvips nodejs pkg-config vim curl nano


# Install Node and Yarn
ENV NODE_VERSION=16.5
ENV NVM_DIR=/root/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
RUN . "$NVM_DIR/nvm.sh" \
    && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" \
    && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" \
    && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        npm
RUN npm install -g yarn

# Install application gems
COPY Gemfile Gemfile.lock ./

RUN bundle config set force_ruby_platform true

RUN bundle lock --add-platform x86_64-linux

RUN bundle check || bundle install
    # rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    # bundle exec bootsnap precompile --gemfile

# COPY package.json .
# COPY yarn.lock .
# RUN yarn install

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
# RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
# RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Final stage for app image
FROM base

# Install packages needed for deployment
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app

# Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# Entrypoint prepares the database.
ENTRYPOINT ["/app/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3001
# CMD ["./bin/rails", "server"]
