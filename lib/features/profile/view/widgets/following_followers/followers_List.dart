import 'package:flutter/material.dart';
import 'package:lite_x/features/profile/models/user_model.dart';
import 'package:lite_x/features/profile/view/widgets/following_followers/follower_card.dart';

class FollowerList extends StatelessWidget {
  final List<UserModel> users;
  final bool isMe;

  const FollowerList({Key? key, required this.users, required this.isMe})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return users.isNotEmpty
        ? ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              return FollowerCard(user: users[index], isMe: isMe);
            },
          )
        : ListView(
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
          );
  }
}
