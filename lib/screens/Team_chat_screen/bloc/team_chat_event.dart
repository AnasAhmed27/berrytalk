part of 'team_chat_bloc.dart';

@immutable
sealed class TeamChatEvent {}

final class TeamChatInitialEvent extends TeamChatEvent {}

final class BackPressActionEvent extends TeamChatEvent {}

final class LoadingEvent extends TeamChatEvent {}

final class LoadingSuccessEvent extends TeamChatEvent {}

final class LoadingErrorEvent extends TeamChatEvent {
  final String errorTitle;
  final String errorMsg;
  LoadingErrorEvent({required this.errorTitle, required this.errorMsg});
}

final class InitTeamChatEvent extends TeamChatEvent {
  final String name;
  final String recipientAgentId;
   final DesigantionStatus desStatus;
   

  InitTeamChatEvent({required this.name, required this.recipientAgentId,required this.desStatus});
}

final class ToggleEmojiPickerEvent extends TeamChatEvent {}

class UpdateSelectedFilesEvent extends TeamChatEvent {
  final List<File> files;
  UpdateSelectedFilesEvent(this.files);
}

final class OpenTeamChatEvent extends TeamChatEvent{}

class SendTeamMessageEvent extends TeamChatEvent {
  final String type; 
  final String textBody;
  final String name;
  final String recipientAgentId;
  final File? file;

  SendTeamMessageEvent({
    required this.type,
    required this.textBody,
    required this.name,
    required this.recipientAgentId,
    this.file,
  });
}

class FetchTeamChatHistoryEvent extends TeamChatEvent {
  final String recipientAgentId;
  final String name; 
  final DesigantionStatus desStatus; 
  final int page;
  final int size;

  FetchTeamChatHistoryEvent({
    required this.recipientAgentId,
    required this.name,
    required this.desStatus,
    this.page = 0,
    this.size = 20,
  });
}

final class ForceLogoutEvent extends TeamChatEvent {}

class TogglePreviewPlaybackEvent extends TeamChatEvent {}

class CancelRecordingEvent extends TeamChatEvent {}

class LockRecordingEvent extends TeamChatEvent {}

class StartRecordingEvent extends TeamChatEvent {}

class UpdateRecordingTimerEvent extends TeamChatEvent {
  final Duration duration;
  UpdateRecordingTimerEvent(this.duration);
}

class StopAndPreviewRecordingEvent extends TeamChatEvent {
  final String filePath;
  StopAndPreviewRecordingEvent(this.filePath);
}

class UpdatePreviewPositionEvent extends TeamChatEvent {
  final Duration position;
  final Duration duration;
  UpdatePreviewPositionEvent(this.position, this.duration);
}

class ToggleAudioPlaybackEvent extends TeamChatEvent {
  final String filePath;
   ToggleAudioPlaybackEvent(this.filePath);
}

class UpdateAudioPositionEvent extends TeamChatEvent {
  final String filePath;
  final Duration position;
   UpdateAudioPositionEvent(this.filePath, this.position);
}

class UpdateAudioDurationEvent extends TeamChatEvent {
  final String filePath;
  final Duration duration;
   UpdateAudioDurationEvent(this.filePath, this.duration);
}

class AudioPlaybackCompletedEvent extends TeamChatEvent {
  final String filePath;
   AudioPlaybackCompletedEvent(this.filePath);
}

class DownloadDocumentEvent extends TeamChatEvent {
  final String filePath;
  final String fileName;
  final BuildContext context; 

  DownloadDocumentEvent({
    required this.filePath,
    required this.fileName,
    required this.context,
  });
}

