import 'dart:developer' as developer;
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:berrytalks/Widgets_Component/Utils/AppUitilities.dart';
import 'package:berrytalks/Widgets_Component/Utils/MediaAttachmentPolicy.dart';
import 'package:berrytalks/Widgets_Component/Utils/MediaUrlResolver.dart';
import 'package:berrytalks/main.dart';
import 'package:berrytalks/network/ApiClient.dart';
import 'package:berrytalks/services/storage/LocalDatabaseHelper.dart';
import 'package:berrytalks/services/storage/SharedPrefrences.dart';
import 'package:dio/dio.dart';

import 'package:berrytalks/Widgets_Component/Enum/enum.dart';
import 'package:berrytalks/network/ApiService.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../network_calls/chatScreen_api_call.dart';

part 'chat_screen_event.dart';
part 'chat_screen_state.dart';

class _MediaKind {
  final String stream;
  final String messageType;
  final String body;

  const _MediaKind({
    required this.stream,
    required this.messageType,
    required this.body,
  });
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
   ChatDataLoadedState? _lastLoadedState;
  Timer? _countdownTimer;
  final ChatDetailsApiCall _apiCall = ChatDetailsApiCall();
  final ChatDetailsApiCall _chatStatusApiCall = ChatDetailsApiCall();

  final List<TeamContactData> _activeChats = [];
  List<TeamContactData> _directoryAgents = [];
  List<TeamContactData> get directoryAgents => _directoryAgents;
  final AudioRecorder _recorder = AudioRecorder();
  Timer? _audioTimer;
  Timer? _typingTimer;

  ChatBloc() : super(ChatInitialState()) {
    on<ChatInitialEvent>(_onChatInitialEvent);
    on<BackPressActionEvent>(_onBackPressActionEvent);
    on<LoadingEvent>(_onLoadingEvent);
    on<LoadingSuccessEvent>(_onLoadingSuccessEvent);
    on<LoadingErrorEvent>(_onLoadingErrorEvent);
    on<InitChatEvent>(_onInitChatEvent);
    on<ToggleEmojiPickerEvent>(_onToggleEmojiPickerEvent);
    on<UpdateSelectedFilesEvent>(_onUpdateSelectedFiles);
    on<OpenCustomerProfileEvent>(_onOpenCustomerProfileEvent);
    on<StartChatWindowTimerEvent>(_onStartTimer);
    on<_TimerTickEvent>(_onTick);
    on<FetchChatDetailsEvent>(_onFetchChatDetailsEvent);
    on<IncomingChatMessageEvent>(_onIncomingChatMessageEvent);
    on<DownloadDocumentEvent>(_onDownloadDocumentEvent);
    on<SubmitTransferChatEvent>(_onSubmitTransferChatEvent);
    on<FetchTeamContactsEvent>(_onFetchTeamContactsEvent);
    on<SelectAgentFromSheetEvent>(_onSelectAgentFromSheetEvent);
    on<SendMessageEvent>(_onSendMessageEvent);
    on<UpdateChatStatusEvent>(_onUpdateChatStatusEvent);
    on<UpdateChatStatusLoadingEvent>(_onUpdateChatStatusLoadingEvent);
    on<UpdateChatStatusSuccessEvent>(_onUpdateChatStatusSuccessEvent);
    on<UpdateChatStatusErrorEvent>(_onUpdateChatStatusErrorEvent);
    on<ForceLogoutEvent>(_onForceLogoutEvent);
    on<StartRecordingEvent>(_onStartRecording);
    on<LockRecordingEvent>(_onLockRecording);
    on<CancelRecordingEvent>(_onCancelRecording);
    on<StopAndPreviewRecordingEvent>(_onStopAndPreviewRecording);
    on<TogglePreviewPlaybackEvent>(_onTogglePreviewPlayback);
    on<UpdatePreviewPositionEvent>(_onUpdatePreviewPosition);
    on<UpdateRecordingTimerEvent>(_onUpdateRecordingTimer);
    on<AmplitudeChangedEvent>(_onRecordingAmplitudeChanged);
    on<ResumeRecordingEvent>(_onResumeRecording);
    on<ToggleAudioPlaybackEvent>(_onToggleAudioPlayback);
    on<UpdateAudioPositionEvent>(_onUpdateAudioPosition);
    on<UpdateAudioDurationEvent>(_onUpdateAudioDuration);
    on<AudioPlaybackCompletedEvent>(_onAudioPlaybackCompleted);
   on<SyncPendingMessagesEvent>(_onSyncPendingMessages);
    on<RestoreChatStateEvent>(_onRestoreChatState);
    on<TypingIndicatorEvent>(_onTypingIndicator);
    on<SetReplyMessageEvent>(_onSetReplyMessage);
    on<CancelReplyEvent>(_onCancelReply);
    on<ReactToMessageEvent>(_onReactToMessage);
  }

//   FutureOr<void> _onSetReplyMessage(
//   SetReplyMessageEvent event,
//   Emitter<ChatState> emit,
// ) {
//   if (state is ChatDataLoadedState) {
//     final currentState = state as ChatDataLoadedState;
//     emit(currentState.copyWith(replyMessage: event.message));
//   }
// }

FutureOr<void> _onReactToMessage(
  ReactToMessageEvent event,
  Emitter<ChatState> emit,
) async {
  if (state is! ChatDataLoadedState) return;
  final currentState = state as ChatDataLoadedState;

  final updatedReactions =
      Map<String, String>.from(currentState.messageReactions);

  if (event.reaction == null) {
    updatedReactions.remove(event.messagePublicId);
    await LocalDatabaseHelper.instance.removeReaction(event.messagePublicId);
  } else {
    updatedReactions[event.messagePublicId] = event.reaction!;
    await LocalDatabaseHelper.instance.saveReaction(
      event.messagePublicId,
      event.reaction!,
    );
  }

  _lastLoadedState =
      currentState.copyWith(messageReactions: updatedReactions);
  emit(_lastLoadedState!);
}

// FutureOr<void> _onSetReplyMessage(
//   SetReplyMessageEvent event,
//   Emitter<ChatState> emit,
// ) {
//   if (state is! ChatDataLoadedState) return Future.value();
//   final currentState = state as ChatDataLoadedState;
//   _lastLoadedState = currentState.copyWith(
//     replyingToMessage: event.replyMessage,
//     clearReply: event.replyMessage == null,
//   );
//   emit(_lastLoadedState!);
// }

FutureOr<void> _onSetReplyMessage(
  SetReplyMessageEvent event,
  Emitter<ChatState> emit,
) {
  if (state is! ChatDataLoadedState);
  final currentState = state as ChatDataLoadedState;

  final newState = currentState.copyWith(
    replyingToMessage: event.replyMessage,
    clearReply: event.replyMessage == null,
  );
  _lastLoadedState = newState;
  emit(newState);
}

// FutureOr<void> _onSetReplyMessage(
//   SetReplyMessageEvent event,
//   Emitter<ChatState> emit,
// ) {
//   if (state is! ChatDataLoadedState) ;
//   final currentState = state as ChatDataLoadedState;

//   _lastLoadedState = ChatDataLoadedState(
//     name: currentState.name,
//     platform: currentState.platform,
//     showEmojiPicker: currentState.showEmojiPicker,
//     selectedFiles: currentState.selectedFiles,
//     conversation: currentState.conversation,
//     messages: currentState.messages,
//     currentPage: currentState.currentPage,
//     hasReachedMax: currentState.hasReachedMax,
//     isLoadingMore: currentState.isLoadingMore,
//     formattedTime: currentState.formattedTime,
//     isWindowClosed: currentState.isWindowClosed,
//     isRecording: currentState.isRecording,
//     isRecordingLocked: currentState.isRecordingLocked,
//     hasRecordedPreview: currentState.hasRecordedPreview,
//     isPlayingPreview: currentState.isPlayingPreview,
//     recordingDuration: currentState.recordingDuration,
//     previewPosition: currentState.previewPosition,
//     previewTotalDuration: currentState.previewTotalDuration,
//     recordedFilePath: currentState.recordedFilePath,
//     playingAudios: currentState.playingAudios,
//     audioPositions: currentState.audioPositions,
//     audioDurations: currentState.audioDurations,
//     messageReactions: currentState.messageReactions,
//     isOtherUserTyping: currentState.isOtherUserTyping,
//     replyingToMessage: event.replyMessage, // <-- null ya message
//   );
//   emit(_lastLoadedState!);
// }

FutureOr<void> _onCancelReply(
  CancelReplyEvent event,
  Emitter<ChatState> emit,
) {
  if (state is ChatDataLoadedState) {
    final currentState = state as ChatDataLoadedState;
    emit(currentState.copyWith(clearReply: true));
  }
}

