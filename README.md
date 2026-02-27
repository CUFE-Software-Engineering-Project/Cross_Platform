# Lite X

<p align="center">
  <img src="assets/images/app_logo.png" alt="Lite X Logo" width="200"/>
</p>

Lite X is a full-featured, cross-platform social media application built with Flutter and Riverpod. It provides a complete X (Twitter-like) experience with modern architecture patterns, real-time messaging, and comprehensive user interactions.

## 📱 Overview

Lite X is a feature-rich social media client that implements the complete X API surface, offering users a seamless experience for content creation, discovery, and social interaction. Built with Flutter 3.22+ and Dart 3, the app follows clean architecture principles with Riverpod for state management.

![App Screenshots](assets/images/app_overview.png)
_Main application screens_

---

## ✨ Features

### 🔐 Authentication

Complete authentication system supporting multiple OAuth providers and traditional login methods.

**Key Capabilities:**

- **Multi-provider OAuth**: Login with GitHub, Google, and other OAuth providers
- **Traditional Authentication**: Email/password registration and login
- **Deep Link Integration**: Seamless OAuth callback handling via deep links
- **Secure Token Management**: JWT token storage and automatic refresh
- **Onboarding Flow**: Interactive intro screens and account setup
- **Persistent Sessions**: Automatic login state persistence across app launches

**Screens:**

- Intro/Splash Screen
- Login Screen
- Sign Up Flow
- OAuth Provider Selection
- Account Creation Wizard

![Authentication Flow](assets/images/auth_feature.png)
_Authentication screens and OAuth flow_

**Architecture:**

- `AuthRemoteRepository`: Handles OAuth flows, login/logout, token management
- `AuthLocalRepository`: Manages local token storage and user session data
- Clean separation between remote API calls and local data persistence

---

### 🏠 Home & Feed

Personalized content discovery with intelligent feed algorithms and comprehensive tweet interactions.

**Key Capabilities:**

- **Dual Feed System**: "For You" personalized feed and "Following" chronological feed
- **Tweet Interactions**: Like, retweet, quote, reply, bookmark, and share
- **Tweet Management**: Create, edit, and delete tweets with media support
- **Engagement Insights**: View lists of users who liked, retweeted, or quoted tweets
- **AI-Powered Summaries**: Get AI-generated summaries of tweet threads
- **Hashtag Support**: Browse and create posts with hashtags
- **Mentions Feed**: Track tweets where you're mentioned
- **Thread Views**: Complete reply threads with nested conversations
- **Infinite Scroll**: Cursor-based pagination for smooth feed browsing

**Screens:**

- Home Timeline (For You / Following)
- Tweet Detail Screen
- Create Post Screen
- Edit Tweet Screen
- Reply Composer
- Quote Tweet Composer
- Hashtag Posts Screen
- Mentioned Tweets Screen
- Quotes Screen
- Reposted By Screen
- Reply Thread View

![Home Feed](assets/images/home_feature.png)
_Home timeline and tweet interactions_

**Architecture:**

- `HomeRepository`: Comprehensive API integration for all tweet operations
- State management with Riverpod for real-time feed updates
- Cached timeline switching for instant feed transitions
- Media download integration for tweet images and videos

---

### 👤 Profile

Complete user profile system with customization, follows management, and activity tracking.

**Key Capabilities:**

- **Profile Customization**: Update profile photo, cover image, bio, and personal details
- **Profile Viewing**: View your own and other users' profiles
- **Activity Tracking**: View user tweets, replies, media, and likes
- **Follow System**: Follow/unfollow users with real-time follower/following counts
- **Connection Management**: View followers and following lists
- **Email Management**: Change and verify email addresses
- **Birthdate Handling**: Update and manage birthdate information
- **Profile Search**: Search within user profiles
- **Offline Support**: Local caching of profile data for offline access

**Screens:**

- Profile Screen (with tabs for tweets, replies, media, likes)
- Edit Profile Screen
- Profile Photo/Cover Screen
- Following/Followers List Screen
- Birthdate Screen
- Change Email Screen
- Email Verification Screen
- Profile Search Screen
- Explore Profiles Screen

![Profile Features](assets/images/profile_feature.png)
_User profiles and customization options_

**Architecture:**

