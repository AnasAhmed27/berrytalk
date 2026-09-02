enum AppPermission {
  liveChatManager('LIVE-CHAT-MANAGER'),
  chatBotManager('CHAT-BOT-MANAGER'),
  liveChatagent('LIVE-CHAT-AGENT'),
  agent('AGENT');

  final String value;
  const AppPermission(this.value);
}