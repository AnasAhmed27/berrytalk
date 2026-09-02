/// Well-known socket message `type` values from the Omni server.
///
/// Screens should filter on these constants instead of scattering raw strings
/// across the app (WhatsApp/Slack-style typed event routing).
abstract final class SocketMessageType {
  // events listeners for socket
  static const authRequest = 'auth-request';
  static const authStatus = 'auth-status';
  static const pingResponse = 'ping-response';
  static const notificationResponse = 'notification-response';
  static const sendMessageDataResponse = 'send-message-data-response';
  static const contactListUpdate = 'contact-list-update';

  // send messages for socket
  static const auth = 'auth';
  static const ping = 'ping';
  static const updateChatList = 'update-chat-list';
  static const subscribeChat = 'subscribe-chat';
  static const readMessage = 'read-message';


  // other events listeners and send messages for socket
  static const newMessage = 'new-message';
  static const messageStatus = 'message-status';
  static const typing = 'typing';
  static const error = 'error';
  static const raw = 'raw';
  static const stopTyping = 'stop-typing';
}