- `ProfileRepo` interface with `ProfileRepoImpl` implementation
- `ProfileStorageService`: Local profile data caching with Hive
- Comprehensive error handling with offline fallback
- Optimistic UI updates for instant feedback

---

### 💬 Chat & Messaging

Real-time messaging system with WebSocket support for instant communication.

**Key Capabilities:**

- **Real-Time Messaging**: WebSocket-based instant message delivery
- **Direct Messages**: One-on-one private conversations
- **Group Chats**: Create and manage group conversations
- **Message Types**: Text, media, voice messages, and reactions
- **User Search**: Find and start conversations with users
- **Conversation Management**: View all active conversations
- **Typing Indicators**: Real-time typing status
- **Message Status**: Delivery and read receipts
- **Message History**: Persistent message storage and retrieval
- **Offline Support**: Local message caching and sync

**Screens:**

- Conversations List Screen
- Chat Screen (individual/group)
- User/Group Search Screen

![Chat Interface](assets/images/chat_feature.png)
_Messaging and conversations_

**Architecture:**

- `SocketRepository`: WebSocket connection management for real-time updates
- `ChatRemoteRepository`: RESTful API for chat operations
- `ChatLocalRepository`: Local message and conversation storage
- Event-driven message handling with Riverpod streams

---

### 🔔 Notifications

Comprehensive notification system with FCM integration for push notifications.

**Key Capabilities:**

- **Activity Notifications**: Likes, retweets, follows, and replies
- **Mention Alerts**: Get notified when mentioned in tweets
- **Push Notifications**: Firebase Cloud Messaging integration
- **Notification Categories**: Organized by type (All, Mentions, Verified)
- **Real-Time Updates**: Instant notification delivery
- **Rich Notifications**: Display user avatars, tweet content, and actions
- **Notification History**: Persistent notification storage
- **Deep Linking**: Tap notifications to navigate to relevant content

**Screens:**

- Notifications Screen (with filtered views)
- Mention-specific notifications

![Notifications](assets/images/notifications_feature.png)
_Notification center and alerts_

**Architecture:**

- `NotificationRepository`: Fetch and manage notifications
- `MentionsRepository`: Handle mention-specific notifications
- `NotificationFCMService`: Firebase integration for push notifications
- Background notification handling for real-time delivery

---

### 🔍 Search

Advanced search functionality for discovering content and users across the platform.

**Key Capabilities:**

- **Multi-Tab Search**: Search across Top, Latest, People, and Media
- **Tweet Search**: Find tweets by keywords and hashtags
- **User Search**: Discover users by name, username, or bio
- **Real-Time Suggestions**: Instant search suggestions as you type
- **Search History**: Track and manage recent searches
- **Filter Options**: Refine results by content type
- **Media Search**: Find tweets with specific media types
- **User Profiles**: View complete user info in search results
- **Follow from Search**: Quick follow/unfollow actions

**Screens:**

- Search Screen (with tab bar)
- Search Results Screen

![Search Interface](assets/images/search_feature.png)
_Search functionality and results_

**Architecture:**

- `SearchRepository`: Handles all search queries and filtering
- Tab-based search navigation (Top, Latest, People, Media)
- Debounced search input for optimized API calls
- Integration with Home and Profile repositories

---

### 🧭 Explore

Content discovery hub for finding trending topics and recommended users.

**Key Capabilities:**

- **Curated Content**: Discover trending topics and popular content
- **Category Browsing**: Explore content by categories
- **Personalized Recommendations**: Content suggestions based on interests
- **Trending Topics**: Real-time trending hashtags and discussions
- **Visual Content**: Image and video discovery feed

**Screens:**

- Explore Screen (main discovery hub)

![Explore Page](assets/images/explore_feature.png)
_Explore and discovery features_

**Architecture:**

- Integration with Trends and Home repositories
- Category-based content organization
- Recommendation algorithms for personalized content

---

### 📈 Trends

Track and explore trending topics, hashtags, and popular conversations.

**Key Capabilities:**

- **Trending Hashtags**: Real-time trending hashtags with tweet counts
- **Trend Categories**: Organized trends by topic (News, Sports, Entertainment, etc.)
- **Trend Analytics**: View trend history and engagement metrics
- **Who to Follow**: Suggested users based on interests and activity
- **Hashtag Navigation**: Browse tweets by specific hashtags
- **Trend Persistence**: Track trend evolution over time