 FutureOr<void> _onTypingIndicator(
  TypingIndicatorEvent event,
  Emitter<ChatState> emit,
) async {
  if (state is! ChatDataLoadedState) return;
  final currentState = state as ChatDataLoadedState;

  _typingTimer?.cancel();
  _typingTimer = null;

  emit(currentState.copyWith(isOtherUserTyping: event.isTyping));

  if (event.isTyping) {
    _typingTimer = Timer(const Duration(seconds: 3), () {
      if (!isClosed) {
        add(TypingIndicatorEvent(isTyping: false)); 
      }
    });
  }
}

  FutureOr<void> _onRestoreChatState(
  RestoreChatStateEvent event,
  Emitter<ChatState> emit,
) async {
  if (_lastLoadedState != null) {
    emit(_lastLoadedState!);
    return;
  }
  
  add(FetchChatDetailsEvent(
    number: '',
    companyPublicId: '',
    agentId: '',
    channelId: '',
    page: 0,
    isSilent: true,
  ));
}

   FutureOr<void> _onSyncPendingMessages(
  SyncPendingMessagesEvent event,
  Emitter<ChatState> emit,
) async {
  final pendingMessages = await LocalDatabaseHelper.instance.getPendingMessages();

  if (pendingMessages.isEmpty) return;

  developer.log("[ChatBloc] Syncing ${pendingMessages.length} pending messages...");

  for (final row in pendingMessages) {
    final clientMsgId = row['client_msg_id'] as String;
    final messageType = row['message_type'] as String? ?? 'text';
    final hasFile = row['file_path'] != null &&
        (row['file_path'] as String).isNotEmpty &&
        messageType != 'text';

    try {
      String? uploadedFileId = row['file_id'] as String?;

      if (hasFile && (uploadedFileId == null || uploadedFileId.isEmpty)) {
        final filePath = row['file_path'] as String;
        final mediaStream = row['media_stream'] as String? ?? 'document';
        final agentId = row['agent_id'] as String? ?? '';
        final channelId = row['channel_id'] as String? ?? '';

        final uploadResponse = await _apiCall.uploadChatDocument(
          filePath: filePath,
          agentPublicId: agentId,
          companyId: '', // conversation se milega agar chahiye
          channelId: channelId,
          mediaStream: mediaStream,
        );

        final uploadResult = uploadResponse?.results?.isNotEmpty == true
            ? uploadResponse!.results!.first
            : null;

        if (uploadResult == null || uploadResult.success != true || uploadResult.fileId == null) {
          developer.log("[ChatBloc] Sync upload failed for $clientMsgId");
          continue; // is message ko skip karo, agli baar try hoga
        }

        uploadedFileId = uploadResult.fileId;
      }

      final sendResponse = await _apiCall.sendMessage(
        type: hasFile ? 'media' : 'text',
        phoneNumber: row['contact_number'] as String? ?? '',
        textBody: row['body'] as String? ?? '',
        fileId: uploadedFileId,
        mediaStream: row['media_stream'] as String?,
        recipientNumber: row['recipient_number'] as String? ?? '',
        chanelId: row['channel_id'] as String? ?? '',
        name: row['name'] as String? ?? '',
        agentId: row['agent_id'] as String? ?? '',
        conversationId: row['conversation_id'] as String? ?? '',
      );

      if (sendResponse.success) {
        await LocalDatabaseHelper.instance.updateMessageSyncStatus(
          clientMsgId,
          isSuccess: true,
        );
        _updateUiMessageStatus(clientMsgId, 'SENT');
        developer.log("✅ [SEND] Success: $clientMsgId");
        developer.log("[ChatBloc] Synced message: $clientMsgId");
      } else {
        developer.log("[ChatBloc] Sync send failed for $clientMsgId: ${sendResponse.message}");
      }
    } catch (e) {
      developer.log("[ChatBloc] Sync exception for $clientMsgId: $e");
    }
  }
}


//Helper to update individual message status in UI without re-fetching whole API
void _updateUiMessageStatus(String clientMsgId, String status) {
  if (state is ChatDataLoadedState) {
    final currentState = state as ChatDataLoadedState;
    final index = currentState.messages.indexWhere((m) => m.messageId == clientMsgId || m.id == clientMsgId);
    
    if (index != -1) {
      final updatedList = List<InboxMessage>.from(currentState.messages);
      final currentMsg = updatedList[index];
      
      updatedList[index] = InboxMessage(
        id: currentMsg.id,
        messageId: currentMsg.messageId,
        messageType: currentMsg.messageType,
        contactNumber: currentMsg.contactNumber,
        body: currentMsg.body,
        timestamp: currentMsg.timestamp,
        contactName: currentMsg.contactName,
        recipientNumber: currentMsg.recipientNumber,
        conversationId: currentMsg.conversationId,
        isSent: currentMsg.isSent,
        messageStatus: status,
        filePath: currentMsg.filePath,
        caption: currentMsg.caption,
      );

      // ignore: invalid_use_of_visible_for_testing_member
      emit(currentState.copyWith(messages: updatedList));
    }
  }
}

