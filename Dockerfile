# Dockerfile.ci
FROM ghcr.io/cirruslabs/flutter:3.35.5 AS base

WORKDIR /app

# copy pubspec first so we can cache dependencies
COPY pubspec.* ./
RUN flutter pub get

# copy source
COPY . .

# LINTING
FROM base AS lint
RUN flutter analyze

# UNIT TETSING
FROM base AS test
RUN flutter test

# BUILDING
FROM test AS build-apk
RUN flutter build apk --release