**Screens:**

- Trends Screen
- Hashtag Tweets Screen
- Who to Follow Screen
- Explore Trends Screen

![Trends](assets/images/trends_feature.png)
_Trending topics and hashtags_

**Architecture:**

- `TrendsRepository`: Fetch trending data and analytics
- Category-based trend organization
- Integration with explore and search features

---

### ⚙️ Settings

Comprehensive settings and privacy controls for user account management.

**Key Capabilities:**

- **Account Settings**: Manage username, email, and account details
- **Privacy Controls**: Configure privacy and safety settings
- **Password Management**: Change and reset password
- **Block & Mute**: Manage blocked and muted accounts
- **Notification Preferences**: Customize notification settings
- **Data Sharing**: Control data sharing and analytics preferences
- **Account Information**: View and edit personal information
- **Security Features**: Two-factor authentication and login alerts

**Screens:**

- Settings and Privacy Screen
- Your Account Screen
- Account Information Screen
- Change Password Screen
- Username Screen
- Privacy and Safety Screen
- Mute and Block Screen
- Blocked Accounts Screen
- Muted Accounts Screen

![Settings](assets/images/settings_feature.png)
_Settings and privacy options_

**Architecture:**

- `SettingsRepo` interface with implementation
- State management following ProfileBasicDataStates pattern
- `SettingsBasicDataNotifier`: Riverpod StateNotifier for settings
- Responsive design with mobile and web layouts
- Persistent settings storage

---

### 🎬 Media Management

Complete media handling system for uploads, downloads, and processing.

**Key Capabilities:**

- **Multi-Format Support**: Images, videos, GIFs, and audio
- **Upload Pipeline**: Request → Upload → Confirm workflow
- **Progress Tracking**: Real-time upload/download progress
- **Media Compression**: Automatic optimization for bandwidth
- **Cloud Storage**: Integration with cloud media storage
- **Media Gallery**: Browse and manage media attachments
- **Image Editing**: Basic crop and filter capabilities
- **Video Processing**: Thumbnail generation and transcoding
- **Audio Messages**: Record and send voice messages

![Media Handling](assets/images/media_feature.png)
_Media upload and management_

**Architecture:**

- `MediaRepo` with `MediaRepoImpl` implementation
- Three-phase upload process: request → S3 upload → confirm
- `upload_media.dart` and `download_media.dart` utilities
- File type detection and validation
- Progress streaming for large files

---

### 🌐 Shared Components

Reusable UI components and utilities used across features.

**Key Capabilities:**

- **Custom Widgets**: Buttons, cards, dialogs, and form elements
- **Theming System**: Consistent design language across the app
- **Responsive Layouts**: Adaptive UI for mobile, tablet, and web
- **Loading States**: Shimmer effects and loading indicators
- **Error Handling**: Consistent error display and recovery
- **Animations**: Smooth transitions and micro-interactions

![Shared Components](assets/images/shared_components.png)
_Reusable UI components_

---

## 🏗️ Architecture

