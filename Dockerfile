# ---------------- BASE STAGE ----------------
FROM ghcr.io/cirruslabs/flutter:3.35.5 AS base
WORKDIR /app

# Copy pubspec first for dependency caching
COPY pubspec.* ./
RUN flutter pub get

# Copy source code
COPY . .

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
RUN flutter analyze

# ---------------- TEST STAGE ----------------
FROM base AS test
WORKDIR /app

# Run unit/widget tests
RUN flutter test --no-pub

# ---------------- BUILD APK STAGE ----------------
FROM base AS build-apk

# Install Android SDK components early for caching


# Now build release APK
RUN flutter build apk --release


