// import 'package:flutter/material.dart';
// import 'package:lite_x/core/theme/palette.dart';

// class BlockedAccountsScreen extends StatelessWidget {
//   const BlockedAccountsScreen({super.key});

//   Widget _description() => Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//         child: Text(
//           'When you block someone, they won\'t be able to follow or message you, and you won\'t see notifications from them.',
//           style: const TextStyle(color: Palette.textSecondary, fontSize: 16, height: 1.4),
//         ),
//       );

//   Widget _content(BuildContext context) => SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 8),
//             _description(),
//             const SizedBox(height: 18),
//             // Placeholder: list of blocked accounts would go here
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//               child: const Text('No blocked accounts', style: TextStyle(color: Palette.textWhite, fontSize: 16)),
//             ),
//             const SizedBox(height: 48),
//           ],
//         ),
//       );

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(builder: (context, constraints) {
//       if (constraints.maxWidth > 600) {
//         return Scaffold(
//           backgroundColor: Colors.black.withOpacity(0.4),
//           body: Center(
//             child: Container(
//               width: 800,
//               height: 700,
//               decoration: BoxDecoration(
//                 color: Palette.background,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 children: [
//                   AppBar(
//                     backgroundColor: Palette.background,
//                     elevation: 0,
//                     leading: IconButton(
//                       icon: const Icon(Icons.arrow_back, color: Palette.textWhite, size: 20),
//                       onPressed: () => Navigator.of(context).pop(),
//                     ),
//                     title: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: const [
//                         Text('Blocked accounts', style: TextStyle(color: Palette.textWhite, fontSize: 18, fontWeight: FontWeight.w700)),
//                         SizedBox(height: 2),
//                         Text('@profilename', style: TextStyle(color: Palette.textSecondary, fontSize: 12)),
//                       ],
//                     ),
//                     centerTitle: false,
//                   ),
//                   Expanded(child: _content(context)),
//                 ],
//               ),
//             ),
//           ),
//         );
//       }

//       return Scaffold(
//         backgroundColor: Palette.background,
//         appBar: AppBar(
//           backgroundColor: Palette.background,
//           elevation: 0,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Palette.textWhite, size: 20),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           title: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: const [
//               Text('Blocked accounts', style: TextStyle(color: Palette.textWhite, fontSize: 18, fontWeight: FontWeight.w700)),
//               SizedBox(height: 2),
//               Text('@profilename', style: TextStyle(color: Palette.textSecondary, fontSize: 12)),
//             ],
//           ),
//           centerTitle: false,
//         ),
//         body: _content(context),
//       );
//     });
//   }
// }
