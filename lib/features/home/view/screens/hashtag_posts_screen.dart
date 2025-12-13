import 'package:flutter/material.dart';

/// Deprecated: the hashtag posts feed feature has been removed.
///
/// This screen is kept as a safe placeholder for any old navigation paths.
class HashtagPostsScreen extends StatelessWidget {
  final String hashtagId;
  final String hashtagText;

  const HashtagPostsScreen({
    super.key,
    required this.hashtagId,
    required this.hashtagText,
  });

  @override
  Widget build(BuildContext context) {
    final decodedHashtag = Uri.decodeComponent(hashtagText);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '#$decodedHashtag',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Hashtag posts are disabled.\n\nHashtag id: $hashtagId',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
        ),
      ),
    );
  }
}
