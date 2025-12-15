# Profile Feature Tests

This directory contains comprehensive tests for the profile feature using Flutter test framework and Mockito for mocking.

## Test Structure

```
test/features/profile/
├── models/                      # Model tests (flutter_test only)
│   ├── profile_model_test.dart
│   └── follower_model_test.dart
├── repositories/                # Repository tests (with Mockito)
│   ├── profile_repo_impl_test.dart
│   └── profile_repo_impl_test.mocks.dart
└── view_model/                  # Provider tests (with Mockito)
    ├── providers_test.dart
    └── providers_test.mocks.dart
```

## Test Coverage

### Models Tests
- **profile_model_test.dart**: Tests for ProfileModel serialization, deserialization, copyWith, and helper functions
- **follower_model_test.dart**: Tests for FollowerModel JSON conversion, copyWith, and factory methods

### Repository Tests
- **profile_repo_impl_test.dart**: Tests for ProfileRepoImpl including:
  - Profile data retrieval
  - Profile updates
  - Follow/unfollow operations
  - Block/unblock/mute operations
  - Tweet interactions (like, unlike, etc.)
  - Banner and photo updates

### Provider Tests
- **providers_test.dart**: Tests for Riverpod providers including:
  - profileDataProvider
  - followersProvider / followingsProvider
  - followControllerProvider / unFollowControllerProvider
  - blockUserProvider / unBlockUserProvider
  - muteUserProvider / unMuteUserProvider
  - Tweet interaction providers
  - Profile edit provider

## Running Tests

### Run all profile tests
```bash
flutter test test/features/profile/
```

### Run specific test file
```bash
flutter test test/features/profile/models/profile_model_test.dart
```

### Run with coverage
```bash
flutter test --coverage test/features/profile/
```

## Generating Mock Files

The repository and provider tests use Mockito for mocking dependencies. Mock files are generated using the `build_runner` package.

### Generate mocks for all tests
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Generate mocks and watch for changes
```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Clean and rebuild
```bash
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

## Mock Annotations

### Repository Tests
```dart
@GenerateMocks([Dio])
```
Generates: `profile_repo_impl_test.mocks.dart` with `MockDio`

### Provider Tests
```dart
@GenerateMocks([ProfileRepo])
```
Generates: `providers_test.mocks.dart` with `MockProfileRepo`

## Test Patterns

### Model Tests (No Mocks)
```dart
test('should create ProfileModel from valid JSON', () {
  // Arrange
  final json = {...};
  
  // Act
  final result = ProfileModel.fromJson(json);
  
  // Assert
  expect(result.username, 'testuser');
});
```

### Repository Tests (With Mockito)
```dart
test('should return ProfileModel when API call succeeds', () async {
  // Arrange
  when(mockDio.get('api/users/$testUsername')).thenAnswer(
    (_) async => Response(data: testData, statusCode: 200, ...),
  );
  
  // Act
  final result = await repository.getProfileData(testUsername, currentUsername);
  
  // Assert
  expect(result.isRight(), true);
  verify(mockDio.get('api/users/$testUsername')).called(1);
});
```

### Provider Tests (With Mockito + Riverpod)
```dart
test('should return profile data when repository succeeds', () async {
  // Arrange
  when(mockRepo.getProfileData(username, currentUsername))
      .thenAnswer((_) async => Right(testProfile));
      
  container = ProviderContainer(
    overrides: [
      profileRepoProvider.overrideWithValue(mockRepo),
    ],
  );
  
  // Act
  final result = await container.read(profileDataProvider(username).future);
  
  // Assert
  result.fold(
    (failure) => fail('Should return Right'),
    (profile) => expect(profile.username, username),
  );
});
```

## Dependencies

Ensure these packages are in your `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  build_runner: ^2.4.0
```

## Best Practices

1. **Use descriptive test names**: Test names should clearly describe what is being tested
2. **Follow AAA pattern**: Arrange, Act, Assert
3. **Test edge cases**: Include tests for null values, empty lists, error conditions
4. **Verify mock calls**: Always verify that mocked methods are called as expected
5. **Clean up**: Use `setUp()` and `tearDown()` to initialize and dispose resources
6. **Test isolation**: Each test should be independent and not rely on other tests

## Troubleshooting

### Mock files not generated
- Ensure `@GenerateMocks` annotations are present
- Run `dart run build_runner clean` then rebuild
- Check that mockito and build_runner are in dev_dependencies

### Tests failing due to missing mocks
- Run the build_runner to generate mock files
- Import the generated `.mocks.dart` file

### Provider tests failing
- Ensure ProviderContainer is disposed in tearDown
- Override all required providers in the test
- Check that async operations are properly awaited
