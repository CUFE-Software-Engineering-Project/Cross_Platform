import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/home/models/reposted_by_user_model.dart';
import 'package:lite_x/features/home/repositories/home_repository.dart';
import 'package:lite_x/features/media/view_model/providers.dart';
import 'package:lite_x/features/profile/view/screens/profile_screen.dart';
import 'package:lite_x/features/profile/view_model/providers.dart' as profile;

class RepostedByScreen extends ConsumerStatefulWidget {
  final String tweetId;

  const RepostedByScreen({super.key, required this.tweetId});

  @override
  ConsumerState<RepostedByScreen> createState() => _RepostedByScreenState();
}

class _RepostedByScreenState extends ConsumerState<RepostedByScreen> {
  final ScrollController _scrollController = ScrollController();

  List<RepostedByUserModel> _users = [];
  String? _cursor;
  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || _cursor == null) return;
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoadingInitial = true;
      _isLoadingMore = false;
      _error = null;
      _users = [];
      _cursor = null;
    });

    try {
      final repo = ref.read(homeRepositoryProvider);
      final result = await repo.getRetweets(widget.tweetId, cursor: null);

      if (!mounted) return;
      setState(() {
        _users = result.users;
        _cursor = result.nextCursor;
        _isLoadingInitial = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoadingInitial = false;
      });
    }
  }

  Future<void> _loadMore() async {
    final next = _cursor;
    if (next == null || next.isEmpty) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final repo = ref.read(homeRepositoryProvider);
      final result = await repo.getRetweets(widget.tweetId, cursor: next);

      if (!mounted) return;
      setState(() {
        _users = [..._users, ...result.users];
        _cursor = result.nextCursor;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _openProfile(String username) {
    final normalized = username.startsWith('@')
        ? username.substring(1)
        : username;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProfilePage(username: normalized)),
    );
  }

  Future<void> _toggleFollow(int index) async {
    final user = _users[index];
    final username = user.username.startsWith('@')
        ? user.username.substring(1)
        : user.username;

    // Optimistic update
    setState(() {
      _users = [..._users];
      _users[index] = user.copyWith(isFollowed: !user.isFollowed);
    });

    try {
      if (user.isFollowed) {
        final unfollow = ref.read(profile.unFollowControllerProvider);
        final res = await unfollow(username);
        res.fold((_) => _rollbackFollow(index, user), (_) {});
      } else {
        final follow = ref.read(profile.followControllerProvider);
        final res = await follow(username);
        res.fold((_) => _rollbackFollow(index, user), (_) {});
      }
    } catch (_) {
      _rollbackFollow(index, user);
    }
  }

  void _rollbackFollow(int index, RepostedByUserModel original) {
    if (!mounted) return;
    setState(() {
      _users = [..._users];
      if (index >= 0 && index < _users.length) {
        _users[index] = original;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = _isLoadingInitial
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Failed to load reposts',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _loadInitial,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        : RefreshIndicator(
            onRefresh: _loadInitial,
            child: ListView.separated(
              controller: _scrollController,
              itemCount: _users.length + (_isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFF2F3336)),
              itemBuilder: (context, i) {
                if (i >= _users.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final user = _users[i];
                final mediaUrl = ref.watch(mediaUrlProvider(user.avatarId));
                final avatarUrl = mediaUrl.maybeWhen(
                  data: (res) => res,
                  orElse: () => '',
                );

                return InkWell(
                  onTap: () => _openProfile(user.username),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.grey[900],
                          backgroundImage: avatarUrl.isNotEmpty
                              ? NetworkImage(avatarUrl)
                              : null,
                          child: avatarUrl.isNotEmpty
                              ? null
                              : const Icon(Icons.person, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      user.name.isNotEmpty
                                          ? user.name
                                          : user.username,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (user.verified) ...[
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                  ],
                                  if (user.protectedAccount) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.lock,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.username.startsWith('@')
                                    ? user.username
                                    : '@${user.username}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () => _toggleFollow(i),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: user.isFollowed
                                ? Colors.white
                                : Colors.black,
                            backgroundColor: user.isFollowed
                                ? Colors.transparent
                                : Colors.white,
                            side: user.isFollowed
                                ? BorderSide(color: Colors.grey[700]!, width: 1)
                                : BorderSide.none,
                            shape: const StadiumBorder(),
                          ),
                          child: Text(user.isFollowed ? 'Following' : 'Follow'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Reposted by'),
      ),
      body: body,
    );
  }
}
