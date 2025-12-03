import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/routes/Route_Constants.dart';
import 'package:lite_x/core/theme/palette.dart';
import 'package:lite_x/features/chat/models/usersearchmodel.dart';
import 'package:lite_x/features/chat/providers/searchResultsProvider.dart';
import 'package:lite_x/features/chat/view_model/conversions/Conversations_view_model.dart';

class SearchUserGroup extends ConsumerStatefulWidget {
  const SearchUserGroup({super.key});

  @override
  ConsumerState<SearchUserGroup> createState() => _SearchUserGroupState();
}

class _SearchUserGroupState extends ConsumerState<SearchUserGroup> {
  late final TextEditingController _searchController;
  Timer? _debounce;
  CancelToken? _cancelToken;

  String _searchQuery = '';
  bool _isGrouping = false;

  final List<UserSearchModel> _selectedUsers = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _cancelToken?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final rawQuery = _searchController.text;
    final query = rawQuery.trim();
    if (query == _searchQuery && rawQuery.isNotEmpty) return;

    _searchQuery = query;
    _debounce?.cancel();
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 600), () async {
      if (!mounted) return;
      if (query.isNotEmpty) {
        final users = await ref
            .read(conversationsViewModelProvider.notifier)
            .searchUsers(query);

        ref.read(searchResultsProvider.notifier).state = users;
      } else {
        ref.read(searchResultsProvider.notifier).state = [];
      }
    });
  }

  void _onUserTapped(UserSearchModel user) async {
    if (_isGrouping) {
      setState(() {
        final exists = _selectedUsers.any((u) => u.id == user.id);
        if (exists) {
          _selectedUsers.removeWhere((u) => u.id == user.id);
        } else {
          _selectedUsers.add(user);
        }
      });
    } else {
      final result = await ref
          .read(conversationsViewModelProvider.notifier)
          .createChat(isDMChat: true, recipientIds: [user.id]);
      result.fold((l) => print("Error"), (chatModel) {
        context.pushNamed(
          RouteConstants.ChatScreen,
          pathParameters: {'chatId': chatModel.id},
          extra: {
            'title': user.name,
            'subtitle': "${user.username}",
            'avatarUrl': user.profileMedia,
            'isGroup': false,
            'recipientFollowersCount': user.followers,
          },
        );
      });
    }
  }

  bool isValidHttpUrl(String? url) {
    if (url == null) return false;
    final uri = Uri.tryParse(url);
    return uri != null && (uri.isScheme('http') || uri.isScheme('https'));
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(searchResultsProvider);

    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        title: Text(_isGrouping ? "Create a group" : "Direct Message"),
        backgroundColor: Palette.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: null,
      ),
      body: Column(
        children: [
          const Divider(color: Color(0xFF38444D), height: 0.25),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.search_outlined, size: 30, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: _isGrouping && _selectedUsers.isNotEmpty
                      ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ..._selectedUsers.map((user) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: Chip(
                                    label: Text(
                                      user.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    backgroundColor: Palette.background,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 4.0,
                                    ),
                                    labelPadding: const EdgeInsets.only(
                                      left: 4.0,
                                      right: 4.0,
                                    ),
                                    side: const BorderSide(
                                      color: Palette.textPrimary,
                                      width: 0.25,
                                    ),

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                );
                              }).toList(),
                              SizedBox(
                                width: 150,
                                child: TextField(
                                  controller: _searchController,
                                  autofocus: true,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    filled: false,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            filled: false,
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF38444D), height: 0.2),

          Expanded(
            child: users.isEmpty
                ? Center(
                    child: _searchController.text.isEmpty
                        ? Text(
                            _isGrouping
                                ? 'Search for users to add to group'
                                : 'Search for users',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          )
                        : const Text(
                            'No users found',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                  )
                : ListView.builder(
                    itemExtent: 72.0,
                    itemCount: users.length,
                    itemBuilder: (_, i) {
                      final user = users[i];
                      final isSelected = _selectedUsers.any(
                        (u) => u.id == user.id,
                      );
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF1E2732),

                          backgroundImage: isValidHttpUrl(user.profileMedia)
                              ? CachedNetworkImageProvider(user.profileMedia!)
                              : null,

                          child: !isValidHttpUrl(user.profileMedia)
                              ? const Icon(Icons.person, color: Colors.grey)
                              : null,
                        ),

                        title: Text(
                          user.name,
                          style: const TextStyle(
                            color: Palette.textWhite,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          "@${user.username}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: _isGrouping
                            ? Icon(
                                isSelected ? Icons.check : null,
                                color: Colors.grey[600],
                              )
                            : null,
                        onTap: () => _onUserTapped(user),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
