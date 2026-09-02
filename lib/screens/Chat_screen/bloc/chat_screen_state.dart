part of 'chat_screen_bloc.dart';

@immutable
sealed class ChatState {}

sealed class ChatActionState extends ChatState {}

final class ChatInitialState extends ChatState {}

final class ForceLogoutActionState extends ChatActionState {}

final class BackPressActionState extends ChatActionState {}

final class LoadingState extends ChatState {}

final class LoadingSuccessState extends ChatActionState {}

final class LoadingErrorState extends ChatActionState {
  final String errorTitle;
  final String errorMsg;
  LoadingErrorState({required this.errorTitle, required this.errorMsg});
}

class UpdateChatStatusLoadingState extends ChatState {}

class UpdateChatStatusSuccessActionState extends ChatActionState {
  final String message;
  UpdateChatStatusSuccessActionState({required this.message});
}

class UpdateChatStatusErrorActionState extends ChatActionState {
  final String errorTitle;
  final String errorMsg;
  UpdateChatStatusErrorActionState({
    required this.errorTitle,
    required this.errorMsg,
  });
}

class ChatTransferSuccessActionState extends ChatActionState {
  final String message;
  ChatTransferSuccessActionState({required this.message});
}

class ChatTransferErrorActionState extends ChatActionState {
  final String error;
  ChatTransferErrorActionState({required this.error});
}

class SendMessageLoadingActionState extends ChatState {}

class SendMessageSuccessActionState extends ChatState {
  final String message;
  SendMessageSuccessActionState({required this.message});
}

class SendMessageErrorActionState extends ChatActionState {
  final String error;
  SendMessageErrorActionState({required this.error});
}

final class ChatHistoryLoadingState extends ChatState {}

class TeamContactsLoadingState extends ChatState {}

class TeamContactsLoadedState extends ChatState {
  final List<TeamContactData> teamMembers;
  TeamContactsLoadedState(this.teamMembers);
}

class TeamContactsErrorState extends ChatState {
  final String errorMessage;
  TeamContactsErrorState(this.errorMessage);
}

final class OpenCustomerProfileActionState extends ChatActionState {}

// ignore: must_be_immutable
class ChatDataLoadedState extends ChatState {
  final InboxMessage? replyingToMessage;
  final String? name;
  final SocialPlatform? platform;
  final bool showEmojiPicker;
  final List<File> selectedFiles;
  final ConversationData? conversation;
  final List<InboxMessage> messages;
  final String formattedTime;
  final bool isWindowClosed;
  final bool isRecording;
  final bool isRecordingLocked;
  final bool hasRecordedPreview;
  final bool isPlayingPreview;
  final Duration recordingDuration;
  final Duration previewPosition;
  final Duration previewTotalDuration;
  final String? recordedFilePath;
  final Map<String, bool> playingAudios;
  final Map<String, Duration> audioPositions;
  final Map<String, Duration> audioDurations;
  final Map<String, double> audioProgressMap;
  final Map<String, bool> audioDraggingMap;
  final int? currentlyPlayingIndex;
  final int currentPage;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final bool isOtherUserTyping;
  final Map<String, String> messageReactions;
  final List<double> recordedSamples;

  ChatDataLoadedState({
    this.replyingToMessage,
    this.name,
    this.platform,
    required this.showEmojiPicker,
    required this.selectedFiles,
    this.conversation,
    this.messages = const [],
    this.formattedTime = "00h 00m 00s",
    this.isWindowClosed = false,
    this.isRecording = false,
    this.isRecordingLocked = false,
    this.hasRecordedPreview = false,
    this.isPlayingPreview = false,
    this.recordingDuration = Duration.zero,
    this.previewPosition = Duration.zero,
    this.previewTotalDuration = Duration.zero,
    this.recordedFilePath,
    this.playingAudios = const {},
    this.audioPositions = const {},
    this.audioDurations = const {},
    this.audioProgressMap = const {},
    this.audioDraggingMap = const {},
    this.currentlyPlayingIndex,
    this.currentPage = 0,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.isOtherUserTyping = false,
    this.messageReactions = const {},
    this.recordedSamples = const [],
  });

  ChatDataLoadedState copyWith({
    InboxMessage? replyingToMessage,
    bool clearReply = false,
    String? name,
    SocialPlatform? platform,
    bool? showEmojiPicker,
    List<File>? selectedFiles,
    ConversationData? conversation,
    List<InboxMessage>? messages,
    String? formattedTime,
    bool? isWindowClosed,
    bool? isRecording,
    bool? isRecordingLocked,
    bool? hasRecordedPreview,
    bool? isPlayingPreview,
    Duration? recordingDuration,
    Duration? previewPosition,
    Duration? previewTotalDuration,
    String? recordedFilePath,
    Map<String, bool>? playingAudios,
    Map<String, Duration>? audioPositions,
    Map<String, Duration>? audioDurations,
    Map<String, double>? audioProgressMap,
    Map<String, bool>? audioDraggingMap,
    int? currentlyPlayingIndex,
    int? currentPage,
    bool? hasReachedMax,
    bool? isLoadingMore,
    bool? isOtherUserTyping,
    Map<String, String>? messageReactions,
    List<double>? recordedSamples,
  }) {
    return ChatDataLoadedState(
    //   replyingToMessage: replyingToMessage != null 
    // ? replyingToMessage 
    // : this.replyingToMessage,
     replyingToMessage: clearReply
          ? null
          : (replyingToMessage ?? this.replyingToMessage),
      name: name ?? this.name,
      platform: platform ?? this.platform,
      showEmojiPicker: showEmojiPicker ?? this.showEmojiPicker,
      selectedFiles: selectedFiles ?? this.selectedFiles,
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      formattedTime: formattedTime ?? this.formattedTime,
      isRecording: isRecording ?? this.isRecording,
      isWindowClosed: isWindowClosed ?? this.isWindowClosed,
      isRecordingLocked: isRecordingLocked ?? this.isRecordingLocked,
      hasRecordedPreview: hasRecordedPreview ?? this.hasRecordedPreview,
      isPlayingPreview: isPlayingPreview ?? this.isPlayingPreview,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      previewPosition: previewPosition ?? this.previewPosition,
      previewTotalDuration: previewTotalDuration ?? this.previewTotalDuration,
      recordedFilePath: recordedFilePath ?? this.recordedFilePath,
      playingAudios: playingAudios ?? this.playingAudios,
      audioPositions: audioPositions ?? this.audioPositions,
      audioDurations: audioDurations ?? this.audioDurations,
      audioProgressMap: audioProgressMap ?? this.audioProgressMap,
      audioDraggingMap: audioDraggingMap ?? this.audioDraggingMap,
      currentlyPlayingIndex: currentlyPlayingIndex ?? this.currentlyPlayingIndex,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isOtherUserTyping: isOtherUserTyping ?? this.isOtherUserTyping,
      messageReactions: messageReactions ?? this.messageReactions,
      recordedSamples: recordedSamples ?? this.recordedSamples,
    );
  }
}
