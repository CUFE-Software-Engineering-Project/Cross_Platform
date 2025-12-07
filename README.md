## Localization Setup

- Added `flutter_localizations` and `intl` to `pubspec.yaml`.
- Created `l10n.yaml` to configure Flutter's gen-l10n.
- Added ARB files in `lib/l10n/`:
  - `app_en.arb`
  - `app_ar.arb`
- Wired delegates and supported locales in `lib/main.dart`.

### How to add strings
- Edit ARB files under `lib/l10n/` and add new keys.
- Keep the same keys across languages.

### Generate localization code
- Run:
  
  ```powershell
  flutter gen-l10n
  ```

- Import and use generated `AppLocalizations` in widgets:

  ```dart
  import 'package:lite_x/l10n/app_localizations.dart';

  Text(AppLocalizations.of(context)!.trendsTitle)
  ```

### Switching locales
- By default, the app supports `en` and `ar` and follows system locale.
- You can set a specific locale on `MaterialApp.router` by providing `locale: const Locale('ar')`.
# lite_x

Lite X is a Flutter/Riverpod client for the X-like backend that exposes a complete Tweets API surface. The app now exercises every Tweets Interaction endpoint (create/update/delete, likes, retweets, bookmarks, replies, quotes, mentions, summaries, liked tweets, user timelines, and search) through dedicated repositories, view models, and screens.

## Highlights

- **For You & Following feeds** powered by Riverpod state with cached timeline switching.
- **Full tweet interactions**: like/unlike, bookmark, retweet/undo, reply, quote, delete, and edit.
- **Insights tooling**: per-tweet engagement lists (likes/retweets/quotes/replies) and AI summary cards.
- **Discovery surfaces**: global tweet search, per-user timelines, mentions feed, and liked-tweets feed.
- **Profile drawer shortcuts** to mentions and liked tweets plus expandable FAB for composing posts.

## Requirements

- Flutter 3.22+ with Dart 3.
- A running backend that implements the `/api/tweets/**` endpoints referenced in `lib/features/home/repositories/home_repository.dart`.
- For help getting started with Flutter development, view the
  [online documentation](https://docs.flutter.dev/), which offers tutorials,
  samples, guidance on mobile development, and a full API reference.

## Settings Feature Architecture

The `features/settings` module mirrors the profile feature logic:

- `SettingsModel` holds persisted preference flags (privacy, messaging, ads, data sharing, spaces, muted words).
- `SettingsBasicDataStates` follows the `ProfileBasicDataStates` pattern with `isLoading`, `errorMessage`, and `settingsData`.
- `SettingsBasicDataNotifier` is a Riverpod `StateNotifier` responsible for loading and and updating settings via `SettingsRepo`.
- `settingsBasicDataNotifierProvider` exposes a family provider keyed by username (autoDispose) similar to profile providers.
- Reusable layout widgets extracted: `SettingsResponsiveScaffold` and `SettingsSearchBar` under `view/widgets/` for consistent mobile/web rendering.

Repository interface (`SettingsRepo`) now includes `getSettings` and `updateSettings` alongside blocked/muted account endpoints. Implementation uses placeholder REST paths (`api/settings/<username>`). Adjust endpoints if backend differs.

## Running the app

```powershell
cd "D:\athird_year\1st term\SW\project\v8\Cross_Platform"
flutter pub get
flutter run
```

## Tests

```powershell
flutter test test/widget_test.dart
```

> **Note:** The default Flutter counter test boots a `SplashScreen` without a `ProviderScope`, so it currently fails outside the application shell. Integrate a test-specific `ProviderScope` or replace the template test to make this suite pass.

## Project structure

- `lib/features/home/repositories/home_repository.dart` – strongly typed accessors for every Tweets endpoint (likes, retweets, quotes, replies, summary, search, user feeds, etc.).
- `lib/features/home/view_model` – feed/state management plus new insight providers and tweet editing helpers.
- `lib/features/home/view/screens` – UI screens (timeline, tweet detail, search, engagement lists, liked/mentioned/user feeds).
- `lib/features/home/view/widgets` – shared UI components such as the tweet card, summary panel, and tab bar.

Refer to in-line comments for endpoint-specific handling details.
