import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/features/profile/models/search_user_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

class ProfileSearchScreen extends ConsumerStatefulWidget {
  const ProfileSearchScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ProfileSearchScreenState();
}

class _ProfileSearchScreenState extends ConsumerState<ProfileSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');
  final _debounceTimer = ValueNotifier<Timer?>(null);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
  }

  void _onSearchTextChanged() {
    // Debounce search to avoid too many rebuilds
    _debounceTimer.value?.cancel();
    _debounceTimer.value = Timer(const Duration(milliseconds: 300), () {
      _searchQuery.value = _searchController.text.trim();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchQuery.value = '';
    _searchFocusNode.requestFocus();
  }

  void _navigateBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(RouteConstants.homescreen);
    }
  }

  @override
  void dispose() {
    _debounceTimer.value?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchQuery.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: BackButton(onPressed: _navigateBack),
            titleSpacing: 0,
            title: TextFormField(
              focusNode: _searchFocusNode,
              autofocus: true,
              controller: _searchController,
              cursorColor: Colors.blue,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(right: 20),
                border: InputBorder.none,
                fillColor: Colors.transparent,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: "Search X",
                hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            actions: [
              const SizedBox(width: 10),
              ValueListenableBuilder<String>(
                valueListenable: _searchQuery,
                builder: (context, searchText, child) {
                  final hasText = searchText.isNotEmpty;
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: hasText
                        ? IconButton(
                            key: const ValueKey('clear-button'),
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: _clearSearch,
                          )
                        : const SizedBox.shrink(key: ValueKey('empty')),
                  );
                },
              ),
            ],
          ),
          const SliverToBoxAdapter(
            child: Divider(height: 1, color: Colors.grey),
          ),
          ValueListenableBuilder<String>(
            valueListenable: _searchQuery,
            builder: (context, searchQuery, child) {
              return SliverFillRemaining(
                hasScrollBody: true,
                child: ProfileSearchResults(searchQuery: searchQuery),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SearchUserTile extends StatelessWidget {
  const SearchUserTile({super.key, required this.user});
  final SearchUserModel user;

  void _navigateToProfile(BuildContext context) {
    context.push("/profilescreen/${user.username}");
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => _navigateToProfile(context),
      horizontalTitleGap: 10,
      enableFeedback: true,
      leading: BuildSmallProfileImage(mediaId: user.profileMediaId),
      title: Text(
        user.name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      subtitle: Text(
        "@${user.username}",
        style: const TextStyle(color: Colors.grey, fontSize: 14),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}

class SearchUsersList extends StatelessWidget {
  const SearchUsersList({super.key, required this.users});
  final List<SearchUserModel> users;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: users.length,
      itemBuilder: (context, index) {
        return SearchUserTile(user: users[index]);
      },
    );
  }
}

class ProfileSearchResults extends ConsumerWidget {
  const ProfileSearchResults({super.key, required this.searchQuery});
  final String searchQuery;

  void _refreshSearch(WidgetRef ref) {
    ref.invalidate(profileCurrentSearchProvider(searchQuery));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (searchQuery.isEmpty) {
      return const SearchUsersList(users: []);
    }

    final asyncUsers = ref.watch(profileCurrentSearchProvider(searchQuery));

    return asyncUsers.when(
      data: (either) {
        return either.fold(
          (failure) {
            return RefreshIndicator(
              onRefresh: () async => _refreshSearch(ref),
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    child: Center(
                      child: Text(failure.message, textAlign: TextAlign.center),
                    ),
                  ),
                ],
              ),
            );
          },
          (users) {
            if (users.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () {
                    // TODO: implement search result navigation
                  },
                  child: Text(
                    "Search for @$searchQuery",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            }
            return SearchUsersList(users: users);
          },
        );
      },
      error: (error, stackTrace) {
        return RefreshIndicator(
          onRefresh: () async => _refreshSearch(ref),
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "An error occurred: ${error.toString()}",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
