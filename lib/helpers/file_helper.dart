import 'package:path/path.dart' as path;

class FileHelper {
  FileHelper._();
  static FileHelperFileType parseUrlFileType(String url) {
    final host = url.split('?').first;
    var ext = path.extension(host);
    // 常见的图片扩展名
    List<String> imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp'];

    // 常见的视频扩展名
    List<String> videoExtensions = ['.mp4', '.avi', '.mkv', '.mov'];

    if (imageExtensions.contains(ext)) {
      return FileHelperFileType.image;
    } else if (videoExtensions.contains(ext)) {
      return FileHelperFileType.video;
    } else {
      return FileHelperFileType.other;
    }
  }
}

enum FileHelperFileType {
  image,
  video,
  other,
}
