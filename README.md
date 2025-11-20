# lite_x

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Settings Feature Architecture

The `features/settings` module mirrors the profile feature logic:

- `SettingsModel` holds persisted preference flags (privacy, messaging, ads, data sharing, spaces, muted words).
- `SettingsBasicDataStates` follows the `ProfileBasicDataStates` pattern with `isLoading`, `errorMessage`, and `settingsData`.
- `SettingsBasicDataNotifier` is a Riverpod `StateNotifier` responsible for loading and updating settings via `SettingsRepo`.
- `settingsBasicDataNotifierProvider` exposes a family provider keyed by username (autoDispose) similar to profile providers.
- Reusable layout widgets extracted: `SettingsResponsiveScaffold` and `SettingsSearchBar` under `view/widgets/` for consistent mobile/web rendering.

Repository interface (`SettingsRepo`) now includes `getSettings` and `updateSettings` alongside blocked/muted account endpoints. Implementation uses placeholder REST paths (`api/settings/<username>`). Adjust endpoints if backend differs.
