// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:go_router/go_router.dart';
// import 'package:lite_x/features/profile/models/profile_model.dart';
// import 'package:lite_x/features/profile/models/shared.dart';
// import 'package:lite_x/features/profile/view/widgets/profile/block_button.dart';
// import 'package:lite_x/features/profile/view/widgets/profile/follow_following_button.dart';
// import 'package:lite_x/features/profile/view/widgets/profile/top_icon.dart';
// import 'package:lite_x/features/profile/view_model/providers.dart';
// import 'package:top_snackbar_flutter/custom_snack_bar.dart';
// import 'package:top_snackbar_flutter/top_snack_bar.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// class ProfileHeader extends ConsumerStatefulWidget {
//   const ProfileHeader({
//     super.key,
//     required this.profileData,
//     required this.isMe,
//     required this.showData,
//     required this.showDataFunc,
//     // required this.showDataFunc,
//   });
//   final ProfileModel profileData;
//   final bool isMe;
//   final bool showData;
//   final Function showDataFunc;
//   // final Function showDataFunc;

//   @override
//   ConsumerState<ProfileHeader> createState() => _ProfileHeaderState();
// }

// class _ProfileHeaderState extends ConsumerState<ProfileHeader> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!widget.showData) {
//       return RefreshIndicator(
//         onRefresh: () async {
//           // ignore: unused_result
//           ref.refresh(profileDataProvider(widget.profileData.username));
//         },
//         child: Stack(
//           children: [
//             GestureDetector(
//               onTap: () {
//                 if (widget.profileData.bannerUrl.isEmpty) {
//                   context.push("/editProfile", extra: widget.profileData);
//                 } else {
//                   context.push(
//                     "/profileCoverScreen",
//                     extra: ProfilePhotoScreenArgs(
//                       isMe: widget.isMe,
//                       profileModel: widget.profileData,
//                     ),
//                   );
//                 }
//               },
//               child: Container(
//                 height: 165,
//                 decoration: BoxDecoration(
//                   color: Colors.blue,
//                   image: widget.profileData.bannerUrl.isEmpty
//                       ? null
//                       : DecorationImage(
//                           image: CachedNetworkImageProvider(
//                             widget.profileData.bannerUrl,
//                           ),
//                           fit: BoxFit.cover,
//                           onError: (exception, stackTrace) => null,
//                         ),
//                 ),
//               ),
//             ),
//             AppBar(
//               backgroundColor: Colors.transparent,
//               leading: Padding(
//                 padding: const EdgeInsets.all(6.0),
//                 child: TopIcon(
//                   icon: Icons.arrow_back,
//                   actionFunction: () {
//                     if (context.canPop()) context.pop();
//                     // ignore: unused_result
//                     ref.refresh(
//                       profileDataProvider(widget.profileData.username),
//                     );
//                   },
//                 ),
//               ),
//               actions: [
//                 TopIcon(
//                   icon: Icons.search_rounded,
//                   actionFunction: () {
//                     context.push("profileSearchScreen");
//                   },
//                 ),
//                 SizedBox(width: 15),
//                 widget.isMe
//                     ? _build_more_options_profile()
//                     : _build_more_options_other_profile(
//                         context,
//                         widget.profileData,
//                         ref,
//                         widget.showDataFunc,
//                       ),
//                 SizedBox(width: 6),
//               ],
//             ),
//             Column(
//               // shrinkWrap: true,
//               // physics: NeverScrollableScrollPhysics(),
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 120),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           GestureDetector(
//                             onTap: () {
//                               // TODO: add open profile page
//                               context.push(
//                                 '/profilePhotoScreen',
//                                 extra: ProfilePhotoScreenArgs(
//                                   isMe: widget.isMe,
//                                   profileModel: widget.profileData,
//                                 ),
//                               );
//                             },
//                             child: CircleAvatar(
//                               radius: 45,
//                               backgroundColor: Colors.black,
//                               child: CircleAvatar(
//                                 radius: 40,
//                                 backgroundColor: Colors.black,
//                                 backgroundImage: CachedNetworkImageProvider(
//                                   widget.profileData.avatarUrl.isNotEmpty
//                                       ? widget.profileData.avatarUrl
//                                       : unkownUserAvatar,
//                                 ),
//                                 onBackgroundImageError:
//                                     (exception, stackTrace) => null,
//                               ),
//                             ),
//                           ),
//                           widget.isMe
//                               ? Padding(
//                                   padding: const EdgeInsets.only(top: 60),
//                                   child: OutlinedButton(
//                                     onPressed: () {
//                                       context
//                                           .push<EditProfileStatus>(
//                                             "/editProfile",
//                                             extra: widget.profileData,
//                                           )
//                                           .then((status) {
//                                             if (status ==
//                                                 EditProfileStatus
//                                                     .changedSuccessfully) {
//                                               // ignore: unused_result
//                                               ref.refresh(
//                                                 profileDataProvider(
//                                                   widget.profileData.username,
//                                                 ),
//                                               );
//                                             } else if (status ==
//                                                 EditProfileStatus
//                                                     .failedToChange) {
//                                               showTopSnackBar(
//                                                 Overlay.of(context),
//                                                 CustomSnackBar.error(
//                                                   backgroundColor: Color(
//                                                     0XFF212121,
//                                                   ),
//                                                   icon: Icon(
//                                                     Icons.error,
//                                                     color: Colors.red,
//                                                   ),
//                                                   message:
//                                                       "Profile update failed",
//                                                 ),
//                                                 displayDuration: const Duration(
//                                                   seconds: 2,
//                                                 ),
//                                               );
//                                             } else {}
//                                           });
//                                     },
//                                     style: OutlinedButton.styleFrom(
//                                       foregroundColor: Colors.white,
//                                       side: const BorderSide(
//                                         color: Color(0xFFADADAD),
//                                         width: 1,
//                                       ),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(20),
//                                       ),
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 15,
//                                       ),
//                                     ),
//                                     child: Text(
//                                       "Edit profile",
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16,
//                                       ),
//                                     ),
//                                   ),
//                                 )
//                               : widget.profileData.isBlockedByMe
//                               ? BlockButton(
//                                   profileData: widget.profileData,
//                                   showDataFunc: widget.showDataFunc,
//                                 )
//                               : Follow_Following_Button(
//                                   profileData: widget.profileData,
//                                 ),
//                         ],
//                       ),
//                       const SizedBox(height: 5),
//                       InkWell(
//                         onTap: () {
//                           //   TODO: ADD verifying logic
//                         },
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Flexible(
//                               child: Text(
//                                 widget.profileData.displayName,
//                                 style: const TextStyle(
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                             if (widget.isMe)
//                               Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   const SizedBox(width: 4),
//                                   const Icon(
//                                     Icons.verified,
//                                     color: Color(0xFF1DA1F2),
//                                     size: 18,
//                                   ),
//                                   const SizedBox(width: 8),
//                                   if (!widget.profileData.isVerified)
//                                     Text(
//                                       'Get Verified',
//                                       style: TextStyle(
//                                         color: Color(0xFF1DA1F2),
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 8),
//                       Wrap(
//                         children: [
//                           Text(
//                             "@${widget.profileData.username}",
//                             style: const TextStyle(
//                               color: Colors.grey,
//                               fontSize: 15,
//                             ),
//                           ),
//                           SizedBox(width: 10),
//                           if (widget.isMe == false &&
//                               widget.profileData.isFollower)
//                             Container(
//                               padding: EdgeInsets.symmetric(horizontal: 5),

//                               decoration: BoxDecoration(
//                                 color: Color(0XFF1F2225),
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     "Follows you",
//                                     style: TextStyle(
//                                       color: Color(0xFF6D7176),
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       );
//     } else
//       return RefreshIndicator(
//         onRefresh: () async {
//           // ignore: unused_result
//           ref.refresh(profileDataProvider(widget.profileData.username));
//         },
//         child: Stack(
//           children: [
//             GestureDetector(
//               onTap: () {
//                 if (widget.profileData.bannerUrl.isEmpty) {
//                   if (widget.isMe)
//                     context.push("/editProfile", extra: widget.profileData);
//                 } else {
//                   context.push(
//                     "/profileCoverScreen",
//                     extra: ProfilePhotoScreenArgs(
//                       isMe: widget.isMe,
//                       profileModel: widget.profileData,
//                     ),
//                   );
//                 }
//               },
//               child: Container(
//                 height: 165,
//                 decoration: BoxDecoration(
//                   color: Colors.blue,
//                   image: widget.profileData.bannerUrl.isEmpty
//                       ? null
//                       : DecorationImage(
//                           image: CachedNetworkImageProvider(
//                             widget.profileData.bannerUrl,
//                           ),
//                           fit: BoxFit.cover,
//                           onError: (exception, stackTrace) => null,
//                         ),
//                 ),
//               ),
//             ),
//             AppBar(
//               backgroundColor: Colors.transparent,
//               leading: Padding(
//                 padding: const EdgeInsets.all(6.0),
//                 child: TopIcon(
//                   icon: Icons.arrow_back,
//                   actionFunction: () {
//                     if (context.canPop()) context.pop();
//                     // ignore: unused_result
//                     ref.refresh(
//                       profileDataProvider(widget.profileData.username),
//                     );
//                   },
//                 ),
//               ),
//               actions: [
//                 TopIcon(
//                   icon: Icons.search_rounded,
//                   actionFunction: () {
//                     context.push("/profileSearchScreen");
//                   },
//                 ),
//                 SizedBox(width: 15),
//                 widget.isMe
//                     ? _build_more_options_profile()
//                     : _build_more_options_other_profile(
//                         context,
//                         widget.profileData,
//                         ref,
//                         widget.showDataFunc,
//                       ),
//                 SizedBox(width: 6),
//               ],
//             ),
//             Column(
//               // shrinkWrap: true,
//               // physics: NeverScrollableScrollPhysics(),
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 120),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           GestureDetector(
//                             onTap: () {
//                               // TODO: add open profile page
//                               context.push(
//                                 '/profilePhotoScreen',
//                                 extra: ProfilePhotoScreenArgs(
//                                   isMe: widget.isMe,
//                                   profileModel: widget.profileData,
//                                 ),
//                               );
//                             },
//                             child: CircleAvatar(
//                               radius: 45,
//                               backgroundColor: Colors.black,
//                               child: CircleAvatar(
//                                 radius: 40,
//                                 backgroundColor: Colors.black,
//                                 backgroundImage: CachedNetworkImageProvider(
//                                   widget.profileData.avatarUrl.isNotEmpty
//                                       ? widget.profileData.avatarUrl
//                                       : unkownUserAvatar,
//                                 ),
//                                 onBackgroundImageError:
//                                     (exception, stackTrace) => null,
//                               ),
//                             ),
//                           ),
//                           widget.isMe
//                               ? Padding(
//                                   padding: const EdgeInsets.only(top: 60),
//                                   child: OutlinedButton(
//                                     onPressed: () {
//                                       context
//                                           .push<EditProfileStatus>(
//                                             "/editProfile",
//                                             extra: widget.profileData,
//                                           )
//                                           .then((status) {
//                                             if (status ==
//                                                 EditProfileStatus
//                                                     .changedSuccessfully) {
//                                               // ignore: unused_result
//                                               ref.refresh(
//                                                 profileDataProvider(
//                                                   widget.profileData.username,
//                                                 ),
//                                               );
//                                             } else if (status ==
//                                                 EditProfileStatus
//                                                     .failedToChange) {
//                                               showTopSnackBar(
//                                                 Overlay.of(context),
//                                                 CustomSnackBar.error(
//                                                   backgroundColor: Color(
//                                                     0XFF212121,
//                                                   ),
//                                                   icon: Icon(
//                                                     Icons.error,
//                                                     color: Colors.red,
//                                                   ),
//                                                   message:
//                                                       "Profile update failed",
//                                                 ),
//                                                 displayDuration: const Duration(
//                                                   seconds: 2,
//                                                 ),
//                                               );
//                                             } else {}
//                                           });
//                                     },
//                                     style: OutlinedButton.styleFrom(
//                                       foregroundColor: Colors.white,
//                                       side: const BorderSide(
//                                         color: Color(0xFFADADAD),
//                                         width: 1,
//                                       ),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(20),
//                                       ),
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 15,
//                                       ),
//                                     ),
//                                     child: Text(
//                                       "Edit profile",
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16,
//                                       ),
//                                     ),
//                                   ),
//                                 )
//                               : widget.profileData.isBlockedByMe
//                               ? BlockButton(
//                                   profileData: widget.profileData,
//                                   showDataFunc: widget.showDataFunc,
//                                 )
//                               : Follow_Following_Button(
//                                   profileData: widget.profileData,
//                                 ),
//                         ],
//                       ),
//                       const SizedBox(height: 0),
//                       InkWell(
//                         onTap: () {
//                           //   TODO: ADD verifying logic
//                         },
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Flexible(
//                               child: Text(
//                                 widget.profileData.displayName,
//                                 style: const TextStyle(
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                             if (widget.isMe)
//                               Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   const SizedBox(width: 4),
//                                   const Icon(
//                                     Icons.verified,
//                                     color: Color(0xFF1DA1F2),
//                                     size: 18,
//                                   ),
//                                   const SizedBox(width: 8),
//                                   if (!widget.profileData.isVerified)
//                                     Text(
//                                       'Get Verified',
//                                       style: TextStyle(
//                                         color: Color(0xFF1DA1F2),
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 8),
//                       Wrap(
//                         children: [
//                           Text(
//                             "@${widget.profileData.username}",
//                             style: const TextStyle(
//                               color: Colors.grey,
//                               fontSize: 15,
//                             ),
//                           ),
//                           SizedBox(width: 10),
//                           if (widget.isMe == false &&
//                               widget.profileData.isFollower)
//                             Container(
//                               padding: EdgeInsets.symmetric(horizontal: 5),

//                               // width: 75,
//                               decoration: BoxDecoration(
//                                 color: Color(0XFF1F2225),
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     "Follows you",
//                                     style: TextStyle(
//                                       color: Color(0xFF6D7176),
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       if (widget.profileData.bio.isNotEmpty)
//                         Text(
//                           widget.profileData.bio,
//                           style: const TextStyle(fontSize: 15),
//                           maxLines: 3,
//                         ),
//                       if (widget.profileData.bio.isNotEmpty)
//                         const SizedBox(height: 5),
//                       const SizedBox(height: 8),

//                       Wrap(
//                         runSpacing: 8,
//                         children: [
//                           if (widget.profileData.location.isNotEmpty)
//                             Wrap(
//                               children: [
//                                 const Icon(
//                                   Icons.location_on_outlined,
//                                   color: Colors.grey,
//                                   size: 16,
//                                 ),
//                                 const SizedBox(width: 1),
//                                 Text(
//                                   widget.profileData.location,
//                                   style: const TextStyle(color: Colors.grey),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.clip,
//                                 ),
//                                 const SizedBox(width: 12),
//                               ],
//                             ),

//                           if (widget.profileData.website.isNotEmpty)
//                             Wrap(
//                               children: [
//                                 SvgPicture.asset(
//                                   "assets/svg/website.svg",
//                                   width: 16,
//                                   height: 16,
//                                   colorFilter: ColorFilter.mode(
//                                     Colors.grey,
//                                     BlendMode.srcIn,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 2),
//                                 GestureDetector(
//                                   onTap: () async {
//                                     final url = widget.profileData.website;
//                                     final uri = Uri.parse(
//                                       url.startsWith('http')
//                                           ? url
//                                           : 'https://$url',
//                                     );

//                                     if (await canLaunchUrl(uri)) {
//                                       await launchUrl(
//                                         uri,
//                                         mode: LaunchMode.inAppBrowserView,
//                                       );
//                                     } else {
//                                       // Show error message
//                                       if (mounted) {
//                                         ScaffoldMessenger.of(
//                                           context,
//                                         ).showSnackBar(
//                                           SnackBar(
//                                             content: Text(
//                                               'Could not open website',
//                                             ),
//                                           ),
//                                         );
//                                       }
//                                     }
//                                   },
//                                   child: Text(
//                                     widget.profileData.website,
//                                     style: const TextStyle(
//                                       color: Colors.blueAccent,
//                                     ),
//                                     maxLines: 1,
//                                     overflow: TextOverflow.clip,
//                                   ),
//                                 ),

//                                 const SizedBox(width: 12),
//                               ],
//                             ),

//                           if (widget.profileData.birthDate.isNotEmpty)
//                             Wrap(
//                               children: [
//                                 SvgPicture.asset(
//                                   "assets/svg/born.svg",
//                                   width: 16,
//                                   height: 16,
//                                   colorFilter: const ColorFilter.mode(
//                                     Colors.grey,
//                                     BlendMode.srcIn,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 1),
//                                 Text(
//                                   "Born ${widget.profileData.birthDate}",
//                                   style: const TextStyle(color: Colors.grey),
//                                 ),
//                                 const SizedBox(width: 12),
//                               ],
//                             ),
//                           if (widget.profileData.joinedDate.isNotEmpty)
//                             Wrap(
//                               children: [
//                                 const Icon(
//                                   Icons.calendar_month_outlined,
//                                   color: Colors.grey,
//                                   size: 16,
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   "Joined ${widget.profileData.joinedDate}",
//                                   style: const TextStyle(color: Colors.grey),
//                                 ),
//                               ],
//                             ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),

//                       Row(
//                         children: [
//                           GestureDetector(
//                             onTap: () {
//                               context.push(
//                                 "/followingfollowersscreen/${FollowingFollowersInitialTab.Following}/${widget.isMe ? "me" : "notme"}",
//                                 extra: this.widget.profileData,
//                               );
//                             },
//                             child: _buildFollowCount(
//                               widget.profileData.followingCount,
//                               'Following',
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           GestureDetector(
//                             onTap: () {
//                               //   TODO: navigae to followers page
//                               context.push(
//                                 "/followingfollowersscreen/${FollowingFollowersInitialTab.Followers}/${widget.isMe ? "me" : "notme"}",
//                                 extra: this.widget.profileData,
//                               );
//                             },
//                             child: _buildFollowCount(
//                               widget.profileData.followersCount,
//                               'Follower',
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 0),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       );
//   }
// }

