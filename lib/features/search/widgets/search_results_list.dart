import 'package:flutter/material.dart';
import '../models/search_result_model.dart';
import 'package:lite_x/core/theme/palette.dart';

class SearchResultsList extends StatelessWidget {
  final List<SearchResultModel> results;

  const SearchResultsList({
    super.key,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      cacheExtent: 500,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      itemCount: results.length,
      itemBuilder: (context, index) {
        final user = results[index];

        return GestureDetector(
  onTap: () {},
  behavior: HitTestBehavior.opaque, // still responds to taps
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(user.avatarUrl ?? ''),
          radius: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      user.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Palette.textWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (user.isVerified) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.check_circle,
                        size: 16, color: Colors.blue),
                  ],
                ],
              ),
              Text(
                user.username,
                style: const TextStyle(fontSize: 15, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  ),
);

      },
    );
  }
}
