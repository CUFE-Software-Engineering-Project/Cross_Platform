import 'package:flutter/material.dart';
import 'package:lite_x/core/theme/Palette.dart';
import '../view_model/explore_state.dart';

class CategoryTabs extends StatelessWidget {
  final ExploreCategory selectedCategory;
  final Function(ExploreCategory) onCategorySelected;

  const CategoryTabs({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      ExploreCategory.forYou,
      ExploreCategory.trending,
      ExploreCategory.news,
      ExploreCategory.entertainment,
      ExploreCategory.sports,
    ];

    final categoryLabels = {
      ExploreCategory.forYou: 'For You',
      ExploreCategory.trending: 'Trending',
      ExploreCategory.news: 'News',
      ExploreCategory.entertainment: 'Entertainment',
      ExploreCategory.sports: 'Sports',
    };

    return Container(
      decoration: BoxDecoration(
        color: Palette.background,
        border: Border(bottom: BorderSide(color: Palette.divider, width: 1)),
      ),
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: categories.map((category) {
            final isSelected = category == selectedCategory;

            return Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onCategorySelected(category),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          categoryLabels[category]!,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Palette.textPrimary
                                : Palette.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 3,
                          width: isSelected ? 30 : 0,
                          decoration: BoxDecoration(
                            color: Palette.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
