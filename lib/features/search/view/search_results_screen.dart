import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/features/search/data/search_repository.dart';
import 'package:lite_x/features/search/providers/search_providers.dart';
import 'package:lite_x/features/search/view/widgets/error_retry.dart';
import 'package:lite_x/features/search/view/widgets/people_card.dart';
import 'package:lite_x/features/search/view/widgets/search_bar.dart';
import 'package:lite_x/features/search/view/widgets/tweet_card.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  final String initialQuery;
  const SearchResultsScreen({super.key, required this.initialQuery});

  @override
  ConsumerState<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> with SingleTickerProviderStateMixin {
  late TabController _controller;
  final _tabs = ['Top', 'Latest', 'People', 'Media'];

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  SearchTab _tabForIndex(int idx) {
    switch (idx) {
      case 1:
        return SearchTab.LATEST;
      case 2:
        return SearchTab.PEOPLE;
      case 3:
        return SearchTab.MEDIA;
      case 0:
      default:
        return SearchTab.TOP;
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = widget.initialQuery;
    return Scaffold(
      appBar: AppSearchBar(
        initialText: query,
        onSubmitted: (q) {
          // Only add to history on submit; tapping the field handles navigation.
          ref.read(searchHistoryProvider.notifier).add(q);
        },
        onTap: () {
          context.pushNamed(
            RouteConstants.SearchScreen,
            extra: <String, dynamic>{
              'query': query,
              'showResults': false,
            },
          );
        },
        trailingIcon: Icons.more_horiz,
        bottom: TabBar(
          controller: _controller,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(width: 4, color: Colors.blue),
            insets: EdgeInsets.symmetric(horizontal: 50),
          ),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      
      body: TabBarView(controller: _controller, 
      children: List.generate(_tabs.length, (index) {
        final tab = _tabForIndex(index);
        return _TabContent(query: query, tab: tab);
      })),
    );
  }
}

class _TabContent extends ConsumerWidget {
  final String query;
  final SearchTab tab;
  const _TabContent({required this.query, required this.tab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tab == SearchTab.PEOPLE) {
      final usersAsync = ref.watch(suggestionsProvider(query));
      return usersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return _buildEmptyResultsMessage(query);
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (c, i) {
              final user = users[i];
              return PeopleCard(
                user: user,
                onTap: () {
                  ref
                      .read(searchHistoryProvider.notifier)
                      .add('@${user.userName}');
                  context.push('/profilescreen/${user.userName}');
                },
                onFollowTap: () async {
                  if (user.isFollowing) {
                    final unfollow = ref.read(unFollowControllerProvider);
                    await unfollow(user.userName);
                  } else {
                    final follow = ref.read(followControllerProvider);
                    await follow(user.userName);
                  }
                  // ignore: unused_result
                  ref.refresh(suggestionsProvider(query));
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => ErrorRetry(
          message: 'Failed to load users — try reloading',
          onRetry: () => ref.refresh(suggestionsProvider(query)),
        ),
      );
    }

    final notifier = ref.watch(
      searchResultsProvider(SearchParams(query: query, tab: tab)),
    );

    if (notifier.isLoading && notifier.tweets.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (notifier.error != null && notifier.tweets.isEmpty) {
      return ErrorRetry(
        message: 'Something went wrong — try reloading',
        onRetry: () => ref.read(searchResultsProvider(SearchParams(query: query, tab: tab)).notifier).refresh(),
      );
    }

    final isTopTab = tab == SearchTab.TOP;

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
          if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
          ref.read(searchResultsProvider(SearchParams(query: query, tab: tab)).notifier).loadNextPage();
        }
        return false;
      },
      child: Builder(
        builder: (context) {
          if (!isTopTab) {
            if (notifier.tweets.isEmpty) {
              return _buildEmptyResultsMessage(query);
            }
            final int itemCount =
                notifier.tweets.length + (notifier.isLoadingMore ? 1 : 0);
            return ListView.builder(
              itemCount: itemCount,
              itemBuilder: (context, index) {
                if (index >= notifier.tweets.length) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final tw = notifier.tweets[index];
                return TweetCardWidget(
                  tweet: tw,
                  onLike: (id) => ref
                      .read(searchResultsProvider(SearchParams(query: query, tab: tab)).notifier)
                      .toggleLike(id),
                );
              },
            );
          }

          final usersAsync = ref.watch(suggestionsProvider(query));

          return usersAsync.when(
            data: (users) {
              final topUsers = users.length > 4 ? users.sublist(0, 4) : users;

              if (topUsers.isEmpty && notifier.tweets.isEmpty) {
                return _buildEmptyResultsMessage(query);
              }

              final int itemCount = topUsers.length +
                  notifier.tweets.length +
                  (notifier.isLoadingMore ? 1 : 0);

              return ListView.builder(
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  if (index < topUsers.length) {
                    final user = topUsers[index];
                    return PeopleCard(
                      user: user,
                      onTap: () {
                        ref
                            .read(searchHistoryProvider.notifier)
                            .add('@${user.userName}');
                        context.push('/profilescreen/${user.userName}');
                      },
                      onFollowTap: () async {
                        if (user.isFollowing) {
                          final unfollow = ref.read(unFollowControllerProvider);
                          await unfollow(user.userName);
                        } else {
                          final follow = ref.read(followControllerProvider);
                          await follow(user.userName);
                        }
                        // ignore: unused_result
                        ref.refresh(suggestionsProvider(query));
                      },
                    );
                  }

                  final int tweetIndex = index - topUsers.length;
                  if (tweetIndex >= notifier.tweets.length) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final tw = notifier.tweets[tweetIndex];
                  return TweetCardWidget(
                    tweet: tw,
                    onLike: (id) => ref
                        .read(searchResultsProvider(SearchParams(query: query, tab: tab)).notifier)
                        .toggleLike(id),
                  );
                },
              );
            },
            loading: () {
              // While users load, just show tweets list
              final int itemCount =
                  notifier.tweets.length + (notifier.isLoadingMore ? 1 : 0);
              return ListView.builder(
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  if (index >= notifier.tweets.length) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final tw = notifier.tweets[index];
                  return TweetCardWidget(
                    tweet: tw,
                    onLike: (id) => ref
                        .read(searchResultsProvider(SearchParams(query: query, tab: tab)).notifier)
                        .toggleLike(id),
                  );
                },
              );
            },
            error: (_, __) {
              // On error fetching users, still show tweets list
              final int itemCount =
                  notifier.tweets.length + (notifier.isLoadingMore ? 1 : 0);
              return ListView.builder(
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  if (index >= notifier.tweets.length) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final tw = notifier.tweets[index];
                  return TweetCardWidget(
                    tweet: tw,
                    onLike: (id) => ref
                        .read(searchResultsProvider(SearchParams(query: query, tab: tab)).notifier)
                        .toggleLike(id),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

Widget _buildEmptyResultsMessage(String query) {
  return Padding(
    padding: const EdgeInsets.only(top: 28.0),
    child: Align(
      alignment: Alignment.topCenter, // box is horizontally centered
      child: SizedBox(
        width: 336,
        // optional height; use mainAxisSize.min if you want auto height
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // text centered inside box
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No results for "$query"',
              style: const TextStyle(
                fontSize: 31,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Try searching for something else, or check your search settings to see if they’re protecting you from potentially sensitive content.',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}









}
