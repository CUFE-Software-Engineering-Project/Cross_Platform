import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/search_bar.dart' as sb;
import '../widgets/search_results_list.dart';
import '../widgets/search_history_list.dart';
import '../view_model/search_view_model.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchViewModelProvider);

    return Scaffold(
      body: Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: sb.SearchBar(),
        ),
        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.results.isNotEmpty
                  ? SearchResultsList(results: state.results)
                  : state.history.isNotEmpty
                      ? SearchHistoryList(history: state.history)
                      : const Text('Try searching for people, lists, or keywords'),
        ),
      ],
    ),
    );
  }
}
