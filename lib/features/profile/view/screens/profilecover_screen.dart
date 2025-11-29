import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/features/media/view_model/providers.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileCoverScreen extends ConsumerWidget {
  ProfileCoverScreen({super.key, required this.profilePhotoScreenArgs}) {
    isMe = profilePhotoScreenArgs.isMe;
    profileModel = profilePhotoScreenArgs.profileModel;
  }
  late final ProfileModel profileModel;
  late final bool isMe;
  final ProfilePhotoScreenArgs profilePhotoScreenArgs;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaUrl = ref.watch(mediaUrlProvider(profileModel.bannerId));
    return mediaUrl.when(
      data: (data) {
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
                      // Handle share
                      final String url = data.isNotEmpty ? data : "";
                      final uri = Uri.parse(
                        url.startsWith('http') ? url : 'https://$url',
                      );

                      Share.share(uri.toString());
                      break;
                    case 'Open in browser':
                      final url = data.isNotEmpty ? data : "";
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
                      // Handle block
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
              SizedBox(width: double.infinity),

              CachedNetworkImage(
                imageUrl: data.isNotEmpty ? data : "",
                errorWidget: (context, url, error) => CachedNetworkImage(
                  imageUrl: unkownUserAvatar,
                  errorWidget: (context, url, error) =>
                      SizedBox(width: double.infinity),
                ),
              ),

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
      },
      error: (err, _) {
        return Scaffold(
          appBar: AppBar(
            leading: BackButton(
              onPressed: () {
                if (context.canPop()) context.pop();
              },
            ),
          ),
          body: Center(child: Text("can't load profile image...")),
        );
      },
      loading: () {
        return Scaffold(
          appBar: AppBar(
            leading: BackButton(
              onPressed: () {
                if (context.canPop()) context.pop();
              },
            ),
          ),
          body: Center(child: CircularProgressIndicator(color: Colors.white)),
        );
      },
    );
  }
}
