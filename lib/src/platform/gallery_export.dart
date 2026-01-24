import 'package:flutter/services.dart';

class GalleryExport {
  static const MethodChannel _channel = MethodChannel('hibiscus/export');

  static Future<void> saveVideoToGallery({
    required String path,
    required String name,
  }) async {
    await _channel.invokeMethod<void>(
      'saveVideoToGallery',
      {'path': path, 'name': name},
    );
  }
}

