import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/home/utils/text_with_hashtags.dart';

void main() {
  group('TextWithHashtags Tests', () {
    const testStyle = TextStyle(fontSize: 14, color: Colors.black);

    test('builds plain text without hashtags or mentions', () {
      const text = 'This is a plain text message';

      final result = TextWithHashtags.buildTextSpan(
        text: text,
        style: testStyle,
      );

      expect(result.children, isNotNull);
      expect(result.children!.length, 1);
      final span = result.children![0] as TextSpan;
      expect(span.text, text);
      expect(span.style, testStyle);
    });

    test('detects and styles hashtags', () {
      const text = 'Check out #flutter and #dart';

      final result = TextWithHashtags.buildTextSpan(
        text: text,
        style: testStyle,
      );

      expect(result.children, isNotNull);
      // 'Check out ', '#flutter', ' and ', '#dart' = 4 spans (no trailing empty span)
      expect(result.children!.length, 4);

      // Check first hashtag
      final hashtagSpan = result.children![1] as TextSpan;
      expect(hashtagSpan.text, '#flutter');
      expect(hashtagSpan.style!.color, const Color(0xFF1DA1F2));
      expect(hashtagSpan.style!.fontWeight, FontWeight.w500);
    });

    test('detects and styles mentions', () {
      const text = 'Hello @testuser and @anotheruser';

      final result = TextWithHashtags.buildTextSpan(
        text: text,
        style: testStyle,
      );

      expect(result.children, isNotNull);

      // Check first mention
      final mentionSpan = result.children![1] as TextSpan;
      expect(mentionSpan.text, '@testuser');
      expect(mentionSpan.style!.color, const Color(0xFF1DA1F2));
      expect(mentionSpan.style!.fontWeight, FontWeight.w500);
    });

    test('handles mixed hashtags and mentions', () {
      const text = 'Check #flutter by @googledev';

      final result = TextWithHashtags.buildTextSpan(
        text: text,
        style: testStyle,
      );

      expect(result.children, isNotNull);
      expect(result.children!.length >= 4, true);

      // Verify hashtag
      final hashtagSpan = result.children![1] as TextSpan;
      expect(hashtagSpan.text, '#flutter');

      // Verify mention
      final mentionSpan = result.children![3] as TextSpan;
      expect(mentionSpan.text, '@googledev');
    });

    test('makes hashtags clickable when onHashtagTap provided', () {
      const text = 'Check #flutter';
      String? tappedHashtag;

      final result = TextWithHashtags.buildTextSpan(
        text: text,
        style: testStyle,
        onHashtagTap: (hashtag) => tappedHashtag = hashtag,
      );

      final hashtagSpan = result.children![1] as TextSpan;
      expect(hashtagSpan.recognizer, isA<TapGestureRecognizer>());

      // Simulate tap
      final recognizer = hashtagSpan.recognizer as TapGestureRecognizer;
      recognizer.onTap!();

      expect(tappedHashtag, 'flutter');
    });

    test('makes mentions clickable when onMentionTap provided', () {
      const text = 'Hello @testuser';
      String? tappedMention;

      final result = TextWithHashtags.buildTextSpan(
        text: text,
        style: testStyle,
        onMentionTap: (mention) => tappedMention = mention,
      );

      final mentionSpan = result.children![1] as TextSpan;
      expect(mentionSpan.recognizer, isA<TapGestureRecognizer>());

      // Simulate tap
      final recognizer = mentionSpan.recognizer as TapGestureRecognizer;
      recognizer.onTap!();

      expect(tappedMention, 'testuser');
    });

    test('hashtags without handler are styled but not clickable', () {
      const text = 'Check #flutter';

      final result = TextWithHashtags.buildTextSpan(
        text: text,
        style: testStyle,
      );

      final hashtagSpan = result.children![1] as TextSpan;
      expect(hashtagSpan.recognizer, isNull);
      expect(hashtagSpan.style!.color, const Color(0xFF1DA1F2));
    });

    test('handles Arabic hashtags', () {
      const text = 'مرحبا #فلاتر و #برمجة';

      final result = TextWithHashtags.buildTextSpan(
        text: text,
        style: testStyle,
      );

      expect(result.children, isNotNull);

      // Should detect Arabic hashtags
      final spans = result.children!
          .whereType<TextSpan>()
          .where((s) => s.text != null && s.text!.startsWith('#'))
          .toList();
      expect(spans.length, 2);
    });

    test('handles Arabic mentions', () {
      const text = 'مرحبا @مستخدم123';

      final result = TextWithHashtags.buildTextSpan(
        text: text,
        style: testStyle,
      );

      expect(result.children, isNotNull);

      // Should detect Arabic mentions
      final spans = result.children!
          .whereType<TextSpan>()
          .where((s) => s.text != null && s.text!.startsWith('@'))
          .toList();
      expect(spans.length, 1);
    });

    test('uses knownHashtags for exact matching', () {
      const text = 'Check #flutter and #unknown';
      final knownHashtags = ['flutter'];

      final result = TextWithHashtags.buildTextSpan(
        text: text,
        style: testStyle,
        knownHashtags: knownHashtags,
      );

      // Should match #flutter from known list
      expect(result.children, isNotNull);
      final hashtagSpans = result.children!
          .whereType<TextSpan>()
          .where((s) => s.text != null && s.text!.startsWith('#'))
          .toList();
      expect(hashtagSpans.length, 1);
      expect(hashtagSpans[0].text, '#flutter');
    });

    test('handles consecutive hashtags', () {
      const text = '#flutter#dart#coding';

      final result = TextWithHashtags.buildTextSpan(
        text: text,
        style: testStyle,
      );

      expect(result.children, isNotNull);
      final hashtagSpans = result.children!
          .whereType<TextSpan>()
          .where((s) => s.text != null && s.text!.startsWith('#'))
          .toList();
      expect(hashtagSpans.length >= 1, true);
    });

    test('handles hashtags at start and end of text', () {
      const text = '#start middle text #end';

      final result = TextWithHashtags.buildTextSpan(
        text: text,
        style: testStyle,
      );

      expect(result.children, isNotNull);
      final hashtagSpans = result.children!
          .whereType<TextSpan>()
          .where((s) => s.text != null && s.text!.startsWith('#'))
          .toList();
      expect(hashtagSpans.length, 2);
    });

    test('handles mentions at start and end of text', () {
      const text = '@start middle text @end';

      final result = TextWithHashtags.buildTextSpan(
        text: text,
        style: testStyle,
      );

      expect(result.children, isNotNull);
      final mentionSpans = result.children!
          .whereType<TextSpan>()
          .where((s) => s.text != null && s.text!.startsWith('@'))
          .toList();
      expect(mentionSpans.length, 2);
    });

    test('handles empty text', () {
      const text = '';

      final result = TextWithHashtags.buildTextSpan(
        text: text,
        style: testStyle,
      );

      expect(result.children, isNotNull);
      expect(result.children!.isEmpty, true);
    });

    test('handles text with only whitespace', () {
      const text = '   ';

      final result = TextWithHashtags.buildTextSpan(
        text: text,
        style: testStyle,
      );

      expect(result.children, isNotNull);
      expect(result.children!.length, 1);
      final span = result.children![0] as TextSpan;
      expect(span.text, text);
    });

    test('handles hashtag with numbers', () {
      const text = 'Check #flutter2024';

      final result = TextWithHashtags.buildTextSpan(
        text: text,
        style: testStyle,
      );

      final hashtagSpans = result.children!
          .whereType<TextSpan>()
          .where((s) => s.text != null && s.text!.startsWith('#'))
          .toList();
      expect(hashtagSpans.length, 1);
      expect(hashtagSpans[0].text, '#flutter2024');
    });

    test('handles mention with numbers', () {
      const text = 'Hello @user123';

      final result = TextWithHashtags.buildTextSpan(
        text: text,
        style: testStyle,
      );

      final mentionSpans = result.children!
          .whereType<TextSpan>()
          .where((s) => s.text != null && s.text!.startsWith('@'))
          .toList();
      expect(mentionSpans.length, 1);
      expect(mentionSpans[0].text, '@user123');
    });

    test('multiple taps on different hashtags work correctly', () {
      const text = '#flutter #dart #coding';
      final tappedHashtags = <String>[];

      final result = TextWithHashtags.buildTextSpan(
        text: text,
        style: testStyle,
        onHashtagTap: tappedHashtags.add,
      );

      final hashtagSpans = result.children!
          .whereType<TextSpan>()
          .where((s) => s.recognizer is TapGestureRecognizer)
          .toList();

      // Tap each hashtag
      for (final span in hashtagSpans) {
        final recognizer = span.recognizer as TapGestureRecognizer;
        recognizer.onTap!();
      }

      expect(tappedHashtags.length, 3);
      expect(tappedHashtags, containsAll(['flutter', 'dart', 'coding']));
    });
  });
}
