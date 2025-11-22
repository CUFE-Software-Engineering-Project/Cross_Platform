import 'package:flutter_riverpod/legacy.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/settings/repositories/settings_repo.dart';

class MutedUsersState {
  final List<UserModel> users;
  final bool isLoading;
  final bool isLoadingMore;
  final String? nextCursor;
  final bool hasMore;
  final String? errorMessage;

  const MutedUsersState({
    required this.users,
    required this.isLoading,
    required this.isLoadingMore,
    required this.nextCursor,
    required this.hasMore,
    required this.errorMessage,
  });

  MutedUsersState copyWith({
    List<UserModel>? users,
    bool? isLoading,
    bool? isLoadingMore,
    String? nextCursor,
    bool? hasMore,
    String? errorMessage,
  }) {
    return MutedUsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  factory MutedUsersState.initial() => const MutedUsersState(
        users: [],
        isLoading: false,
        isLoadingMore: false,
        nextCursor: null,
        hasMore: false,
        errorMessage: null,
      );
}

class MutedUsersNotifier extends StateNotifier<MutedUsersState> {
  final SettingsRepo settingsRepo;
  final int pageSize;

  MutedUsersNotifier({required this.settingsRepo, this.pageSize = 30}) : super(MutedUsersState.initial()) {
    fetchInitial();
  }

  Future<void> fetchInitial() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await settingsRepo.fetchMutedAccounts(limit: pageSize);
    result.fold((failure) {
      state = state.copyWith(isLoading: false, errorMessage: failure.message);
    }, (resp) {
      state = state.copyWith(
        isLoading: false,
        users: resp.users,
        nextCursor: resp.nextCursor,
        hasMore: resp.hasMore,
        errorMessage: null,
      );
    });
  }

  Future<void> refresh() async {
    await fetchInitial();
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.nextCursor == null) return;
    state = state.copyWith(isLoadingMore: true, errorMessage: null);
    final result = await settingsRepo.fetchMutedAccounts(limit: pageSize, cursor: state.nextCursor);
    result.fold((failure) {
      state = state.copyWith(isLoadingMore: false, errorMessage: failure.message);
    }, (resp) {
      final combined = List<UserModel>.from(state.users)..addAll(resp.users);
      state = state.copyWith(
        isLoadingMore: false,
        users: combined,
        nextCursor: resp.nextCursor,
        hasMore: resp.hasMore,
        errorMessage: null,
      );
    });
  }
}
