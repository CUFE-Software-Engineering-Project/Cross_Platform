import 'package:lite_x/features/profile/models/follower_model.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/trends/models/trend_category.dart';

class ForYouResponseModel {
  final List<TrendCategory> categories;
  final List<UserModel> suggestedUsers;

  ForYouResponseModel({required this.categories, required this.suggestedUsers});
}