Lite X follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                    # Core utilities and shared resources
│   ├── classes/            # Core data classes and models
│   ├── models/             # Shared models (User, Tokens, etc.)
│   ├── providers/          # Global Riverpod providers
│   └── services/           # Core services (deep linking, etc.)
├── features/               # Feature-based modules
│   ├── auth/              # Authentication feature
│   │   ├── models/        # Auth-specific models
│   │   ├── repositories/  # Data layer (local + remote)
│   │   ├── view_model/    # State management
│   │   └── view/          # UI layer (screens + widgets)
│   ├── home/              # Home feed feature
│   ├── profile/           # Profile feature
│   ├── chat/              # Messaging feature
│   ├── notifications/     # Notifications feature
│   ├── search/            # Search feature
│   ├── explore/           # Explore feature
│   ├── trends/            # Trends feature
│   ├── settings/          # Settings feature
│   ├── media/             # Media management
│   └── shared/            # Shared UI components
└── l10n/                   # Localization files
```

### Architecture Layers

1. **View Layer**: Flutter widgets and screens
2. **ViewModel Layer**: Riverpod providers and state management
3. **Repository Layer**: Data access abstraction (local + remote)
4. **Model Layer**: Data models and entities
5. **Service Layer**: Core services (network, storage, etc.)

---

## 🌍 Localization

Lite X supports multiple languages with Flutter's internationalization framework.

### Supported Languages

- **English (en)** - Default
- **Arabic (ar)** - Full RTL support

### Adding Translations

1. Edit ARB files in `lib/l10n/`:
   - `app_en.arb` (English)
   - `app_ar.arb` (Arabic)

2. Generate localization code:

   ```powershell
   flutter gen-l10n
   ```

3. Use in widgets:

   ```dart
   import 'package:lite_x/l10n/app_localizations.dart';

   Text(AppLocalizations.of(context)!.trendsTitle)
   ```

### Switching Locales

- Default: Follows system locale
- Manual: Set specific locale in `MaterialApp.router`:
  ```dart
  locale: const Locale('ar')
  ```

---

## 🚀 Getting Started

### Requirements

- **Flutter**: 3.22+
- **Dart**: 3.0+
- **Backend API**: Running instance of the X-like backend
- **Firebase**: Configured project for FCM notifications

### Installation

1. Clone the repository:

   ```powershell
   git clone <repository-url>
   cd Cross_Platform
   ```

2. Install dependencies:

   ```powershell
   flutter pub get
   ```

3. Configure environment variables:
   - Create `.env` file with API endpoints and credentials
   - Update `firebase_options.dart` with your Firebase configuration

4. Generate code:

   ```powershell
   flutter pub run build_runner build --delete-conflicting-outputs
   flutter gen-l10n
   ```

5. Run the app:
   ```powershell
   flutter run
   ```

### Running on Specific Platforms

```powershell
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome

# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

---

## 🧪 Testing

Run the test suite:

```powershell
# Run all tests
flutter test

# Run specific test file
flutter test test/features/auth/auth_test.dart

# Run with coverage
flutter test --coverage
```

### Test Structure

```
test/
├── core/              # Core utilities tests
└── features/          # Feature tests
    ├── auth/         # Authentication tests
    ├── home/         # Home feed tests
    ├── profile/      # Profile tests
    └── ...
```

> **Note**: Ensure tests include `ProviderScope` for Riverpod-dependent widgets.

---

## 📦 Dependencies

### Core Dependencies

- **flutter_riverpod**: State management
- **dio**: HTTP client with interceptors
- **hive**: Local database
- **firebase_core** & **firebase_messaging**: Push notifications
- **go_router**: Navigation
- **socket_io_client**: Real-time messaging

### UI Dependencies

- **cached_network_image**: Image caching
- **image_picker** & **image_cropper**: Media selection
- **flutter_svg**: SVG support
- **shimmer**: Loading animations

### Utilities

- **fpdart**: Functional programming utilities
- **intl**: Internationalization
- **url_launcher**: External link handling
- **path_provider**: File system paths

See `pubspec.yaml` for complete list.

---

## 🔧 Configuration

### API Configuration

Update `lib/core/providers/dio_interceptor.dart` with your backend endpoints.

### Firebase Setup

1. Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
2. Configure FCM in `firebase_options.dart`
3. Update notification handling in `NotificationFCMService`

### Deep Links

Configure deep link schemes in:

- Android: `android/app/src/main/AndroidManifest.xml`
- iOS: `ios/Runner/Info.plist`

---

## 📝 API Endpoints

The app integrates with the following main API routes:

- **Auth**: `/api/auth/*`, `/oauth2/authorize/*`
- **Tweets**: `/api/home/*`, `/api/tweets/*`
- **Users**: `/api/users/*`
- **Chat**: `/api/dm/*`
- **Notifications**: `/api/notifications`
- **Media**: `/api/media/*`
- **Search**: `/api/search/*`
- **Settings**: `/api/settings/*`

Refer to repository implementations for detailed endpoint documentation.

---

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 📞 Support

For issues, questions, or contributions, please:

- Open an issue on GitHub
- Contact the development team
- Check the [Flutter documentation](https://docs.flutter.dev/)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Riverpod for excellent state management
- All open-source contributors

---
