/// Single place to switch staging / production API host.
///
/// Used by [ApiService], [MediaUrlResolver], and the websocket client.
class ApiConfig {
  /// Change only this when moving environments (staging ↔ production).
  static const String hostName = 'qaomni.convexinteractive.com';

  static const String host = 'https://$hostName';

  /// Retrofit / Dio REST base (`…/api`).
  static const String apiBaseUrl = '$host/api';

  /// Prefix for relative media paths like `assets/123.ogg`.
  /// Portal/staging serve files at `{host}/node/assets/{filename}`.
  static const String mediaBaseUrl = '$host/node/assets';

  /// WebSocket endpoint on the same host.
  static const String socketUrl = 'wss://$hostName/api/socket';
}