  FutureOr<void> _onToggleAudioPlayback(
    ToggleAudioPlaybackEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatDataLoadedState) {
      final currentState = state as ChatDataLoadedState;
      final bool currentlyPlaying =
          currentState.playingAudios[event.filePath] ?? false;

      // Only one voice note may be active at a time.
      final Map<String, bool> updatedPlaying = <String, bool>{};
      if (!currentlyPlaying) {
        updatedPlaying[event.filePath] = true;
      }

      emit(currentState.copyWith(playingAudios: updatedPlaying));
    }
  }

  FutureOr<void> _onUpdateAudioPosition(
    UpdateAudioPositionEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatDataLoadedState) {
      final currentState = state as ChatDataLoadedState;
      final Map<String, Duration> updatedPositions = Map.from(
        currentState.audioPositions,
      );
      updatedPositions[event.filePath] = event.position;
      emit(currentState.copyWith(audioPositions: updatedPositions));
    }
  }

  FutureOr<void> _onUpdateAudioDuration(
    UpdateAudioDurationEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatDataLoadedState) {
      final currentState = state as ChatDataLoadedState;
      final Map<String, Duration> updatedDurations = Map.from(
        currentState.audioDurations,
      );
      updatedDurations[event.filePath] = event.duration;
      emit(currentState.copyWith(audioDurations: updatedDurations));
    }
  }

  FutureOr<void> _onAudioPlaybackCompleted(
    AudioPlaybackCompletedEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatDataLoadedState) return;
    final currentState = state as ChatDataLoadedState;

    final bool wasActuallyPlaying =
        currentState.playingAudios[event.filePath] ?? false;
    if (!wasActuallyPlaying) return;

    final updatedPlaying = Map<String, bool>.from(currentState.playingAudios);
    final updatedPositions =
        Map<String, Duration>.from(currentState.audioPositions);
    updatedPlaying[event.filePath] = false;
    updatedPositions[event.filePath] = Duration.zero;

    // Stop only — do not auto-chain into the next voice note (that caused
    // duplicate bubbles to start playing together).
    emit(
      currentState.copyWith(
        playingAudios: updatedPlaying,
        audioPositions: updatedPositions,
      ),
    );
  }



FutureOr<void> _onStartRecording(
  StartRecordingEvent event,
  Emitter<ChatState> emit,
) {
  if (state is ChatDataLoadedState) {
    final currentState = state as ChatDataLoadedState;
    
    _lastLoadedState = currentState.copyWith(
      isRecording: true,
      isRecordingLocked: false,
      hasRecordedPreview: false,
      isPlayingPreview: false,
      recordingDuration: Duration.zero,
      recordedSamples: const [],
      recordedFilePath: null,
    );

    emit(_lastLoadedState!);
  }
}
  FutureOr<void> _onLockRecording(
    LockRecordingEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatDataLoadedState) {
      final currentState = state as ChatDataLoadedState;
      emit(currentState.copyWith(isRecordingLocked: true));
    }
  }



