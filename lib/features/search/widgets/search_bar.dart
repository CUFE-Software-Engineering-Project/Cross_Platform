import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/search_view_model.dart';
import 'package:lite_x/core/theme/palette.dart';

class SearchBar extends ConsumerWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Back arrow button
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),

        const SizedBox(width: 8),

        // Search input field
        Expanded(
          child: SizedBox(
            height: 48,
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search',
                hintStyle: const TextStyle(color: Palette.textSecondary),
                filled: true,
                fillColor: Palette.background,
                
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Palette.textSecondary,
                    width: 0.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Palette.textSecondary,
                    width: 0.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Palette.primary,
                    width: 2,
                  ),
                ),

                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
              onChanged: (value) {
                ref.read(searchViewModelProvider.notifier).search(value);
              },
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Settings button
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {},
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
      ],
    );
  }
}
