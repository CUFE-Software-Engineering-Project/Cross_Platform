# ---------------- BASE STAGE ----------------
FROM ghcr.io/cirruslabs/flutter:3.35.5 AS base
WORKDIR /app

# Copy pubspec first for dependency caching
COPY pubspec.* ./
RUN flutter pub get

# Copy source code
COPY . .

# Install Android SDK components early for caching
RUN yes | sdkmanager --licenses

RUN sdkmanager \
    "platform-tools" \
    "platforms;android-34" \
    "build-tools;34.0.0" \
    "cmdline-tools;latest"




# ---------------- LINT STAGE ----------------
FROM base AS lint
WORKDIR /app

COPY pubspec.* ./
RUN flutter pub get

COPY . .
RUN flutter analyze || true


# ---------------- TEST STAGE ----------------
FROM lint AS test
WORKDIR /app

# Run unit/widget tests
RUN flutter test --no-pub

# --------------- E2E TEST ---------------------
FROM base AS e2e
RUN flutter test integration_test || true


# ---------------- BUILD APK STAGE ----------------
FROM base AS build-apk
RUN flutter build apk --release
