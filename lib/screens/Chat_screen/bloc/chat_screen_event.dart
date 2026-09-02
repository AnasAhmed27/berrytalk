part of 'chat_screen_bloc.dart';

@immutable
sealed class ChatEvent {}

final class ChatInitialEvent extends ChatEvent {}

final class ForceLogoutEvent extends ChatEvent {}

final class BackPressActionEvent extends ChatEvent {}

class StartRecordingEvent extends ChatEvent {}

class LockRecordingEvent extends ChatEvent {}

class CancelRecordingEvent extends ChatEvent {}

class StopAndPreviewRecordingEvent extends ChatEvent {
  final String filePath;
  StopAndPreviewRecordingEvent(this.filePath);
}
class TogglePreviewPlaybackEvent extends ChatEvent {}

class UpdatePreviewPositionEvent extends ChatEvent {
  final Duration position;
  final Duration duration;
  UpdatePreviewPositionEvent(this.position, this.duration);
}

class UpdateRecordingTimerEvent extends ChatEvent {
  final Duration duration;
  UpdateRecordingTimerEvent(this.duration);
}

class AmplitudeChangedEvent extends ChatEvent {
  final double amplitude;
  AmplitudeChangedEvent(this.amplitude);
}

class ResumeRecordingEvent extends ChatEvent {}


final class LoadingEvent extends ChatEvent {}

final class LoadingSuccessEvent extends ChatEvent {}

final class LoadingErrorEvent extends ChatEvent {
  final String errorTitle;
  final String errorMsg;
  LoadingErrorEvent({required this.errorTitle, required this.errorMsg});
}

final class UpdateChatStatusEvent extends ChatEvent {
  final String chatStatus;
  final String companyId;
  final String currentAgentId;
  final String phoneNumber;
  final String conversationId;

  UpdateChatStatusEvent({
    required this.chatStatus,
    required this.companyId,
    required this.currentAgentId,
    required this.phoneNumber,
    required this.conversationId,
  });
}

final class UpdateChatStatusLoadingEvent extends ChatEvent {}

final class UpdateChatStatusSuccessEvent extends ChatEvent {
  final String message;
  UpdateChatStatusSuccessEvent({required this.message});
}

final class UpdateChatStatusErrorEvent extends ChatEvent {
  final String errorTitle;
  final String errorMsg;
  UpdateChatStatusErrorEvent({required this.errorTitle, required this.errorMsg});
}

class DownloadDocumentEvent extends ChatEvent {
  final String filePath;
  final String fileName;
  final BuildContext context; 

  DownloadDocumentEvent({
    required this.filePath,
    required this.fileName,
    required this.context,
  });
}

final class FetchChatDetailsEvent extends ChatEvent {
  final String number;
  final String companyPublicId;
  final String agentId;
  final String channelId;
  final bool isSilent;
  final bool isLoadMore;
  final int page;

  FetchChatDetailsEvent({
    required this.number,
    required this.companyPublicId,
    required this.agentId,
    required this.channelId,
    this.isSilent = false,
    this.isLoadMore = false,
    this.page = 0,
  });
}

/// A real-time message pushed over the socket (`send-message-data-response`).
/// [data] is the raw `data` object from the socket payload.
final class IncomingChatMessageEvent extends ChatEvent {
  final Map<String, dynamic> data;

  IncomingChatMessageEvent({required this.data});
}

final class InitChatEvent extends ChatEvent {
  final String name;
   final SocialPlatform platform;
   

  InitChatEvent({required this.name, required this.platform});
}

final class ToggleEmojiPickerEvent extends ChatEvent {}

class UpdateSelectedFilesEvent extends ChatEvent {
  final List<File> files;
  UpdateSelectedFilesEvent(this.files);
}

final class OpenCustomerProfileEvent extends ChatEvent{}

class StartChatWindowTimerEvent extends ChatEvent {
  final DateTime expiryTime;
  StartChatWindowTimerEvent({required this.expiryTime});
}


class FetchTeamContactsEvent extends ChatEvent {
  final int page;
  FetchTeamContactsEvent({this.page = 1});
}
class SelectAgentFromSheetEvent extends ChatEvent {
  final dynamic selectedAgent; 
  SelectAgentFromSheetEvent({required this.selectedAgent});
}

class _TimerTickEvent extends ChatEvent {
  final Duration remainingTime;
  _TimerTickEvent({required this.remainingTime});
}

class SubmitTransferChatEvent extends ChatEvent {
  final String assignAgentId;
  final String channelId;
  final String companyId;
  final String currentAgentId;
  final String phoneNumber;

  SubmitTransferChatEvent({
    required this.assignAgentId,
    required this.channelId,
    required this.companyId,
    required this.currentAgentId,
    required this.phoneNumber,
  });
}

class SendMessageEvent extends ChatEvent {
  final String type;
  final String phoneNumber;
  final String textBody;
  final String recipientNumber;
  final String chanelId;
  final String name;
  final String agentId;
  final String conversationId;
  final String companyPublicId;
  final List<File> files;
  final String clientMsgId;
  final String? replyMessageId;
  final String? replyToPublicId;

  SendMessageEvent({
    required this.type,
    required this.phoneNumber,
    required this.textBody,
    required this.recipientNumber,
    required this.chanelId,
    required this.name,
    required this.agentId,
    required this.conversationId,
    required this.companyPublicId,
    this.files = const [],
    String? clientMsgId,
    this.replyMessageId,
    this.replyToPublicId,
  }): clientMsgId = clientMsgId ?? "msg_${DateTime.now().millisecondsSinceEpoch}";
}

class SyncPendingMessagesEvent extends ChatEvent {}

class ToggleAudioPlaybackEvent extends ChatEvent {
  final String filePath;
   ToggleAudioPlaybackEvent(this.filePath);
}

class UpdateAudioPositionEvent extends ChatEvent {
  final String filePath;
  final Duration position;
   UpdateAudioPositionEvent(this.filePath, this.position);
}

class UpdateAudioDurationEvent extends ChatEvent {
  final String filePath;
  final Duration duration;
   UpdateAudioDurationEvent(this.filePath, this.duration);
}

class AudioPlaybackCompletedEvent extends ChatEvent {
  final String filePath;
   AudioPlaybackCompletedEvent(this.filePath);
}

class AudioMessageFinishedEvent extends ChatEvent {
  final int finishedIndex;
  AudioMessageFinishedEvent({required this.finishedIndex});
}

final class RestoreChatStateEvent extends ChatEvent {}

final class TypingIndicatorEvent extends ChatEvent {
  final bool isTyping;
  TypingIndicatorEvent({required this.isTyping});
}


final class SetReplyMessageEvent extends ChatEvent {
  final InboxMessage? replyMessage; 
  SetReplyMessageEvent({this.replyMessage});
}

class CancelReplyEvent extends ChatEvent {}

final class ReactToMessageEvent extends ChatEvent {
  final String messagePublicId;
  final String? reaction; 
   ReactToMessageEvent({
    required this.messagePublicId,
    this.reaction,
  });
}