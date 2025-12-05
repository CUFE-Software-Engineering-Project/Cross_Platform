import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/core/providers/current_user_provider.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/profile_tweet_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view/widgets/profile_tweets/shared_tweet_components.dart';
import 'package:lite_x/features/profile/view_model/providers.dart';
import 'package:readmore/readmore.dart';

class ProfileNormarTweetQuot extends ConsumerWidget implements ProfileTweet {
  const ProfileNormarTweetQuot({
    required this.profileModel,
    required this.profilePostModel,
  });
  final ProfileModel profileModel;
  final ProfileTweetModel profilePostModel;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BasicTweetWidget(
      profileModel: profileModel,
      profilePostModel: profilePostModel,
      withActions: false,
    );
  }
}
