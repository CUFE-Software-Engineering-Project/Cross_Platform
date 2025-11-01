import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_x/features/media/view_model/media_view_model.dart';

/// Simple Tweet composer with media attach support.
class TweetComposer extends ConsumerStatefulWidget {
  final String tweetId;
  const TweetComposer({required this.tweetId, super.key});

  @override
  ConsumerState<TweetComposer> createState() => _TweetComposerState();
}

class _TweetComposerState extends ConsumerState<TweetComposer> {
  final _controller = TextEditingController();
  Uint8List? _pickedBytes;
  String? _pickedName;
  bool _loading = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true, allowMultiple: false);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedBytes = result.files.first.bytes;
        _pickedName = result.files.first.name;
      });
    }
  }

  Future<void> _attach() async {
    if (_pickedBytes == null || _pickedName == null) return;
    setState(() => _loading = true);
    try {
      final vm = ref.read(mediaViewModelProvider);
      final resp = await vm.attachMediaToTweet(
        tweetId: widget.tweetId,
        fileBytes: _pickedBytes!.toList(),
        filename: _pickedName!,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Uploaded: ${resp.toString()}')));
      setState(() {
        _pickedBytes = null;
        _pickedName = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(controller: _controller, maxLines: 3, decoration: const InputDecoration(hintText: 'What\'s happening?')),
        const SizedBox(height: 8),
        if (_pickedName != null) Text('Selected: $_pickedName'),
        Row(
          children: [
            TextButton.icon(onPressed: _pickFile, icon: const Icon(Icons.attach_file), label: const Text('Attach')),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _loading ? null : _attach,
              child: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Upload Media'),
            ),
          ],
        ),
      ],
    );
  }
}
