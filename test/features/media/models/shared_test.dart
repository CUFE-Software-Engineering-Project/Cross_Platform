import 'package:flutter_test/flutter_test.dart';
import 'package:lite_x/features/media/models/shared.dart';

void main() {
  group('getMediaType', () {
    group('Image types', () {
      test('should return image/jpeg for jpg extension', () {
        expect(getMediaType('photo.jpg'), 'image/jpeg');
      });

      test('should return image/jpeg for jpeg extension', () {
        expect(getMediaType('photo.jpeg'), 'image/jpeg');
      });

      test('should return image/png for png extension', () {
        expect(getMediaType('image.png'), 'image/png');
      });

      test('should return image/gif for gif extension', () {
        expect(getMediaType('animation.gif'), 'image/gif');
      });

      test('should return image/webp for webp extension', () {
        expect(getMediaType('modern.webp'), 'image/webp');
      });
    });

    group('Video types', () {
      test('should return video/mp4 for mp4 extension', () {
        expect(getMediaType('video.mp4'), 'video/mp4');
      });

      test('should return video/quicktime for mov extension', () {
        expect(getMediaType('video.mov'), 'video/quicktime');
      });

      test('should return video/x-msvideo for avi extension', () {
        expect(getMediaType('video.avi'), 'video/x-msvideo');
      });

      test('should return video/webm for webm extension', () {
        expect(getMediaType('video.webm'), 'video/webm');
      });

      test('should return video/x-matroska for mkv extension', () {
        expect(getMediaType('video.mkv'), 'video/x-matroska');
      });

      test('should return video/x-flv for flv extension', () {
        expect(getMediaType('video.flv'), 'video/x-flv');
      });

      test('should return video/x-ms-wmv for wmv extension', () {
        expect(getMediaType('video.wmv'), 'video/x-ms-wmv');
      });

      test('should return video/mpeg for mpeg extension', () {
        expect(getMediaType('video.mpeg'), 'video/mpeg');
      });

      test('should return video/mpeg for mpg extension', () {
        expect(getMediaType('video.mpg'), 'video/mpeg');
      });

      test('should return video/3gpp for 3gp extension', () {
        expect(getMediaType('video.3gp'), 'video/3gpp');
      });

      test('should return video/x-m4v for m4v extension', () {
        expect(getMediaType('video.m4v'), 'video/x-m4v');
      });
    });

    group('Case insensitivity', () {
      test('should handle uppercase JPG extension', () {
        expect(getMediaType('PHOTO.JPG'), 'image/jpeg');
      });

      test('should handle mixed case PnG extension', () {
        expect(getMediaType('image.PnG'), 'image/png');
      });

      test('should handle uppercase MP4 extension', () {
        expect(getMediaType('VIDEO.MP4'), 'video/mp4');
      });

      test('should handle mixed case MoV extension', () {
        expect(getMediaType('clip.MoV'), 'video/quicktime');
      });
    });

    group('Path handling', () {
      test('should extract extension from simple filename', () {
        expect(getMediaType('file.jpg'), 'image/jpeg');
      });

      test('should extract extension from path with single directory', () {
        expect(getMediaType('images/photo.png'), 'image/png');
      });

      test('should extract extension from full path', () {
        expect(getMediaType('/user/documents/photos/vacation.jpg'), 'image/jpeg');
      });

      test('should extract extension from Windows-style path', () {
        expect(getMediaType('C:\\Users\\Photos\\image.png'), 'image/png');
      });

      test('should handle filename with multiple dots', () {
        expect(getMediaType('file.backup.old.jpg'), 'image/jpeg');
      });

      test('should handle path with dots in directory names', () {
        expect(getMediaType('folder.2024/sub.folder/file.mp4'), 'video/mp4');
      });
    });

    group('Default behavior', () {
      test('should return default image/jpeg for unknown extension', () {
        expect(getMediaType('file.xyz'), 'image/jpeg');
      });

      test('should return default image/jpeg for no extension', () {
        expect(getMediaType('file'), 'image/jpeg');
      });

      test('should return default image/jpeg for empty string', () {
        expect(getMediaType(''), 'image/jpeg');
      });

      test('should return default image/jpeg for unsupported format', () {
        expect(getMediaType('document.pdf'), 'image/jpeg');
      });

      test('should return default image/jpeg for text file', () {
        expect(getMediaType('readme.txt'), 'image/jpeg');
      });
    });

    group('Edge cases', () {
      test('should handle very long filename', () {
        final longName = 'a' * 1000 + '.jpg';
        expect(getMediaType(longName), 'image/jpeg');
      });

      test('should handle filename with spaces', () {
        expect(getMediaType('my photo.jpg'), 'image/jpeg');
      });

      test('should handle filename with special characters', () {
        expect(getMediaType('photo@2024#1.png'), 'image/png');
      });

      test('should handle URL-style path', () {
        expect(getMediaType('https://example.com/images/photo.jpg'), 'image/jpeg');
      });

      test('should handle path ending with slash and extension', () {
        expect(getMediaType('folder/.jpg'), 'image/jpeg');
      });
    });

    group('All supported extensions coverage', () {
      test('should handle all image extensions', () {
        expect(getMediaType('f.jpg'), 'image/jpeg');
        expect(getMediaType('f.jpeg'), 'image/jpeg');
        expect(getMediaType('f.png'), 'image/png');
        expect(getMediaType('f.gif'), 'image/gif');
        expect(getMediaType('f.webp'), 'image/webp');
      });

      test('should handle all video extensions', () {
        expect(getMediaType('f.mp4'), 'video/mp4');
        expect(getMediaType('f.mov'), 'video/quicktime');
        expect(getMediaType('f.avi'), 'video/x-msvideo');
        expect(getMediaType('f.webm'), 'video/webm');
        expect(getMediaType('f.mkv'), 'video/x-matroska');
        expect(getMediaType('f.flv'), 'video/x-flv');
        expect(getMediaType('f.wmv'), 'video/x-ms-wmv');
        expect(getMediaType('f.mpeg'), 'video/mpeg');
        expect(getMediaType('f.mpg'), 'video/mpeg');
        expect(getMediaType('f.3gp'), 'video/3gpp');
        expect(getMediaType('f.m4v'), 'video/x-m4v');
      });
    });
  });
}