FutureOr<void> _onCancelRecording(
  CancelRecordingEvent event,
  Emitter<ChatState> emit,
) async {
  if (state is! ChatDataLoadedState) return;
  final currentState = state as ChatDataLoadedState;

  // 1. Audio Recording safely stop aur cleanup karein
  try {
    if (await _recorder.isRecording() || await _recorder.isPaused()) {
      await _recorder.stop();
    }
  } catch (e) {
    // Exception silent rakhein taaki UI par fail state trigger na ho
    developer.log("[ChatBloc] Audio recorder clean reset on cancel: $e");
  }

  // 2. Clear state emit karein (Kisi kisam ki ActionState emit NAI karni)
  _lastLoadedState = currentState.copyWith(
    isRecording: false,
    isRecordingLocked: false,
    hasRecordedPreview: false,
    isPlayingPreview: false,
    recordingDuration: Duration.zero,
    previewPosition: Duration.zero,
    previewTotalDuration: Duration.zero,
    recordedFilePath: null,
    recordedSamples: const [],
  );

  emit(_lastLoadedState!);
}

  FutureOr<void> _onStopAndPreviewRecording(
    StopAndPreviewRecordingEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatDataLoadedState) {
      final currentState = state as ChatDataLoadedState;
      emit(
        currentState.copyWith(
          isRecording: false,
          isRecordingLocked: false,
          hasRecordedPreview: true,
          recordedFilePath: event.filePath,
        ),
      );
    }
  }

  FutureOr<void> _onTogglePreviewPlayback(
    TogglePreviewPlaybackEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatDataLoadedState) {
      final currentState = state as ChatDataLoadedState;
      emit(
        currentState.copyWith(isPlayingPreview: !currentState.isPlayingPreview),
      );
    }
  }

  FutureOr<void> _onUpdatePreviewPosition(
    UpdatePreviewPositionEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatDataLoadedState) {
      final currentState = state as ChatDataLoadedState;
      emit(
        currentState.copyWith(
          previewPosition: event.position,
          previewTotalDuration: event.duration,
        ),
      );
    }
  }

  FutureOr<void> _onUpdateRecordingTimer(
    UpdateRecordingTimerEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatDataLoadedState) {
      final currentState = state as ChatDataLoadedState;
      emit(currentState.copyWith(recordingDuration: event.duration));
    }
  }

  // Cap on how many waveform samples we keep, mirrors the WhatsAppVoiceBar
  // reference component.
  static const int _maxWaveformSamples = 200;

  /// Turns a raw normalized mic amplitude (0.0 - 1.0) into a WhatsApp-style
  /// waveform sample and appends it to state.recordedSamples. This is kept
  /// running across pause/resume (it is only reset in _onStartRecording /
  /// _onCancelRecording) so the waveform shows the WHOLE recording, not
  /// just the current segment.
  FutureOr<void> _onRecordingAmplitudeChanged(
    AmplitudeChangedEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatDataLoadedState) return null;
    final currentState = state as ChatDataLoadedState;

    final double rawAmp = event.amplitude.clamp(0.0, 1.0);
    // Noise threshold & dynamic amplitude contrast — same curve used by the
    // WhatsAppVoiceBar reference widget.
    final double processedSample =
        (rawAmp < 0.08) ? 0.0 : math.pow(rawAmp, 5.5).toDouble();

    final updatedSamples = List<double>.from(currentState.recordedSamples)
      ..add(processedSample);
    if (updatedSamples.length > _maxWaveformSamples) {
      updatedSamples.removeAt(0);
    }

    emit(currentState.copyWith(recordedSamples: updatedSamples));
  }

  /// User tapped "resume" on the paused/preview row. Only flips the UI
  /// flags back to "actively recording" — recordingDuration and
  /// recordedSamples are intentionally left untouched so the timer keeps
  /// counting up and the waveform keeps growing across the pause. The
  /// actual mic restart (new audio segment) happens in ChatBottomBar,
  /// which dispatches this event right after starting the new segment.
  FutureOr<void> _onResumeRecording(
    ResumeRecordingEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatDataLoadedState) return null;
    final currentState = state as ChatDataLoadedState;
    emit(
      currentState.copyWith(
        isRecording: true,
        isRecordingLocked: true,
        hasRecordedPreview: false,
        isPlayingPreview: false,
      ),
    );
  }

  FutureOr<void> _onForceLogoutEvent(
    ForceLogoutEvent event,
    Emitter<ChatState> emit,
  ) {
    print("[ChatBloc] Force logout triggered");
    emit(ForceLogoutActionState());
  }

  FutureOr<void> _onUpdateChatStatusEvent(
    UpdateChatStatusEvent event,
    Emitter<ChatState> emit,
  ) async {
    //add(UpdateChatStatusLoadingEvent());

    try {
      final response = await _chatStatusApiCall.updateChatStatus(
        chatStatus: event.chatStatus,
        companyId: event.companyId,
        currentAgentId: event.currentAgentId,
        phoneNumber: event.phoneNumber,
        conversationId: event.conversationId,
      );

      if (response.success) {
        add(
          UpdateChatStatusSuccessEvent(
            message: response.message ?? "Chat status updated successfully",
          ),
        );
      } else {
        add(
          UpdateChatStatusErrorEvent(
            errorTitle: "Status Update Failed",
            errorMsg: response.message ?? "Failed to update chat status",
          ),
        );
      }
    } catch (e) {
      add(
        UpdateChatStatusErrorEvent(
          errorTitle: "Error",
          errorMsg: "Something went wrong: $e",
        ),
      );
    }
  }

  FutureOr<void> _onUpdateChatStatusLoadingEvent(
    UpdateChatStatusLoadingEvent event,
    Emitter<ChatState> emit,
  ) {
    emit(UpdateChatStatusLoadingState());
  }

  FutureOr<void> _onUpdateChatStatusSuccessEvent(
    UpdateChatStatusSuccessEvent event,
    Emitter<ChatState> emit,
  ) {
    emit(UpdateChatStatusSuccessActionState(message: event.message));
  }

  FutureOr<void> _onUpdateChatStatusErrorEvent(
    UpdateChatStatusErrorEvent event,
    Emitter<ChatState> emit,
  ) {
    emit(
      UpdateChatStatusErrorActionState(
        errorTitle: event.errorTitle,
        errorMsg: event.errorMsg,
      ),
    );
  }

  /// Resolves API `stream` + UI messageType from event type / file path.
  /// Voice must be `audio` (NOT `media`) so payload becomes:
  /// `{ "type":"media", "stream":"audio", "audio":{"fileId":"..."} }`
  /// Video (WhatsApp Cloud API): `stream: video` + `video: { fileId }`
  /// See: https://developers.facebook.com/documentation/business-messaging/whatsapp/business-phone-numbers/media#supported-media-types
  _MediaKind _resolveMediaKind({
    required String eventType,
    required String filePath,
  }) {
    final lower = filePath.toLowerCase();
    final fileName = filePath.split('/').last;
    final type = eventType.toLowerCase().trim();

    final isAudio = type == 'voice' ||
        type == 'audio' ||
        lower.endsWith('.mp3') ||
        lower.endsWith('.m4a') ||
        lower.endsWith('.wav') ||
        lower.endsWith('.ogg') ||
        lower.endsWith('.aac');

    final isImage = type == 'image' ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');

    // WhatsApp supported: video/mp4 (.mp4), video/3gpp (.3gp). Also map common
    // phone formats so we never send them as `document`.
    final isVideo = type == 'video' ||
        lower.endsWith('.mp4') ||
        lower.endsWith('.3gp') ||
        lower.endsWith('.3gpp') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.webm');

    if (isAudio) {
      return const _MediaKind(stream: 'audio', messageType: 'audio', body: '');
    }
    if (isImage) {
      return const _MediaKind(stream: 'image', messageType: 'image', body: '');
    }
    if (isVideo) {
      return const _MediaKind(stream: 'video', messageType: 'video', body: '');
    }
    return _MediaKind(stream: 'document', messageType: 'document', body: fileName);
  }

  FutureOr<void> _onSendMessageEvent(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final hasFiles = event.files.isNotEmpty;
    final trimmedText = event.textBody.trim();

    // Nothing to send.
    if (!hasFiles && trimmedText.isEmpty) return;

    developer.log("====== SEND MESSAGE ======");
    developer.log("type: ${event.type} | files: ${event.files.length}");
    developer.log("phone: ${event.phoneNumber} | channel: ${event.chanelId}");
    developer.log("replyTo: ${event.replyMessageId}");
    developer.log("==================================");

    // Platform policy check BEFORE upload/optimistic bubble so the user is
    // told immediately (WhatsApp / Facebook / Instagram size limits).
    if (hasFiles) {
      for (final file in event.files) {
        final kind = _resolveMediaKind(
          eventType: event.type,
          filePath: file.path,
        );
        final policyError = await MediaAttachmentPolicy.validateBeforeUpload(
          file: file,
          channelId: event.chanelId,
          stream: kind.stream,
        );
        if (policyError != null) {
          developer.log('Attachment blocked by policy: $policyError');
          emit(SendMessageErrorActionState(error: policyError));
          return;
        }
      }
    }

    // Optimistic bubble so UI feels instant.
    if (state is ChatDataLoadedState) {
      final currentState = state as ChatDataLoadedState;
      String tempBody = trimmedText;
      String tempMessageType = 'text';
      String? localFilePath;

      if (hasFiles) {
        final firstFile = event.files.first;
        localFilePath = firstFile.path;
        final kind = _resolveMediaKind(
          eventType: event.type,
          filePath: firstFile.path,
        );
        tempMessageType = kind.messageType;
        tempBody = kind.body;
      }

      final InboxMessage? replyMsg = currentState.replyingToMessage;


      final optimisticMessage = InboxMessage(
        body: tempBody,
        isSent: 'true',
        messageType: tempMessageType,
        filePath: localFilePath,
        timestamp: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
        messageStatus: 'SENT',
        replyToMessage: replyMsg,
        
      );

      emit(
        currentState.copyWith(
          messages: List<InboxMessage>.from(currentState.messages)
            ..add(optimisticMessage),
            clearReply: true,
        ),
      );
    }

    try {
      // -------- MEDIA / VOICE / IMAGE / DOCUMENT --------
      if (hasFiles) {
        for (final file in event.files) {
          final kind = _resolveMediaKind(
            eventType: event.type,
            filePath: file.path,
          );

          developer.log(
            'Uploading ${kind.stream}: ${file.path}',
          );

          final uploadResponse = await _apiCall.uploadChatDocument(
            filePath: file.path,
            agentPublicId: event.agentId,
            companyId: event.companyPublicId,
            channelId: event.chanelId,
            mediaStream: kind.stream,
          );

          final uploadResult = uploadResponse?.results?.isNotEmpty == true
              ? uploadResponse!.results!.first
              : null;

          if (uploadResult == null ||
              uploadResult.success != true ||
              uploadResult.fileId == null ||
              uploadResult.fileId!.isEmpty) {
            emit(
              SendMessageErrorActionState(
                error: uploadResult?.errorMessage ??
                    'File upload failed. Please try again.',
              ),
            );
            return;
          }

          final fileId = uploadResult.fileId!;
          developer.log(
            'Upload OK → stream=${kind.stream}, fileId=$fileId',
          );

          final sendResponse = await _apiCall.sendMessage(
            type: 'media',
            phoneNumber: event.phoneNumber,
            textBody: '',
            fileId: fileId,
            mediaStream: kind.stream, // audio | image | video | document
            recipientNumber: event.recipientNumber,
            chanelId: event.chanelId,
            name: event.name,
            agentId: event.agentId,
            conversationId: event.conversationId,
            //replyMessageId: event.replyMessageId,
          );

          if (!sendResponse.success) {
            emit(
              SendMessageErrorActionState(
                error: sendResponse.message ?? 'Failed to send file.',
              ),
            );
            return;
          }
        }

        // Do NOT refetch here. Socket `send-message-data-response` upgrades the
        // optimistic bubble in place. A silent Fetch races with the socket and
        // often inserts a second copy of the same voice/media message.
        return;
      }

      // -------- PLAIN TEXT --------
      final response = await _apiCall.sendMessage(
        type: 'text',
        phoneNumber: event.phoneNumber,
        textBody: trimmedText,
        recipientNumber: event.recipientNumber,
        chanelId: event.chanelId,
        name: event.name,
        agentId: event.agentId,
        conversationId: event.conversationId,
        //replyMessageId: event.replyMessageId,
      );

      if (response.success) {
        await Future.delayed(const Duration(milliseconds: 400));
        add(
          FetchChatDetailsEvent(
            number: event.phoneNumber,
            companyPublicId: event.companyPublicId,
            agentId: event.agentId,
            channelId: event.chanelId,
            isSilent: true,
          ),
        );
      } else {
        emit(
          SendMessageErrorActionState(
            error: response.message ?? 'Failed to send message.',
          ),
        );
      }
    } catch (e, stacktrace) {
      developer.log('SEND EXCEPTION: $e', error: e, stackTrace: stacktrace);
      emit(SendMessageErrorActionState(error: e.toString()));
    }
  }

  FutureOr<void> _onFetchTeamContactsEvent(
    FetchTeamContactsEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(TeamContactsLoadingState());

    try {
      final response = await _apiCall.fetchTeamContactList(page: event.page);

      if (response != null && response.success == true) {
        _directoryAgents = response.data ?? [];
        emit(TeamContactsLoadedState(_directoryAgents));
      } else {
        emit(
          TeamContactsErrorState(response?.message ?? "Failed to load team"),
        );
      }
    } catch (e) {
      emit(TeamContactsErrorState("Something went wrong: $e"));
    }
  }

  FutureOr<void> _onSelectAgentFromSheetEvent(
    SelectAgentFromSheetEvent event,
    Emitter<ChatState> emit,
  ) {
    final agent = event.selectedAgent;

    final index = _activeChats.indexWhere(
      (element) => element.agentId == agent.publicId,
    );

    if (index != -1) {
      final existingChat = _activeChats.removeAt(index);
      _activeChats.insert(0, existingChat);
    } else {
      _activeChats.insert(0, agent);
    }
  }

  FutureOr<void> _onSubmitTransferChatEvent(
    SubmitTransferChatEvent event,
    Emitter<ChatState> emit,
  ) async {
    // emit(LoadingState());

    try {
      final response = await _apiCall.transferChat(
        assignAgentId: event.assignAgentId,
        channelId: event.channelId,
        companyId: event.companyId,
        currentAgentId: event.currentAgentId,
        phoneNumber: event.phoneNumber,
      );

      if (response.success == true) {
        emit(
          ChatTransferSuccessActionState(
            message: response.data?.message ?? "Chat Transferred Successfully!",
          ),
        );
      } else {
        emit(
          ChatTransferErrorActionState(
            error:
                response.data?.message ??
                response.message ??
                "Failed to transfer chat.",
          ),
        );
      }
    } catch (e) {
      // emit(LoadingSuccessState());
      emit(ChatTransferErrorActionState(error: e.toString()));
    }
  }

  FutureOr<void> _onDownloadDocumentEvent(
    DownloadDocumentEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      if (event.context.mounted) {
        AppUtilities.showSuccessSnackBar(
          navigatorKey.currentContext!,
          title: "Downloading",
          message: "${event.fileName} is downloading...",
        );
      }

      String savePath = "";

      if (Platform.isAndroid) {
        final Directory? externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          List<String> paths = externalDir.path.split('Android');
          String rootPath = paths[0];
          final Directory downloadDir = Directory("${rootPath}Download");
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
          }
          savePath = "${downloadDir.path}/${event.fileName}";
        } else {
          final Directory appDocDir = await getApplicationDocumentsDirectory();
          savePath = "${appDocDir.path}/${event.fileName}";
        }
      } else if (Platform.isIOS) {
        final Directory documentsDirectory =
            await getApplicationDocumentsDirectory();
        savePath = "${documentsDirectory.path}/${event.fileName}";
      }

      final Dio dio = Dio();
      await dio.download(event.filePath, savePath);

      if (event.context.mounted) {
        ScaffoldMessenger.of(event.context).hideCurrentSnackBar();
        AppUtilities.showSuccessSnackBar(
          navigatorKey.currentContext!,
          title: "Success",
          message: Platform.isAndroid
              ? "Saved to Phone's Download folder!"
              : "Saved to Documents: ${event.fileName}",
        );
      }
    } catch (e) {
      if (event.context.mounted) {
        ScaffoldMessenger.of(event.context).hideCurrentSnackBar();

        AppUtilities.showErrorSnackBar(
          navigatorKey.currentContext!,
          title: "Error",
          message: "Download failed. Please try again.",
        );
      }
    }
  }


