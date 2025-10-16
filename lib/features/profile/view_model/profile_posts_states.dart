import 'package:lite_x/features/profile/models/profile_post_model.dart';

class ProfilePostsStates {
  final bool isLoading;
  final String? errorMessage;
  final List<ProfilePostModel> posts;

  ProfilePostsStates({required this.isLoading, required this.errorMessage, required this.posts});

  factory ProfilePostsStates.initial() {
    return ProfilePostsStates(isLoading: false, errorMessage: null, posts: []);
  }

  ProfilePostsStates copyWith({
    bool? isLoading,
    String? errorMessage,
    List<ProfilePostModel>? posts,
  }) {
    return ProfilePostsStates(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      posts: posts ?? this.posts,
    );
  }


}
