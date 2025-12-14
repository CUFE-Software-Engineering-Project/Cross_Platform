import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/features/search/providers/search_providers.dart';
import 'package:lite_x/features/search/view/search_results_screen.dart';
import 'package:lite_x/features/search/view/widgets/search_bar.dart';
import 'package:lite_x/features/search/view/widgets/people_card.dart';
import 'package:lite_x/features/profile/models/shared.dart';


class SearchScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extra;

  const SearchScreen({super.key, this.extra});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Timer? _debounce;
  String _query = '';
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    final extra = widget.extra;
    _query = (extra?['query'] as String?) ?? '';
    _showResults = (extra?['showResults'] as bool?) ?? false;
    _controller = TextEditingController(text: _query);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _query = value;
      });
    });
  }

  void _onSubmitted(String q) {
    final trimmed = q.trim();
    if (trimmed.isEmpty) return;
    ref.read(searchHistoryProvider.notifier).add(trimmed);
    context.pushNamed(
      RouteConstants.SearchScreen,
      extra: <String, dynamic>{
        'query': trimmed,
        'showResults': true,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showResults && _query.trim().isNotEmpty) {
      return SearchResultsScreen(initialQuery: _query);
    }

    final history = ref.watch(searchHistoryProvider);
    final trimmedQuery = _query.trim();
    final hasQuery = trimmedQuery.isNotEmpty;

    return Scaffold(
      appBar: AppSearchBar(
        initialText: _query,
        onSubmitted: _onSubmitted,
        onChanged: _onQueryChanged,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1, color: Palette.divider),
          if (!hasQuery) ...[
            if (history.isEmpty)
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Try searching for people, lists, or keywords',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
            else ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent searches',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          ref.read(searchHistoryProvider.notifier).clear(),
                      child: const Text('Clear all'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    final isUser = item.startsWith('@') && item.length > 1;

                    if (!isUser) {
                      // Keyword/text recent — keep existing simple style
                      return ListTile(
                        leading:
                            const Icon(Icons.history, color: Palette.icons),
                        title: Text(item),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => ref
                              .read(searchHistoryProvider.notifier)
                              .remove(item),
                        ),
                        onTap: () {
                          _onSubmitted(item);
                        },
                      );
                    }

                    // User recent: show avatar, name, and @username like search results
                    final username = item.substring(1);
                    final usersAsync =
                        ref.watch(suggestionsProvider(username));

                    return usersAsync.when(
                      data: (users) {
                        if (users.isEmpty) {
                          // Fallback to simple tile if no user found
                          return ListTile(
                            leading: const Icon(Icons.history,
                                color: Palette.icons),
                            title: Text(item),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => ref
                                  .read(searchHistoryProvider.notifier)
                                  .remove(item),
                            ),
                            onTap: () {
                              _onSubmitted(item);
                            },
                          );
                        }

                        // Prefer an exact username match if available
                        final lower = username.toLowerCase();
                        final user = users.firstWhere(
                          (u) => u.userName.toLowerCase() == lower,
                          orElse: () => users.first,
                        );

                        return ListTile(
                          leading: ClipOval(
              child: SizedBox(
                width: 40,
                height: 40,
                child: BuildSmallProfileImage(
                  mediaId: user.avatarUrl,
                  radius: 20,
                ),
              ),
            ),
                          title: Text(
                            user.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Palette.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            '@${user.userName}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Palette.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => ref
                                .read(searchHistoryProvider.notifier)
                                .remove(item),
                          ),
                          onTap: () {
                            context.push(
                                '/profilescreen/${user.userName}');
                          },
                        );
                      },
                      loading: () => ListTile(
                        leading: const Icon(Icons.history, color: Palette.icons),
                        title: Text(item),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => ref
                              .read(searchHistoryProvider.notifier)
                              .remove(item),
                        ),
                        onTap: () {
                          _onSubmitted(item);
                        },
                      ),
                      error: (e, s) => ListTile(
                        leading: const Icon(Icons.history, color: Palette.icons),
                        title: Text(item),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => ref
                              .read(searchHistoryProvider.notifier)
                              .remove(item),
                        ),
                        onTap: () {
                          _onSubmitted(item);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ]
          else ...[
            Expanded(
              child: ref.watch(suggestionsProvider(trimmedQuery)).when(
                    data: (users) {
                      if (users.isEmpty) {
                        return ListTile(
                          title: TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero, // removes extra padding
                              alignment: Alignment.centerLeft, // aligns like normal list item
                            ),
                            onPressed: () {
                              _onSubmitted(trimmedQuery);
                            },
                            child: Text(
                              'Search for "$trimmedQuery"',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return PeopleCard(
                            user: user,
                            onTap: () {
                              ref
                                  .read(searchHistoryProvider.notifier)
                                  .add('@${user.userName}');
                              context.push('/profilescreen/${user.userName}');
                            },
                            showFollowButton: false,
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (e, s) => const Center(
                      child: Text(
                        'Something went wrong. Please try again.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