FutureOr<void> _onFetchChatDetailsEvent(
  FetchChatDetailsEvent event,
  Emitter<ChatState> emit,
) async {
  developer.log("🔄 [CHAT_BLOC] FetchChatDetailsEvent started | page: ${event.page} | isSilent: ${event.isSilent} | isLoadMore: ${event.isLoadMore}");

  if (event.isLoadMore && state is ChatDataLoadedState) {
    final currentState = state as ChatDataLoadedState;
    if (currentState.hasReachedMax) return;
    emit(currentState.copyWith(isLoadingMore: true));
  }

  if (!event.isLoadMore && _countdownTimer != null) {
    _countdownTimer!.cancel();
  }

  if (!event.isLoadMore && !event.isSilent && _countdownTimer != null) {
  _countdownTimer!.cancel();
}

  if (!event.isLoadMore && !event.isSilent) {
    emit(LoadingState());
  }

  final response = await _apiCall.fetchChatDetails(
    number: event.number,
    companyPublicId: event.companyPublicId,
    agentId: event.agentId,
    channelId: event.channelId,
    page: event.page,
  );

  if (isClosed) return;

  if (response != null && response.data != null) {
    final chatData = response.data!;
    final conversation = chatData.conversation;
    final newMessages = chatData.inboxes ?? [];

    List<InboxMessage> combinedMessages;
    if (event.isLoadMore && state is ChatDataLoadedState) {
      final currentState = state as ChatDataLoadedState;
      combinedMessages = [...newMessages, ...currentState.messages];
    } else {
      combinedMessages = newMessages;
    }

    final bool hasReachedMax = newMessages.isEmpty;
    final currentActiveConversation = (event.isLoadMore && state is ChatDataLoadedState)
        ? (state as ChatDataLoadedState).conversation
        : (conversation ?? (state is ChatDataLoadedState ? (state as ChatDataLoadedState).conversation : null));

    String existingFormattedTime = "00h 00m 00s";
    bool existingIsWindowClosed = false;

    if (state is ChatDataLoadedState) {
      final currentState = state as ChatDataLoadedState;
      existingFormattedTime = currentState.formattedTime;
      existingIsWindowClosed = currentState.isWindowClosed;
    }

    //developer.log("🔍 [TIMER] isSilent: ${event.isSilent} | isLoadMore: ${event.isLoadMore} | isWindowClosed before emit: $existingIsWindowClosed | timer active: ${_countdownTimer?.isActive}");

    emit(
      ChatDataLoadedState(
        name: conversation?.customerName ?? (state is ChatDataLoadedState ? (state as ChatDataLoadedState).name : event.number),
        platform: conversation?.platform ?? (state is ChatDataLoadedState ? (state as ChatDataLoadedState).platform : SocialPlatform.sms),
        showEmojiPicker: false,
        selectedFiles: const [],
        conversation: currentActiveConversation,
        messages: combinedMessages,
        currentPage: event.page,
        hasReachedMax: hasReachedMax,
        isLoadingMore: false,
        formattedTime: existingFormattedTime,
        isWindowClosed: existingIsWindowClosed,
      ),
    );

    

    if (!isClosed && !event.isLoadMore) {
      final expiry = conversation?.expiryDateTime ?? DateTime.now().add(const Duration(hours: 24));
      add(StartChatWindowTimerEvent(expiryTime: expiry));
    }
    if (!isClosed && !event.isLoadMore && !event.isSilent) {
  final expiry = conversation?.expiryDateTime ?? DateTime.now().add(const Duration(hours: 24));
  add(StartChatWindowTimerEvent(expiryTime: expiry));
}
    
  } else {
    // 💡 FIX: Chahe response null ho ya response.data null ho,
    // agar event silent tha aur screen par pehle se data tha, TOH SCREEN DISRUPT MAT KARO!
    developer.log("❌ [CHAT_BLOC] API failed or response/data is null!");

    if (event.isSilent && state is ChatDataLoadedState) {
      developer.log("🔄 [CHAT_BLOC] Preserving UI state on silent sync failure.");
      emit((state as ChatDataLoadedState).copyWith(isLoadingMore: false));
      return;
    }

    if (state is ChatDataLoadedState) {
      emit((state as ChatDataLoadedState).copyWith(isLoadingMore: false));
    }

    if (!event.isSilent) {
      emit(
        LoadingErrorState(
          errorTitle: "Sync Error",
          errorMsg: response?.message ?? "Failed to connect to server",
        ),
      );
    }
  }
}


  /// Appends a message that arrived live over the socket to the open chat.
  FutureOr<void> _onIncomingChatMessageEvent(
    IncomingChatMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatDataLoadedState) return;
    final currentState = state as ChatDataLoadedState;

    final message = _mapSocketMessage(event.data);
    final messages = currentState.messages;

    // 1) Exact duplicate (re-delivery / already in list) -> ignore.
    if (_isDuplicateMessage(messages, message)) return;

    // 2) Our own message echoed back: upgrade optimistic placeholder in place.
    final sentByMe = message.wasSentByMe;
    if (sentByMe) {
      final optimisticIndex = _findOptimisticIndex(messages, message);
      if (optimisticIndex != -1) {
        final updated = List<InboxMessage>.from(messages);
        // Keep local file for instant playback until remote URL is usable.
        final existing = updated[optimisticIndex];
        final merged = _mergeOptimisticWithSocket(existing, message);
        updated[optimisticIndex] = merged;
        emit(currentState.copyWith(messages: updated));
        return;
      }
    }

    // 3) Genuinely new message -> append.
    final updated = List<InboxMessage>.from(messages)..add(message);
    emit(currentState.copyWith(messages: updated));
  }

  bool _isDuplicateMessage(
    List<InboxMessage> messages,
    InboxMessage incoming,
  ) {
    for (final m in messages) {
      final sameMsgId = incoming.messageId != null &&
          incoming.messageId!.isNotEmpty &&
          m.messageId != null &&
          m.messageId == incoming.messageId;
      final sameId = incoming.id != null &&
          incoming.id!.isNotEmpty &&
          m.id != null &&
          m.id == incoming.id;
      if (sameMsgId || sameId) return true;

      // Same remote media URL from me within a short window = duplicate echo.
      final incomingPath = incoming.filePath?.split('?').first;
      final existingPath = m.filePath?.split('?').first;
      if (incoming.wasSentByMe &&
          m.wasSentByMe &&
          incomingPath != null &&
          incomingPath.isNotEmpty &&
          incomingPath.startsWith('http') &&
          incomingPath == existingPath) {
        return true;
      }
    }
    return false;
  }

  InboxMessage _mergeOptimisticWithSocket(
    InboxMessage optimistic,
    InboxMessage socketMsg,
  ) {
    final localPath = optimistic.filePath;
    final remotePath = socketMsg.filePath;
    final preferLocal = localPath != null &&
        localPath.isNotEmpty &&
        !localPath.startsWith('http') &&
        (remotePath == null || remotePath.isEmpty);

    return InboxMessage(
      id: socketMsg.id ?? optimistic.id,
      messageId: socketMsg.messageId ?? optimistic.messageId,
      messageType: socketMsg.messageType ?? optimistic.messageType,
      contactNumber: socketMsg.contactNumber ?? optimistic.contactNumber,
      body: socketMsg.body ?? optimistic.body,
      timestamp: socketMsg.timestamp ?? optimistic.timestamp,
      contactName: socketMsg.contactName ?? optimistic.contactName,
      recipientNumber: socketMsg.recipientNumber ?? optimistic.recipientNumber,
      conversationId: socketMsg.conversationId ?? optimistic.conversationId,
      isSent: true,
      messageStatus: socketMsg.messageStatus ?? optimistic.messageStatus ?? 'SENT',
      filePath: preferLocal ? localPath : (remotePath ?? localPath),
      caption: socketMsg.caption ?? optimistic.caption,
    );
  }

  /// Finds the pending optimistic bubble (no id/messageId, sent by me) that the
  /// incoming socket [message] corresponds to, so it can be replaced instead of
  /// duplicated. Returns -1 when there is none.
  int _findOptimisticIndex(List<InboxMessage> messages, InboxMessage message) {
    final incomingType = (message.messageType ?? '').toLowerCase();
    final isMedia = incomingType != 'text';

    for (int i = messages.length - 1; i >= 0; i--) {
      final m = messages[i];
      final isOptimistic =
          m.messageId == null && m.id == null && m.wasSentByMe;
      if (!isOptimistic) continue;

      final existingType = (m.messageType ?? '').toLowerCase();

      if (isMedia) {
        // Match any pending media/audio/image/document bubble from me.
        if (existingType != 'text') return i;
      } else if ((m.body ?? '') == (message.body ?? '')) {
        return i;
      }
    }
    return -1;
  }

  /// Maps a `send-message-data-response` `data` object into an [InboxMessage].
  ///
  /// Socket shape (media):
  /// ```
  /// messageType: "media"
  /// mimeType: "audio" | "image/png" | ...
  /// filePath: "https://...ogg?..." | "https://...png?..."
  /// body: often null/empty for media
  /// ```
  InboxMessage _mapSocketMessage(Map<String, dynamic> data) {
    final rawType = data['messageType']?.toString() ?? 'text';
    final mimeType = data['mimeType']?.toString().toLowerCase() ?? '';
    final stream = data['stream']?.toString().toLowerCase() ?? '';
    final body = data['body']?.toString();
    // Media URL lives in `filePath` on socket (NOT in `body`).
    final socketFilePath = data['filePath']?.toString();
    final pathForDetect =
        (socketFilePath != null && socketFilePath.isNotEmpty)
            ? socketFilePath
            : (body ?? '');

    final type = _normalizeSocketMessageType(
      rawType: rawType,
      mimeType: mimeType,
      stream: stream,
      pathOrBody: pathForDetect,
    );

    final isMedia = type.toLowerCase() != 'text';
    final sentByMe = data['isSent'] == true ||
        data['isSent']?.toString().toLowerCase() == 'true';

    final rawFilePath = isMedia
        ? (socketFilePath?.isNotEmpty == true ? socketFilePath : body)
        : null;
    // WhatsApp relative paths (`assets/….ogg`) → absolute Omni media URL.
    final resolvedFilePath = MediaUrlResolver.resolve(rawFilePath);

    return InboxMessage(
      id: data['publicId']?.toString(),
      messageId: data['messageId']?.toString(),
      messageType: type,
      contactNumber: data['contactNumber']?.toString(),
      body: body,
      timestamp: data['timestamp']?.toString(),
      contactName: data['contactName']?.toString(),
      recipientNumber: data['recipientNumber']?.toString(),
      conversationId: data['conversationId'],
      isSent: sentByMe,
      messageStatus: sentByMe ? 'SENT' : null,
      filePath: resolvedFilePath,
      caption: data['body2']?.toString(),
    );
  }

  /// Turns socket `messageType: media` + `mimeType` / path into UI kinds:
  /// `audio` | `image` | `video` | `document` | `text`.
  String _normalizeSocketMessageType({
    required String rawType,
    required String mimeType,
    required String stream,
    required String pathOrBody,
  }) {
    final type = rawType.toLowerCase().trim();
    final lowerPath = pathOrBody.toLowerCase();
    // Strip query so `.ogg?x=1` / `.png?x=1` still match.
    final pathNoQuery = lowerPath.split('?').first;

    if (type == 'text') return 'text';

    if (stream == 'audio' ||
        type == 'audio' ||
        mimeType.startsWith('audio') ||
        mimeType == 'audio' ||
        pathNoQuery.contains('.m4a') ||
        pathNoQuery.contains('.mp3') ||
        pathNoQuery.contains('.ogg') ||
        pathNoQuery.contains('.wav') ||
        pathNoQuery.contains('.aac') ||
        lowerPath.contains('audioclip')) {
      return 'audio';
    }

    if (stream == 'image' ||
        type == 'image' ||
        mimeType.startsWith('image') ||
        pathNoQuery.contains('.jpg') ||
        pathNoQuery.contains('.jpeg') ||
        pathNoQuery.contains('.png') ||
        pathNoQuery.contains('.webp') ||
        pathNoQuery.contains('.gif')) {
      return 'image';
    }

    if (stream == 'video' ||
        type == 'video' ||
        mimeType.startsWith('video') ||
        pathNoQuery.contains('.mp4') ||
        pathNoQuery.contains('.3gp') ||
        pathNoQuery.contains('.3gpp') ||
        pathNoQuery.contains('.mov') ||
        pathNoQuery.contains('.mkv') ||
        pathNoQuery.contains('.webm')) {
      return 'video';
    }

    if (stream == 'document' ||
        type == 'document' ||
        type == 'media' ||
        mimeType.isNotEmpty) {
      return type == 'media' ? 'document' : type;
    }

    return type.isEmpty ? 'text' : type;
  }

  FutureOr<void> _onStartTimer(
    StartChatWindowTimerEvent event,
    Emitter<ChatState> emit,
  ) {
    _countdownTimer?.cancel();

    final initialRemaining = event.expiryTime.difference(DateTime.now());
    add(
      _TimerTickEvent(
        remainingTime: initialRemaining.isNegative
            ? Duration.zero
            : initialRemaining,
      ),
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = event.expiryTime.difference(DateTime.now());

      if (remaining.isNegative || remaining.inSeconds <= 0) {
        timer.cancel();
        add(_TimerTickEvent(remainingTime: Duration.zero));
      } else {
        add(_TimerTickEvent(remainingTime: remaining));
      }
    });
  }

  FutureOr<void> _onTick(_TimerTickEvent event, Emitter<ChatState> emit) {
    if (state is ChatDataLoadedState) {
      final currentState = state as ChatDataLoadedState;

      if (event.remainingTime == Duration.zero) {
        emit(
          currentState.copyWith(
            formattedTime: "00h 00m 00s",
            isWindowClosed: true,
          ),
        );
      } else {
        String twoDigits(int n) => n.toString().padLeft(2, '0');
        final hours = twoDigits(event.remainingTime.inHours);
        final minutes = twoDigits(event.remainingTime.inMinutes.remainder(60));
        final seconds = twoDigits(event.remainingTime.inSeconds.remainder(60));

        final formatted = "${hours}h ${minutes}m ${seconds}s";

        // emit(
        //   currentState.copyWith(
        //     formattedTime: formatted,
        //     isWindowClosed: false,
        //   ),
        // );

        final newState = currentState.copyWith(
  formattedTime: formatted,
  isWindowClosed: false,
);
_lastLoadedState = newState; // <-- cache karo
emit(newState);

      }
    } else {
      print(
        "======>>> [ChatBloc] _onTick skipped because current state is NOT ChatDataLoadedState. Current state: $state",
      );
    }
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    _audioTimer?.cancel();
    _recorder.dispose();
    _typingTimer?.cancel();
    // _authSubscription?.cancel();
    return super.close();
  }

  FutureOr<void> _onOpenCustomerProfileEvent(
    OpenCustomerProfileEvent event,
    Emitter<ChatState> emit,
  ) {
    print("OPEN CUSTOMER PROFILE");
    // print("CUSTOMER NAME: ${event.name}");
    // print("PLATFORM: ${event.platform.title}");

    emit(OpenCustomerProfileActionState());
  }

  FutureOr<void> _onInitChatEvent(
    InitChatEvent event,
    Emitter<ChatState> emit,
  ) {
    final currentState = state;

    List<InboxMessage> existingMessages = [];
    dynamic existingConversation;

    if (currentState is ChatDataLoadedState) {
      existingMessages = currentState.messages;
      existingConversation = currentState.conversation;
    }

    emit(
      ChatDataLoadedState(
        name: event.name,
        platform: event.platform,
        showEmojiPicker: false,
        selectedFiles: const [],
        messages: existingMessages,
        conversation: existingConversation,
      ),
    );
  }

  FutureOr<void> _onToggleEmojiPickerEvent(
    ToggleEmojiPickerEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatDataLoadedState) {
      final currentState = state as ChatDataLoadedState;
      emit(
        currentState.copyWith(showEmojiPicker: !currentState.showEmojiPicker),
      );
    }
  }

  FutureOr<void> _onUpdateSelectedFiles(
    UpdateSelectedFilesEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatDataLoadedState) {
      final currentState = state as ChatDataLoadedState;
      emit(currentState.copyWith(selectedFiles: event.files));
    }
  }

  FutureOr<void> _onChatInitialEvent(
    ChatInitialEvent event,
    Emitter<ChatState> emit,
  ) {
    emit(ChatInitialState());
  }

  FutureOr<void> _onBackPressActionEvent(
    BackPressActionEvent event,
    Emitter<ChatState> emit,
  ) {
    emit(BackPressActionState());
  }

  FutureOr<void> _onLoadingEvent(LoadingEvent event, Emitter<ChatState> emit) {
    emit(LoadingState());
  }

  FutureOr<void> _onLoadingSuccessEvent(
    LoadingSuccessEvent event,
    Emitter<ChatState> emit,
  ) {
    emit(LoadingSuccessState());
  }

  FutureOr<void> _onLoadingErrorEvent(
    LoadingErrorEvent event,
    Emitter<ChatState> emit,
  ) {
    emit(
      LoadingErrorState(errorTitle: event.errorTitle, errorMsg: event.errorMsg),
    );
  }
}