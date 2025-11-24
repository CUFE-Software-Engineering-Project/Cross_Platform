# Home Feature Unit Tests

This directory contains comprehensive unit tests for the Home feature of the LiteX application.

## Test Coverage

### Models Tests

#### 1. `tweet_model_test.dart`

Tests for the `TweetModel` class:

- ✅ Creation with required fields
- ✅ Default values
- ✅ `copyWith` functionality
- ✅ Quoted tweet handling
- ✅ Reply relationships
- ✅ Interaction counts (likes, retweets, quotes, bookmarks)
- ✅ Boolean state toggles (isLiked, isRetweeted, isBookmarked)
- ✅ Multiple images handling
- ✅ Different tweet types (TWEET, RETWEET, REPLY, QUOTE)
- ✅ Null optional fields

#### 2. `user_profile_model_test.dart`

Tests for `UserProfileModel` and `MediaModel` classes:

- ✅ MediaModel creation and JSON serialization
- ✅ UserProfileModel creation with all fields
- ✅ Profile and cover media handling
- ✅ Followers/following counts
- ✅ Verified status
- ✅ Protected account status
- ✅ Optional fields as null
- ✅ Join date handling

#### 3. `tweet_summary_test.dart`

Tests for the `TweetSummary` class:

- ✅ Creation with default values
- ✅ Creation with custom values
- ✅ JSON deserialization with standard keys
- ✅ Alternative key name handling (viewCount, likesCount, etc.)
- ✅ Key coalescing logic (multiple key variations)
- ✅ Type conversions (int, double, string to int)
- ✅ Invalid value handling
- ✅ Missing and null key handling
- ✅ Mixed data types
- ✅ Large numbers
- ✅ Zero and negative values

### View Model Tests

#### 3. `home_state_test.dart`

Tests for the `HomeState` class:

- ✅ FeedType enum values (forYou, following)
- ✅ Default state values
- ✅ Custom state values
- ✅ State copying with modifications
- ✅ Loading and error states
- ✅ Refreshing state
- ✅ Feed type switching
- ✅ Separate tweet lists (tweets, forYouTweets, followingTweets)
- ✅ Empty lists handling
- ✅ Feed switching scenarios

#### 4. `home_view_model_test.dart`

Tests for the `HomeViewModel` state management:

- ✅ Tweet like status updates
- ✅ Tweet retweet status updates
- ✅ Tweet bookmark status updates
- ✅ Maintaining separate feed lists
- ✅ Feed switching logic
- ✅ Adding new tweets to feed
- ✅ Error state handling
- ✅ Loading and refreshing states
- ✅ Updating tweets in feed
- ✅ Reply relationships

### Providers Tests

#### 5. `user_profile_provider_test.dart`

Tests for the `UserProfileProvider` and `UserProfileController`:

- ✅ Provider initialization
- ✅ Controller instantiation
- 📝 Note: Full integration tests require mocking Ref and dependencies

### Repositories Tests

#### 6. `home_repository_test.dart`

Tests for the `HomeRepository`:

- ✅ Repository instantiation
- 📝 Note: Comprehensive tests require mocked HTTP responses and would be better suited as integration tests

## Running the Tests

### Run all home feature tests:

```bash
flutter test test/features/home/
```

### Run specific test file:

```bash
flutter test test/features/home/models/tweet_model_test.dart
flutter test test/features/home/models/user_profile_model_test.dart
flutter test test/features/home/models/tweet_summary_test.dart
flutter test test/features/home/view_model/home_state_test.dart
flutter test test/features/home/view_model/home_view_model_test.dart
flutter test test/features/home/providers/user_profile_provider_test.dart
flutter test test/features/home/repositories/home_repository_test.dart
```

### Run with coverage:

```bash
flutter test --coverage test/features/home/
```

### Run in watch mode:

```bash
flutter test --watch test/features/home/
```

## Test Structure

Each test file follows this structure:

1. **Setup**: Helper functions and test data creation
2. **Group Tests**: Organized by functionality
3. **Individual Tests**: Specific behavior validation

## Key Testing Patterns

### Model Testing

- Tests object creation and initialization
- Validates immutability with `copyWith`
- Checks field defaults and nullability
- Verifies serialization/deserialization

### State Testing

- Tests state transitions
- Validates immutability
- Checks default values
- Tests copy operations

### View Model Testing

- Tests business logic
- Validates state updates
- Checks interaction handling
- Tests error scenarios

## Dependencies

Tests use the following packages:

- `flutter_test`: Core testing framework
- `mockito`: For mocking dependencies (future enhancement)

## Future Enhancements

Potential additions to test coverage:

- [ ] Integration tests with repository
- [ ] Widget tests for UI components
- [ ] End-to-end tests for user flows
- [ ] Performance tests for feed loading
- [ ] Mock HTTP responses for repository tests

## Contributing

When adding new tests:

1. Follow the existing naming conventions
2. Group related tests together
3. Add clear test descriptions
4. Include both positive and negative test cases
5. Update this README with new test coverage
