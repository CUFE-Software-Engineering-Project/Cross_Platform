  import 'package:flutter/material.dart';
  import '../models/search_result_model.dart';

  class SearchResultsList extends StatelessWidget {
    final List<SearchResultModel> results;
    const SearchResultsList({super.key, required this.results});

    @override
    Widget build(BuildContext context) {
      return ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: results.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final user = results[index];
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
            onTap: () {},
          );
        },
      );
    }
  }
