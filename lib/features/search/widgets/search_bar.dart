import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/search_view_model.dart';

class SearchBar extends ConsumerWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        const CircleAvatar(
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=10'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search',
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
            onChanged: (value) {
              ref.read(searchViewModelProvider.notifier).search(value);
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {},
        ),
      ],
    );
  }
}