// Widget _buildFollowCount(int count, String label) {
//   String formatedCount = Shared.formatCount(count);

//   return RichText(
//     text: TextSpan(
//       children: [
//         TextSpan(
//           text: formatedCount + " ",
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//         TextSpan(
//           text: label,
//           style: const TextStyle(color: Colors.grey, fontSize: 16),
//         ),
//       ],
//     ),
//   );
// }

// Widget _build_more_options_profile() {
//   return CircleAvatar(
//     child: PopupMenuButton<String>(
//       icon: Icon(Icons.more_vert, color: Colors.white),
//       color: Color(0xFF212121),
//       onSelected: (value) async {
//         switch (value) {
//           case 'Share':
//             // // Handle share
//             // final url = profileModel.avatarUrl;
//             // final uri = Uri.parse(
//             //   url.startsWith('http') ? url : 'https://$url',
//             // );

//             // Share.share(uri.toString());

//             // TODO: add the profile url
//             break;
//           case 'Drafts':
//             break;
//           case "Lists you're on":
//             // Handle block
//             break;
//         }
//       },
//       itemBuilder: (context) => [
//         PopupMenuItem(
//           value: 'Share',
//           child: Row(
//             children: [
//               SizedBox(width: 12),
//               Text(
//                 'Share',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         PopupMenuItem(
//           value: 'Drafts',
//           child: Row(
//             children: [
//               SizedBox(width: 12),
//               Text(
//                 'Drafts',
//                 style: TextStyle(color: Colors.white, fontSize: 18),
//               ),
//             ],
//           ),
//         ),
//         PopupMenuItem(
//           value: "Lists you're on",
//           child: Row(
//             children: [
//               SizedBox(width: 12),
//               Text(
//                 "Lists you're on",
//                 style: TextStyle(color: Colors.white, fontSize: 18),
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//     backgroundColor: Colors.black.withValues(alpha: 0.5),
//     radius: 20,
//   );
// }

