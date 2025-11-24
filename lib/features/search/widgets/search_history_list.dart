import 'package:flutter/material.dart';
import '../models/search_result_model.dart';

class SearchHistoryList extends StatelessWidget {
  final List<SearchResultModel> history;
  const SearchHistoryList({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(
        child: Text('Try searching for people, lists, or keywords'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      cacheExtent: 500,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      itemCount: history.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final user = history[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user.avatarUrl ?? ''),
          ),
          title: Row(
            children: [
              Text(user.name),
              if (user.isVerified) ...[
                const SizedBox(width: 4),
                const Icon(Icons.check_circle, size: 16, color: Colors.blue),
              ],
            ],
          ),
          subtitle: Text(user.username),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              // Call ViewModel to delete from history
            },
          ),
          onTap: () {},
        );
      },
    );
  }
}
