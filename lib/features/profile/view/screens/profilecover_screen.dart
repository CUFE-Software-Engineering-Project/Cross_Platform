import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileCoverScreen extends StatelessWidget {
  ProfileCoverScreen({super.key, required this.profilePhotoScreenArgs}) {
    isMe = profilePhotoScreenArgs.isMe;
    profileModel = profilePhotoScreenArgs.profileModel;
  }
  late final ProfileModel profileModel;
  late final bool isMe;
  final ProfilePhotoScreenArgs profilePhotoScreenArgs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            color: Color(0xFF212121),
            onSelected: (value) async {
              switch (value) {
                case 'Share image link':
                  final url = profileModel.bannerUrl;
                  final uri = Uri.parse(
                    url.startsWith('http') ? url : 'https://$url',
                  );

                  Share.share(uri.toString());
                  break;
                case 'Open in browser':
                  final url = profileModel.bannerUrl;
                  final uri = Uri.parse(
                    url.startsWith('http') ? url : 'https://$url',
                  );

                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not open website')),
                      );
                    }
                  }
                  break;
                case 'Save':
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'Share image link',
                child: Row(
                  children: [
                    SizedBox(width: 12),
                    Text(
                      'Share image link',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'Open in browser',
                child: Row(
                  children: [
                    SizedBox(width: 12),
                    Text(
                      'Open in browser',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'Save',
                child: Row(
                  children: [
                    SizedBox(width: 12),
                    Text(
                      'Save',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(width: 12),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(),

          // Container(
          //   width: double.infinity,
          //   // height: 300,
          //   decoration: BoxDecoration(
          //     image: DecorationImage(image: image, fit: BoxFit.cover),
          //   ),
          // ),
          Image(image: NetworkImage(profileModel.bannerUrl)),

          if (isMe)
            OutlinedButton(
              onPressed: () {
                context.pushReplacement(
                  "/editProfile",
                  extra: this.profileModel,
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFADADAD), width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 0,
                ),
              ),
              child: Text(
                'Edit',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
              ),
            ),
          if (!isMe) SizedBox(),
        ],
      ),
    );
  }
}