// Widget _build_more_options_other_profile(
//   BuildContext context,
//   ProfileModel profileData,
//   WidgetRef ref,
//   Function showDataFunc,
// ) {
//   return CircleAvatar(
//     child: PopupMenuButton<String>(
//       icon: Icon(Icons.more_vert, color: Colors.white),
//       color: Color(0xFF212121),
//       onSelected: (value) async {
//         switch (value) {
//           case 'Share':
//             // // Handle share
//             // final url = profileModel.avatarUrl;
//             // final uri = Uri.parse(
//             //   url.startsWith('http') ? url : 'https://$url',
//             // );

//             // Share.share(uri.toString());

//             // TODO: add the profile url
//             // print("Share");
//             break;
//           case 'Add/remove from lists':
//             // print("add /remove");
//             break;
//           case "view lists":
//             // print("veiew lists");
//             // Handle block
//             break;
//           case "Lists they're on":
//             // print("list they are on");
//             // Handle block
//             break;
//           case "Mute":
//             final mute = ref.watch(muteUserProvider);
//             mute(profileData.username).then((either) {
//               either.fold(
//                 (l) {
//                   showSmallPopUpMessage(
//                     context: context,
//                     message: l.message,
//                     borderColor: Colors.red,
//                     icon: Icon(Icons.error, color: Colors.red),
//                   );
//                 },
//                 (r) {
//                   showSmallPopUpMessage(
//                     context: context,
//                     message: "You Muted @${profileData.username}",
//                     borderColor: Colors.blue,
//                     icon: Icon(Icons.volume_off, color: Colors.blue),
//                   );
//                   // ignore: unused_result
//                   ref.refresh(profileDataProvider(profileData.username));
//                 },
//               );
//             });
//             break;

