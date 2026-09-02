import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/// Generates a JPEG frame from a video URL/path and stores it on disk so chat
/// bubbles don't re-extract the same thumbnail on every rebuild/scroll.
class VideoThumbnailCache {
  VideoThumbnailCache._();

  static final Map<String, Future<String?>> _inFlight = {};
  static Directory? _cacheDir;

  static Future<Directory> _dir() async {
    if (_cacheDir != null) return _cacheDir!;
    final root = await getTemporaryDirectory();
    final dir = Directory('${root.path}/video_thumbs');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _cacheDir = dir;
    return dir;
  }

  static String _keyFor(String videoPath) {
    final digest =
        base64Url.encode(utf8.encode(videoPath)).replaceAll('=', '');
    return digest.length > 80 ? digest.substring(0, 80) : digest;
  }

  /// Returns a local file path to a cached JPEG thumbnail, or null on failure.
  static Future<String?> getThumbnailPath(String videoPath) {
    final key = _keyFor(videoPath);
    return _inFlight.putIfAbsent(key, () async {
      try {
        return await _loadOrCreate(videoPath, key);
      } catch (e, st) {
        debugPrint('VideoThumbnailCache error: $e\n$st');
        _inFlight.remove(key); // allow retry next time
        return null;
      }
    });
  }

  static Future<String?> _loadOrCreate(String videoPath, String key) async {
    final dir = await _dir();
    final outPath = '${dir.path}/$key.jpg';
    final existing = File(outPath);
    if (await existing.exists() && await existing.length() > 0) {
      return outPath;
    }

    final generated = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: dir.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 480,
      quality: 70,
      timeMs: 500,
    );

    if (generated == null || generated.isEmpty) {
      _inFlight.remove(key);
      return null;
    }

    final generatedFile = File(generated);
    if (!await generatedFile.exists()) {
      _inFlight.remove(key);
      return null;
    }

    if (generated != outPath) {
      await generatedFile.copy(outPath);
      try {
        await generatedFile.delete();
      } catch (_) {}
    }

    return outPath;
  }
}
