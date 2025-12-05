const Map<String, String> _mediaTypes = {
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'png': 'image/png',
  'gif': 'image/gif',
  'webp': 'image/webp',

  'mp4': 'video/mp4',
  'mov': 'video/quicktime',
  'avi': 'video/x-msvideo',
  'webm': 'video/webm',
  'mkv': 'video/x-matroska',
  'flv': 'video/x-flv',
  'wmv': 'video/x-ms-wmv',
  'mpeg': 'video/mpeg',
  'mpg': 'video/mpeg',
  '3gp': 'video/3gpp',
  'm4v': 'video/x-m4v',
};
String getMediaType(String filePath) {
  final extension = filePath.split('.').last.toLowerCase();
  return _mediaTypes[extension] ?? 'image/jpeg';
}
