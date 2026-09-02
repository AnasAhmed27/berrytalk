part of 'team_chat_bloc.dart';

@immutable
sealed class TeamChatState {}

sealed class TeamChatActionState extends TeamChatState {}

final class TeamChatInitialState extends TeamChatState {}

final class BackPressActionState extends TeamChatActionState {}

final class LoadingState extends TeamChatState {}

final class LoadingSuccessState extends TeamChatActionState {}

final class ForceLogoutActionState extends TeamChatState {}

final class LoadingErrorState extends TeamChatActionState {
  final String errorTitle;
  final String errorMsg;
  LoadingErrorState({required this.errorTitle, required this.errorMsg});
}

final class TeamChatHistoryLoadingState extends TeamChatState {}

final class TeamChatHistoryErrorState extends TeamChatState {
  final String errorMessage;
  TeamChatHistoryErrorState({required this.errorMessage});
}

final class OpenTeamChatActionState extends TeamChatActionState {}

class TeamChatDataLoadedState extends TeamChatState {
  final String name;
  final DesigantionStatus desStatus;
  final String recipientAgentId;
  final bool showEmojiPicker;
  final List<File> selectedFiles;
  final List<TeamMessage> messages;
  final bool hasReachedMax;
  final int currentPage;
  final bool isLoadingMore;
  final Duration previewTotalDuration;
  final Duration previewPosition;
  final bool isPlayingPreview;
  final Duration recordingDuration;
  final String? recordedFilePath;
  final bool isRecordingLocked;
  final bool isRecording;
  final bool hasRecordedPreview;
  final Map<String, bool> playingAudios;
  final Map<String, Duration> audioPositions;
  final Map<String, Duration> audioDurations;

  TeamChatDataLoadedState({
    required this.name,
    required this.recipientAgentId,
    required this.desStatus,
    this.showEmojiPicker = false,
    this.selectedFiles = const [],
    this.messages = const [],
    this.hasReachedMax = false,
    this.currentPage = 0,
    this.isLoadingMore = false,
    this.previewTotalDuration = Duration.zero,
    this.previewPosition = Duration.zero,
    this.isPlayingPreview = false,
    this.recordingDuration = Duration.zero,
    this.recordedFilePath,
    this.isRecordingLocked = false,
    this.isRecording = false,
    this.hasRecordedPreview = false,
    this.playingAudios = const {},
    this.audioPositions = const {},
    this.audioDurations = const {},
  });

  TeamChatDataLoadedState copyWith({
    String? name,
    String? recipientAgentId,
    DesigantionStatus? desStatus,
    bool? showEmojiPicker,
    List<File>? selectedFiles,
    List<TeamMessage>? messages,
    bool? hasReachedMax,
    int? currentPage,
    bool? isLoadingMore,
    Duration? previewTotalDuration,
    Duration? previewPosition,
    bool? isPlayingPreview,
    Duration? recordingDuration,
    String? recordedFilePath,
    bool? isRecordingLocked,
    bool? isRecording,
    bool? hasRecordedPreview,
    Map<String, bool>? playingAudios,
    Map<String, Duration>? audioPositions,
    Map<String, Duration>? audioDurations,
  }) {
    return TeamChatDataLoadedState(
      name: name ?? this.name,
      desStatus: desStatus ?? this.desStatus,
      recipientAgentId: recipientAgentId ?? this.recipientAgentId,
      showEmojiPicker: showEmojiPicker ?? this.showEmojiPicker,
      selectedFiles: selectedFiles ?? this.selectedFiles,
      messages: messages ?? this.messages,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      previewTotalDuration: previewTotalDuration ?? this.previewTotalDuration,
      previewPosition: previewPosition ?? this.previewPosition,
      isPlayingPreview: isPlayingPreview ?? this.isPlayingPreview,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      recordedFilePath: recordedFilePath ?? this.recordedFilePath,
      isRecordingLocked: isRecordingLocked ?? this.isRecordingLocked,
      isRecording: isRecording ?? this.isRecording,
      hasRecordedPreview: hasRecordedPreview ?? this.hasRecordedPreview,
      playingAudios: playingAudios ?? this.playingAudios,
      audioPositions: audioPositions ?? this.audioPositions,
      audioDurations: audioDurations ?? this.audioDurations,
    );
  }
}