//           case "Unmute":
//             final unMute = ref.watch(unMuteUserProvider);
//             unMute(profileData.username).then((either) {
//               either.fold(
//                 (l) {
//                   showSmallPopUpMessage(
//                     context: context,
//                     message: l.message,
//                     borderColor: Colors.red,
//                     icon: Icon(Icons.error, color: Colors.red),
//                   );
//                 },
//                 (r) {
//                   showSmallPopUpMessage(
//                     context: context,
//                     message: "You Unmuted @${profileData.username}",
//                     borderColor: Colors.blue,
//                     icon: Icon(Icons.volume_up, color: Colors.blue),
//                   );
//                   // ignore: unused_result
//                   ref.refresh(profileDataProvider(profileData.username));
//                 },
//               );
//             });
//             break;
//           case "Block":
//             final res = await showPopupMessage(
//               context: context,
//               title: Text(
//                 "Block @${profileData.username}?",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w900,
//                   fontSize: 22,
//                 ),
//               ),
//               message: Text(
//                 "They will be able to see your public posts, but will no longer be able to engage with them. @${profileData.username} will also not be able to follow or message you, and you will not see notifications from them",
//                 style: TextStyle(color: Colors.white),
//               ),
//               confirmText: "Block",
//               cancelText: "Cancel",
//             );
//             if (res == null || res == false) return;
//             final block = ref.read(blockUserProvider);
//             final blockRes = await block(profileData.username);
//             blockRes.fold(
//               (fail) {
//                 showSmallPopUpMessage(
//                   context: context,
//                   message: fail.message,
//                   borderColor: Colors.red,
//                   icon: Icon(Icons.error, color: Colors.red),
//                 );
//               },
//               (right) {
//                 // ignore: unused_result
//                 ref.refresh(profileDataProvider(profileData.username));
//                 showDataFunc();
//               },
//             );
//             break;
//           case "Unblock":
//             final res = await showPopupMessage(
//               context: context,
//               title: Text(
//                 "Unblock @${profileData.username}?",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w900,
//                   fontSize: 22,
//                 ),
//               ),
//               message: Text(
//                 "They will be able to follow you and engage with your posts. (if the account is protected they'll have to request to follow)",
//                 style: TextStyle(color: Colors.white),
//               ),
//               confirmText: "UnBlock",
//               cancelText: "Cancel",
//             );
//             if (res == null || res == false) return;
//             final unblock = ref.read(unBlockUserProvider);
//             final blockRes = await unblock(profileData.username);
//             blockRes.fold(
//               (fail) {
//                 showSmallPopUpMessage(
//                   context: context,
//                   message: fail.message,
//                   borderColor: Colors.red,
//                   icon: Icon(Icons.error, color: Colors.red),
//                 );
//               },
//               (right) {
//                 // ignore: unused_result
//                 ref.refresh(profileDataProvider(profileData.username));
//                 showDataFunc();
//               },
//             );
//             break;
//           case "Report":
//             // print("Report");
//             // handle report
//             break;
//         }
//       },
//       itemBuilder: (context) => [
//         PopupMenuItem(
//           value: 'Share',
//           child: Row(
//             children: [
//               SizedBox(width: 12),
//               Text(
//                 'Share',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         if (!profileData.isBlockedByMe)
//           PopupMenuItem(
//             value: 'Add/remove from lists',
//             child: Row(
//               children: [
//                 SizedBox(width: 12),
//                 Text(
//                   'Add/remove from lists',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         PopupMenuItem(
//           value: 'view lists',
//           child: Row(
//             children: [
//               SizedBox(width: 12),
//               Text(
//                 'view Lists',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         PopupMenuItem(
//           value: "Lists they're on",
//           child: Row(
//             children: [
//               SizedBox(width: 12),
//               Text(
//                 "Lists they're on",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         if (!profileData.isBlockedByMe)
//           PopupMenuItem(
//             value: profileData.isMutedByMe ? 'Unmute' : 'Mute',
//             child: Row(
//               children: [
//                 SizedBox(width: 12),
//                 Text(
//                   profileData.isMutedByMe ? 'Unmute' : 'Mute',
//                   style: TextStyle(color: Colors.white, fontSize: 18),
//                 ),
//               ],
//             ),
//           ),
//         PopupMenuItem(
//           value: profileData.isBlockedByMe ? "Unblock" : "Block",
//           child: Row(
//             children: [
//               SizedBox(width: 12),
//               Text(
//                 profileData.isBlockedByMe ? "Unblock" : "Block",
//                 style: TextStyle(color: Colors.white, fontSize: 18),
//               ),
//             ],
//           ),
//         ),
//         PopupMenuItem(
//           value: "Report",
//           child: Row(
//             children: [
//               SizedBox(width: 12),
//               Text(
//                 "Report",
//                 style: TextStyle(color: Colors.white, fontSize: 18),
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//     backgroundColor: Colors.black.withValues(alpha: 0.5),
//     radius: 20,
//   );
// }
