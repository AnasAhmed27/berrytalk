import 'package:berrytalks/network/ApiConfig.dart';

/// Resolves chat media paths from the API/socket into playable URLs.
///
/// WhatsApp often returns relative paths like `assets/123.ogg`, while
/// Facebook/Instagram return full `https://...` CDN URLs.
///
/// Staging/portal serve relative files at:
/// `{host}/node/assets/` + filePath.replace("assets/", "")
/// e.g. `assets/123.ogg` → `https://qaomni…/node/assets/123.ogg`
class MediaUrlResolver {
  static const String mediaBaseUrl = ApiConfig.mediaBaseUrl;

  /// Returns an absolute http(s) URL when [path] is a server-relative media
  /// path. Leaves local device paths and already-absolute URLs unchanged.
  static String? resolve(String? path) {
    if (path == null) return null;
    final p = path.trim();
    if (p.isEmpty) return p;

    if (p.startsWith('http://') ||
        p.startsWith('https://') ||
        p.startsWith('file://') ||
        p.startsWith('content://')) {
      return p;
    }

    // Absolute local filesystem paths (optimistic uploads / recordings).
    if (p.startsWith('/') || RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(p)) {
      return p;
    }

    // `assets/123.ogg` → `{host}/node/assets/123.ogg`
    var relative = p.startsWith('/') ? p.substring(1) : p;
    if (relative.toLowerCase().startsWith('assets/')) {
      relative = relative.substring('assets/'.length);
    }
    final base = mediaBaseUrl.endsWith('/') ? mediaBaseUrl : '$mediaBaseUrl/';
    return '$base$relative';
  }

  static bool isNetworkUrl(String? path) {
    final resolved = resolve(path);
    if (resolved == null || resolved.isEmpty) return false;
    return resolved.startsWith('http://') || resolved.startsWith('https://');
  }
}
