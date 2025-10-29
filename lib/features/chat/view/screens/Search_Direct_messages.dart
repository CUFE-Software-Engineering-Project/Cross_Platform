// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/theme/Palette.dart';

class SearchDirectMessages extends ConsumerStatefulWidget {
  const SearchDirectMessages({super.key});

  @override
  ConsumerState<SearchDirectMessages> createState() =>
      _SearchDirectMessagesState();
}

class _SearchDirectMessagesState extends ConsumerState<SearchDirectMessages> {
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isQueryEmpty = _searchQuery.isEmpty;
    final searchBarHintColor = Colors.grey[400];

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Palette.background,
        appBar: AppBar(
          backgroundColor: Palette.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(color: Palette.textWhite, fontSize: 16),
            cursorColor: Palette.inputBorderFocused,
            decoration: InputDecoration(
              hintText: isQueryEmpty ? 'Search Direct Messages' : '',
              hintStyle: TextStyle(color: searchBarHintColor, fontSize: 16),
              filled: false,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              suffixIcon: isQueryEmpty
                  ? null
                  : IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Palette.inputBorderFocused,
                      ),
                      onPressed: () => _searchController.clear(),
                    ),
            ),
          ),
        ),
        body: Column(
          children: [
            const Divider(color: Color(0xFF38444D), height: 0.5),
            if (!isQueryEmpty)
              Column(
                children: [
                  TabBar(
                    tabAlignment: TabAlignment.start,
                    isScrollable: true,
                    dividerColor: Colors.transparent,
                    indicatorWeight: 1,
                    indicatorColor: Palette.inputBorderFocused,
                    labelColor: Palette.textWhite,
                    unselectedLabelColor: searchBarHintColor,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                    tabs: const [
                      Tab(text: 'All'),
                      Tab(text: 'People'),
                      Tab(text: 'Groups'),
                      Tab(text: 'Messages'),
                    ],
                  ),
                ],
              ),
            const Divider(color: Color(0xFF38444D), height: 0.5),
            Expanded(
              child: isQueryEmpty
                  ? _buildUnsearched(searchBarHintColor!)
                  : _buildSearchResults(_searchQuery),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnsearched(Color hintColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 17.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          'Try searching for people, groups or messages',
          style: TextStyle(color: hintColor, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildSearchResults(String query) {
    return TabBarView(
      children: [
        _buildResultsList(query),
        _buildResultsList(query),
        _buildResultsList(query),
        _buildResultsList(query),
      ],
    );
  }

  Widget _buildResultsList(String query) {
    final bool hasResults = false;

    if (hasResults) {
      return ListView.builder(itemBuilder: (context, index) {});
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            'No results for "$query"',
            textAlign: TextAlign.start,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
