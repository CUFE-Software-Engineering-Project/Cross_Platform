import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:lite_x/features/trends/view_model/trends_view_model.dart';

class ExploreCategoryTab extends ConsumerWidget {
  const ExploreCategoryTab({
    super.key,
    required this.categoryName,
    required this.pm,
  });
  final String categoryName;
  final ProfileModel pm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exploreCategoryProvider(categoryName));
    final notifier = ref.read(exploreCategoryProvider(categoryName).notifier);

    // Load initial data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.tweets.isEmpty && !state.isLoading && !state.hasError) {
        notifier.loadInitial();
      }
    });

    return _buildContent(state, notifier, context);
  }

  Widget _buildContent(
    ExploreCategoryState state,
    ExploreCategoryNotifier notifier,
    BuildContext context,
  ) {
    // Handle error state
    if (state.hasError && state.tweets.isEmpty) {
      return _buildErrorWidget(notifier);
    }

    // Handle loading initial data
    if (state.tweets.isEmpty && state.isLoading) {
      return _buildLoadingWidget();
    }

    // Handle empty state
    if (state.tweets.isEmpty) {
      return _buildEmptyWidget(notifier);
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollUpdateNotification) {
          final metrics = scrollNotification.metrics;

          // Load more when user is near the bottom (100 pixels from bottom)
          if (metrics.extentAfter < 100 &&
              !state.isLoadingMore &&
              state.nextCursor != null) {
            notifier.loadMore();
          }
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          notifier.refresh();
        },
        child: ListView.separated(
          cacheExtent: 2000,
          itemCount: state.tweets.length + (state.nextCursor != null ? 1 : 0),
          itemBuilder: (context, index) {
            // Show loading indicator at the bottom if there's more data
            if (index == state.tweets.length) {
              return _buildLoadMoreWidget(state, notifier);
            }

            final post = state.tweets[index];
            return getCorrectTweetType(post, pm);
          },
          separatorBuilder: (context, index) {
            // Don't show separator before loading indicator
            if (index >= state.tweets.length - 1) {
              return const SizedBox();
            }
            return Container(
              width: double.infinity,
              height: 0.5,
              color: Colors.grey,
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorWidget(ExploreCategoryNotifier notifier) {
    return ListView(
      padding: EdgeInsets.only(top: 50),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        Center(child: Text("Failed to load tweets")),
        Center(
          child: IconButton(
            onPressed: () => notifier.loadInitial(),
            icon: Icon(Icons.refresh),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEmptyWidget(ExploreCategoryNotifier notifier) {
    return RefreshIndicator(
      onRefresh: () async {
        notifier.refresh();
      },
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              "Nothing to see here -- yet.",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreWidget(
    ExploreCategoryState state,
    ExploreCategoryNotifier notifier,
  ) {
    if (state.isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.hasError) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Failed to load more",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: TextButton(
              onPressed: () => notifier.loadMore(),
              child: Text("Retry"),
            ),
          ),
        ],
      );
    }

    return const SizedBox(); // Empty widget
  }
}
