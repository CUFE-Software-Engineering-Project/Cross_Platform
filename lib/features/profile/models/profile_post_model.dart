import '../../../core/models/usermodel.dart';

class ProfilePostModel {
  final String id;
  final String text;
  final String timeAgo;
  final int likes;
  final int retweets;
  final int replies;
  final int activityNumber;
  final bool isLiked;
  final List<dynamic> mediaUrls;

  ProfilePostModel({
    required this.id,
    required this.text,
    required this.timeAgo,
    required this.likes,
    required this.retweets,
    required this.replies,
    required this.isLiked,
    required this.activityNumber,
    required this.mediaUrls,
  });

  factory ProfilePostModel.fromJson(Map<String, dynamic> json) {
    return ProfilePostModel(
      id: json['id']??"",
      text: json['text']??"",
      timeAgo: json['timeAgo']??"",
      likes: json['likes']??0,
      retweets: json['retweets']??0,
      replies: json['replies']??0,
      isLiked: json['isLiked']??false,
      activityNumber: json['activityNumber']??0,
      mediaUrls: json['mediaUrls']?? [],
    );
  }
// ------------------------------------------
}