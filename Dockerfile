# ---------------- BASE STAGE ----------------
FROM ghcr.io/cirruslabs/flutter:3.35.5 AS base
WORKDIR /app

# Copy pubspec first for dependency caching
COPY pubspec.* ./
RUN flutter pub get

# Copy source code
COPY . .

# ---------------- LINT STAGE ----------------
FROM base AS lint
WORKDIR /app

COPY pubspec.* ./
RUN flutter pub get

COPY . .
RUN flutter analyze || true
# ---------------- TEST STAGE ----------------
FROM base AS test
WORKDIR /app

RUN flutter test


# ---------------- BUILD APK STAGE ----------------
FROM base AS build-apk

# Install Android SDK components early for caching


# Now build release APK
RUN flutter build apk --release


