# Lite X

A full-featured Flutter mobile client for the X (Twitter-like) platform, built with Riverpod state management. Lite X provides a complete social media experience including timelines, tweet interactions, messaging, notifications, and more.

<!-- Add a banner/logo image here -->
<!-- ![Lite X Banner](assets/images/banner.png) -->

---

## Table of Contents

- [Features](#features)
  - [Authentication](#authentication)
  - [Home Feed & Tweets](#home-feed--tweets)
  - [Profile](#profile)
  - [Chat & Messaging](#chat--messaging)
  - [Search](#search)
  - [Explore](#explore)
  - [Trends](#trends)
  - [Notifications](#notifications)
  - [Settings & Privacy](#settings--privacy)
  - [Media](#media)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Localization](#localization)
- [Tests](#tests)

---

## Features

### Authentication

User registration, login, and OAuth-based sign-in flows. Supports Google Sign-In and Firebase Authentication.

<!-- Add screenshots for the Authentication feature below -->
<!-- ![Intro Screen](assets/screenshots/auth_intro.png) -->
<!-- ![Login Screen](assets/screenshots/auth_login.png) -->
<!-- ![Create Account Screen](assets/screenshots/auth_create_account.png) -->

---

### Home Feed & Tweets

The core timeline experience with **For You** and **Following** feeds powered by Riverpod state with cached timeline switching. Full tweet interactions including:

- Create, edit, and delete tweets
- Like / unlike and bookmark
- Retweet / undo retweet
- Reply to tweets and view reply threads
- Quote tweets
- View engagement lists (likes, retweets, quotes, replies)
- Hashtag filtering and mentions feed
- AI-powered tweet summary cards

<!-- Add screenshots for the Home Feed & Tweets feature below -->
<!-- ![Home Feed](assets/screenshots/home_feed.png) -->
<!-- ![Create Post](assets/screenshots/home_create_post.png) -->
<!-- ![Tweet Detail](assets/screenshots/home_tweet_detail.png) -->
<!-- ![Reply Thread](assets/screenshots/home_reply_thread.png) -->

---

### Profile

View and manage user profiles with full account customization:

- View own profile and other users' profiles
- Edit profile information, photos, and cover images
- Followers and following lists
- Change email with verification
- User timeline and liked tweets

<!-- Add screenshots for the Profile feature below -->
<!-- ![Profile Screen](assets/screenshots/profile_view.png) -->
<!-- ![Edit Profile](assets/screenshots/profile_edit.png) -->
<!-- ![Followers / Following](assets/screenshots/profile_followers.png) -->

---

### Chat & Messaging

Real-time direct messaging system powered by Socket.io:

- One-on-one conversations
- Group chat support
- Search for users and groups to message

<!-- Add screenshots for the Chat & Messaging feature below -->
<!-- ![Conversations List](assets/screenshots/chat_conversations.png) -->
<!-- ![Chat Screen](assets/screenshots/chat_conversation.png) -->

---

### Search

Global search functionality for discovering tweets and users across the platform.

<!-- Add screenshots for the Search feature below -->
<!-- ![Search Screen](assets/screenshots/search_main.png) -->
<!-- ![Search Results](assets/screenshots/search_results.png) -->

---

### Explore

Discovery surface for finding new content, trending topics, and recommended users.

<!-- Add screenshots for the Explore feature below -->
<!-- ![Explore Screen](assets/screenshots/explore_main.png) -->

---

### Trends

Stay up to date with what's happening:

- Trending topics and hashtags
- Hashtag-filtered tweet feeds
- Who to follow recommendations

<!-- Add screenshots for the Trends feature below -->
<!-- ![Trends Screen](assets/screenshots/trends_main.png) -->
<!-- ![Who to Follow](assets/screenshots/trends_who_to_follow.png) -->

---

### Notifications

Stay informed with push notifications and mention alerts:

- Firebase Cloud Messaging (FCM) integration
- Mention notifications
- Engagement alerts

<!-- Add screenshots for the Notifications feature below -->
<!-- ![Notifications Screen](assets/screenshots/notifications_main.png) -->

---

### Settings & Privacy

Comprehensive settings and privacy controls:

- Account information and username management
- Password changes
- Privacy and safety preferences
- Mute and block management
- Muted and blocked accounts lists

<!-- Add screenshots for the Settings & Privacy feature below -->
<!-- ![Settings Screen](assets/screenshots/settings_main.png) -->
<!-- ![Privacy & Safety](assets/screenshots/settings_privacy.png) -->
<!-- ![Mute & Block](assets/screenshots/settings_mute_block.png) -->

---

### Media

Upload and download media for tweets and profiles:

- Image and video uploads
- Image cropping and editing
- Media downloads

<!-- Add screenshots for the Media feature below -->
<!-- ![Media Upload](assets/screenshots/media_upload.png) -->

---

## Tech Stack

| Category | Technologies |
|---|---|
| **Framework** | Flutter 3.22+, Dart 3 |
| **State Management** | Riverpod 3.0, Riverpod Annotation, Code Generation |
| **Networking** | Dio 5.9.0, HTTP |
| **Real-time** | Socket.io Client |
| **Local Storage** | Hive CE |
| **Navigation** | GoRouter 17.0.0 |
| **Authentication** | Google Sign-In, Firebase Auth |
| **Push Notifications** | Firebase Cloud Messaging |
| **Localization** | Flutter Localizations, intl (English & Arabic) |
| **Media** | Image Picker, Image Cropper, Audio Waveforms, Just Audio |
| **UI Extras** | Flutter SVG, Emoji Picker, Giphy GIF Picker |

---

## Project Structure

```
lib/
├── core/                   # Shared app-wide utilities
│   ├── classes/            # Base classes
│   ├── constants/          # App constants
│   ├── models/             # Shared data models
│   ├── providers/          # Global Riverpod providers
│   ├── routes/             # GoRouter navigation config
│   ├── services/           # HTTP clients, auth services
│   ├── theme/              # Material Design theming
│   ├── utils/              # Helper utilities
│   └── view/               # Core UI shells / layouts
├── features/
│   ├── auth/               # Authentication flows
│   ├── home/               # Main feed & tweet management
│   ├── chat/               # Direct messaging
│   ├── profile/            # User profiles
│   ├── search/             # Search functionality
│   ├── explore/            # Content discovery
│   ├── trends/             # Trending topics
│   ├── notifications/      # Push notifications & mentions
│   ├── settings/           # User preferences & privacy
│   ├── media/              # Media upload / download
│   └── shared/             # Shared feature utilities
└── l10n/                   # Localization (ARB files)
```

Each feature follows a consistent architecture:

```
feature/
├── models/                 # Data models
├── repositories/           # API abstractions (Repository pattern)
├── view_model/             # State management (Riverpod notifiers)
└── view/
    ├── screens/            # Full-page UI screens
    └── widgets/            # Reusable UI components
```

---

## Getting Started

### Prerequisites

- Flutter 3.22+ with Dart 3
- A running backend that implements the `/api/tweets/**` endpoints (see `lib/features/home/repositories/home_repository.dart`)

For help getting started with Flutter, see the [official documentation](https://docs.flutter.dev/).

### Installation

```bash
# Clone the repository
git clone https://github.com/CUFE-Software-Engineering-Project/Lite_X-mobileApp.git
cd Lite_X-mobileApp

# Install dependencies
flutter pub get

# Run the app
flutter run
```

---

## Localization

The app supports **English** and **Arabic** and follows the system locale by default.

### Adding new strings

1. Edit the ARB files under `lib/l10n/`:
   - `app_en.arb` (English)
   - `app_ar.arb` (Arabic)
2. Keep the same keys across both languages.

### Generating localization code

```bash
flutter gen-l10n
```

### Using localized strings in widgets

```dart
import 'package:lite_x/l10n/app_localizations.dart';

Text(AppLocalizations.of(context)!.trendsTitle)
```

### Switching locales manually

Set a specific locale on `MaterialApp.router`:

```dart
locale: const Locale('ar')
```

---

## Tests

```bash
flutter test
```

> **Note:** The default Flutter counter test boots a `SplashScreen` without a `ProviderScope`, so it currently fails outside the application shell. Integrate a test-specific `ProviderScope` or replace the template test to make this suite pass.
