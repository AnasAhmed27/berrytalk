import 'dart:async';
import 'dart:io';

import 'package:berrytalks/Widgets_Component/Enum/desigantion_enum.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppUitilities.dart';
import 'package:berrytalks/main.dart';
import 'package:berrytalks/network/ApiService.dart';
import 'package:berrytalks/screens/Team_chat_screen/network%20calls/team_chat_api_call.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

part 'team_chat_event.dart';
part 'team_chat_state.dart';

class TeamChatBloc extends Bloc<TeamChatEvent, TeamChatState> {
  final TeamChatApiCall _teamChatApiCall = TeamChatApiCall();

  TeamChatBloc() : super(TeamChatInitialState()) {
    on<TeamChatInitialEvent>(_onTeamChatInitialEvent);
    on<BackPressActionEvent>(_onBackPressActionEvent);
    on<LoadingEvent>(_onLoadingEvent);
    on<LoadingSuccessEvent>(_onLoadingSuccessEvent);
    on<LoadingErrorEvent>(_onLoadingErrorEvent);
    on<InitTeamChatEvent>(_onInitTeamChatEvent);
    on<ToggleEmojiPickerEvent>(_onToggleEmojiPickerEvent);
    on<UpdateSelectedFilesEvent>(_onUpdateSelectedFiles);
    on<FetchTeamChatHistoryEvent>(_onFetchTeamChatHistoryEvent);
    on<SendTeamMessageEvent>(_onSendTeamMessageEvent);
    on<ForceLogoutEvent>(_onForceLogoutEvent);
    on<StartRecordingEvent>(_onStartRecording);
    on<LockRecordingEvent>(_onLockRecording);
    on<CancelRecordingEvent>(_onCancelRecording);
    on<StopAndPreviewRecordingEvent>(_onStopAndPreviewRecording);
    on<TogglePreviewPlaybackEvent>(_onTogglePreviewPlayback);
    on<UpdatePreviewPositionEvent>(_onUpdatePreviewPosition);
    on<UpdateRecordingTimerEvent>(_onUpdateRecordingTimer);
    on<ToggleAudioPlaybackEvent>(_onToggleAudioPlayback);
    on<UpdateAudioPositionEvent>(_onUpdateAudioPosition);
    on<UpdateAudioDurationEvent>(_onUpdateAudioDuration);
    on<AudioPlaybackCompletedEvent>(_onAudioPlaybackCompleted);
    on<DownloadDocumentEvent>(_onDownloadDocumentEvent);

  }

  FutureOr<void> _onDownloadDocumentEvent(
    DownloadDocumentEvent event,
    Emitter<TeamChatState> emit,
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

  FutureOr<void> _onAudioPlaybackCompleted(
    AudioPlaybackCompletedEvent event,
    Emitter<TeamChatState> emit,
  ) async {
    if (state is! TeamChatDataLoadedState) return;
    final currentState = state as TeamChatDataLoadedState;

    final bool wasActuallyPlaying =
        currentState.playingAudios[event.filePath] ?? false;
    if (!wasActuallyPlaying) return;

    final updatedPlaying = Map<String, bool>.from(currentState.playingAudios);
    final updatedPositions = Map<String, Duration>.from(
      currentState.audioPositions,
    );
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

  FutureOr<void> _onUpdateAudioDuration(
    UpdateAudioDurationEvent event,
    Emitter<TeamChatState> emit,
  ) {
    if (state is TeamChatDataLoadedState) {
      final currentState = state as TeamChatDataLoadedState;
      final Map<String, Duration> updatedDurations = Map.from(
        currentState.audioDurations,
      );
      updatedDurations[event.filePath] = event.duration;
      emit(currentState.copyWith(audioDurations: updatedDurations));
    }
  }

  FutureOr<void> _onUpdateAudioPosition(
    UpdateAudioPositionEvent event,
    Emitter<TeamChatState> emit,
  ) {
    if (state is TeamChatDataLoadedState) {
      final currentState = state as TeamChatDataLoadedState;
      final Map<String, Duration> updatedPositions = Map.from(
        currentState.audioPositions,
      );
      updatedPositions[event.filePath] = event.position;
      emit(currentState.copyWith(audioPositions: updatedPositions));
    }
  }

  FutureOr<void> _onToggleAudioPlayback(
    ToggleAudioPlaybackEvent event,
    Emitter<TeamChatState> emit,
  ) {
    if (state is TeamChatDataLoadedState) {
      final currentState = state as TeamChatDataLoadedState;
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

  FutureOr<void> _onUpdateRecordingTimer(
    UpdateRecordingTimerEvent event,
    Emitter<TeamChatState> emit,
  ) {
    if (state is TeamChatDataLoadedState) {
      final currentState = state as TeamChatDataLoadedState;
      emit(currentState.copyWith(recordingDuration: event.duration));
    }
  }

  FutureOr<void> _onUpdatePreviewPosition(
    UpdatePreviewPositionEvent event,
    Emitter<TeamChatState> emit,
  ) {
    if (state is TeamChatDataLoadedState) {
      final currentState = state as TeamChatDataLoadedState;
      emit(
        currentState.copyWith(
          previewPosition: event.position,
          previewTotalDuration: event.duration,
        ),
      );
    }
  }

  FutureOr<void> _onTogglePreviewPlayback(
    TogglePreviewPlaybackEvent event,
    Emitter<TeamChatState> emit,
  ) {
    if (state is TeamChatDataLoadedState) {
      final currentState = state as TeamChatDataLoadedState;
      emit(
        currentState.copyWith(isPlayingPreview: !currentState.isPlayingPreview),
      );
    }
  }

  FutureOr<void> _onStopAndPreviewRecording(
    StopAndPreviewRecordingEvent event,
    Emitter<TeamChatState> emit,
  ) {
    if (state is TeamChatDataLoadedState) {
      final currentState = state as TeamChatDataLoadedState;
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

  FutureOr<void> _onCancelRecording(
    CancelRecordingEvent event,
    Emitter<TeamChatState> emit,
  ) {
    if (state is TeamChatDataLoadedState) {
      final currentState = state as TeamChatDataLoadedState;
      emit(
        currentState.copyWith(
          isRecording: false,
          isRecordingLocked: false,
          hasRecordedPreview: false,
          isPlayingPreview: false,
          recordingDuration: Duration.zero,
          previewPosition: Duration.zero,
          previewTotalDuration: Duration.zero,
          recordedFilePath: null,
        ),
      );
    }
  }

  FutureOr<void> _onLockRecording(
    LockRecordingEvent event,
    Emitter<TeamChatState> emit,
  ) {
    if (state is TeamChatDataLoadedState) {
      final currentState = state as TeamChatDataLoadedState;
      emit(currentState.copyWith(isRecordingLocked: true));
    }
  }

  FutureOr<void> _onStartRecording(
    StartRecordingEvent event,
    Emitter<TeamChatState> emit,
  ) {
    if (state is TeamChatDataLoadedState) {
      final currentState = state as TeamChatDataLoadedState;
      emit(
        currentState.copyWith(
          isRecording: true,
          isRecordingLocked: false,
          hasRecordedPreview: false,
          isPlayingPreview: false,
          recordingDuration: Duration.zero,
        ),
      );
    }
  }

  FutureOr<void> _onForceLogoutEvent(
    ForceLogoutEvent event,
    Emitter<TeamChatState> emit,
  ) {
    print("[ChatBloc] Force logout triggered");
    emit(ForceLogoutActionState());
  }

//   Future<void> _onSendTeamMessageEvent(
//   SendTeamMessageEvent event,
//   Emitter<TeamChatState> emit,
// ) async {
//   if (state is TeamChatDataLoadedState) {
//     var currentState = state as TeamChatDataLoadedState;
//     if (event.type == "text" && event.textBody.trim().isEmpty) return;

//     final tempMessage = TeamMessage(
//       type: event.type, 
//       textBody: event.type == "text" ? event.textBody : "${event.type} message",
//       recipientAgentId: event.recipientAgentId,
//       name: currentState.name,
//     );

//     final List<TeamMessage> updatedList = List.from(currentState.messages);
//     updatedList.add(tempMessage);

//     emit(currentState.copyWith(messages: updatedList));

//     try {
     
//       final response = await _teamChatApiCall.sendTeamMessage(
//         type: event.type, 
//         textBody: event.textBody,
//         name: currentState.name,
//         recipientAgentId: event.recipientAgentId,
//         // file: event.file, 
//       );

//       if (state is TeamChatDataLoadedState) {
//         currentState = state as TeamChatDataLoadedState;

//         if (response != null && response.data == true) {
//           print("TEAM MESSAGE SENT SUCCESSFUL: ${response.message}");
          
//           final List<TeamMessage> finalFilteredList = List.from(currentState.messages);
//           emit(currentState.copyWith(messages: finalFilteredList));
//         } else {
//           print("TEAM MESSAGE SENT FAILED: ${response?.message}");
//         }
//       }
//     } catch (e) {
//       print("TEAM MESSAGE SENT EXCEPTION: $e");
//     }
//   }
// }

Future<void> _onSendTeamMessageEvent(
  SendTeamMessageEvent event,
  Emitter<TeamChatState> emit,
) async {
  if (state is TeamChatDataLoadedState) {
    var currentState = state as TeamChatDataLoadedState;
    
    final bool hasFile = event.file != null;
    if (event.type == "text" && event.textBody.trim().isEmpty) return;

    // 1. OPTIMISTIC BUBBLE: Send dabate hi screen par show karne ke liye
    final tempMessage = TeamMessage(
      id: "temp_${DateTime.now().millisecondsSinceEpoch}", // Temporary ID
      type: event.type, // "voice" ya "audio"
      textBody: event.type == "text" ? event.textBody : "",
      recipientAgentId: event.recipientAgentId,
      name: currentState.name,
      timestamp: (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(), // Hamara fixed timestamp format
      filePath: hasFile ? event.file!.path : null, // Local path taake bubble load ho jaye
      messageStatus: "SENDING",
    );

    final List<TeamMessage> updatedList = List.from(currentState.messages);
    updatedList.add(tempMessage);
    emit(currentState.copyWith(messages: updatedList));

    try {
      // 2. API CALL: Agar aapki API alag se upload leti hai ya direct multipart leti hai
      // Agar direct leti hai toh event.file pass hoga:
      final response = await _teamChatApiCall.sendTeamMessage(
        type: event.type, 
        textBody: event.textBody,
        name: currentState.name,
        recipientAgentId: event.recipientAgentId,
        file: event.file, // Multipart call ke liye file ja rahi hai
      );

      if (state is TeamChatDataLoadedState) {
        currentState = state as TeamChatDataLoadedState;

        if (response != null && response.data == true) {
          print("TEAM MESSAGE SENT SUCCESSFUL: ${response.message}");
          
          // Idhar jab success ho jaye, toh status ko 'SENT' kar dein ya refresh event call karein
          final List<TeamMessage> finalFilteredList = currentState.messages.map((msg) {
            if (msg.id == tempMessage.id) {
              return msg.copyWith(messageStatus: "SENT");
            }
            return msg;
          }).toList();
          
          emit(currentState.copyWith(messages: finalFilteredList));
        } else {
          print("TEAM MESSAGE SENT FAILED: ${response?.message}");
          _handleSendFailure(currentState, tempMessage.id!, emit);
        }
      }
    } catch (e) {
      print("TEAM MESSAGE SENT EXCEPTION: $e");
      if (state is TeamChatDataLoadedState) {
        _handleSendFailure(state as TeamChatDataLoadedState, tempMessage.id!, emit);
      }
    }
  }
}

// Helper function agar message fail ho jaye toh ui se temporary hata sakein ya fail status dikhayein
void _handleSendFailure(TeamChatDataLoadedState state, String tempId, Emitter<TeamChatState> emit) {
  final failedList = state.messages.map((msg) {
    if (msg.id == tempId) {
      return msg.copyWith(messageStatus: "FAILED");
    }
    return msg;
  }).toList();
  emit(state.copyWith(messages: failedList));
}

  // Future<void> _onSendTeamMessageEvent(
  //   SendTeamMessageEvent event,
  //   Emitter<TeamChatState> emit,
  // ) async {
  //   if (state is TeamChatDataLoadedState) {
  //     var currentState = state as TeamChatDataLoadedState;
  //     if (event.textBody.trim().isEmpty) return;

  //     final tempMessage = TeamMessage(
  //       type: "text",
  //       textBody: event.textBody,
  //       recipientAgentId: event.recipientAgentId,
  //       name: currentState.name,
  //     );

  //     final List<TeamMessage> updatedList = List.from(currentState.messages);
  //     updatedList.add(tempMessage);

  //     emit(currentState.copyWith(messages: updatedList));

  //     try {
  //       final response = await _teamChatApiCall.sendTeamMessage(
  //         type: "text",
  //         textBody: event.textBody,
  //         name: currentState.name,
  //         recipientAgentId: event.recipientAgentId,
  //       );

  //       if (state is TeamChatDataLoadedState) {
  //         currentState = state as TeamChatDataLoadedState;

  //         if (response != null && response.data == true) {
  //           print("MESSAGE SENT SUCCESSFUL: ${response.message}");

  //           final List<TeamMessage> finalFilteredList = List.from(
  //             currentState.messages,
  //           );
  //           emit(currentState.copyWith(messages: finalFilteredList));
  //         } else {
  //           print("MESSAGE SENT FAILED: ${response?.message}");
  //         }
  //       }
  //     } catch (e) {
  //       print("MESSAGE SENT EXCEPTION: $e");
  //     }
  //   }
  // }

  Future<void> _onFetchTeamChatHistoryEvent(
    FetchTeamChatHistoryEvent event,
    Emitter<TeamChatState> emit,
  ) async {
    List<TeamMessage> currentMessages = [];
    int pageToFetch = event.page;
    String savedName = event.name;
    String savedRecipientId = event.recipientAgentId;
    DesigantionStatus savedStatus = DesigantionStatus.agent;
    bool savedEmojiPicker = false;
    List<File> savedFiles = [];

    if (state is TeamChatDataLoadedState) {
      final currentState = state as TeamChatDataLoadedState;
      savedName = currentState.name.isNotEmpty ? currentState.name : event.name;
      savedRecipientId = currentState.recipientAgentId;
      savedStatus = currentState.desStatus;
      savedEmojiPicker = currentState.showEmojiPicker;
      savedFiles = currentState.selectedFiles;

      if (pageToFetch > 0) {
        currentMessages = List.from(currentState.messages);
      }
    }

    if (pageToFetch == 0) {
      emit(TeamChatHistoryLoadingState());
    }

    try {
      final response = await _teamChatApiCall.fetchTeamChatDetails(
        recipientAgentId: event.recipientAgentId,
        page: pageToFetch,
        size: event.size,
      );

      if (response != null &&
          (response.status == 0 || response.status == 1) &&
          response.data != null) {
        final newMessages = response.data?.content ?? [];
        final isLastPage = response.data?.last ?? true;

        if (pageToFetch == 0) {
          currentMessages = List.from(newMessages);
        } else {
          currentMessages.addAll(newMessages);
        }

        if (state is TeamChatDataLoadedState) {
          final currentState = state as TeamChatDataLoadedState;
          emit(
            currentState.copyWith(
              messages: currentMessages,
              hasReachedMax: !isLastPage,
              currentPage: pageToFetch,
            ),
          );
        } else {
          emit(
            TeamChatDataLoadedState(
              name: savedName,
              recipientAgentId: savedRecipientId,
              desStatus: savedStatus,
              showEmojiPicker: savedEmojiPicker,
              selectedFiles: savedFiles,
              messages: currentMessages,
              hasReachedMax: !isLastPage,
              currentPage: pageToFetch,
            ),
          );
        }
      } else {
        emit(
          TeamChatHistoryErrorState(
            errorMessage: response?.message ?? "Failed to fetch chat history",
          ),
        );
      }
    } catch (e) {
      emit(TeamChatHistoryErrorState(errorMessage: e.toString()));
    }
  }

  FutureOr<void> _onInitTeamChatEvent(
    InitTeamChatEvent event,
    Emitter<TeamChatState> emit,
  ) {
    emit(
      TeamChatDataLoadedState(
        recipientAgentId: event.recipientAgentId,
        name: event.name,
        desStatus: event.desStatus,
        showEmojiPicker: false,
        selectedFiles: const [],
      ),
    );
  }

  FutureOr<void> _onToggleEmojiPickerEvent(
    ToggleEmojiPickerEvent event,
    Emitter<TeamChatState> emit,
  ) {
    if (state is TeamChatDataLoadedState) {
      final currentState = state as TeamChatDataLoadedState;
      emit(
        currentState.copyWith(showEmojiPicker: !currentState.showEmojiPicker),
      );
    }
  }

  FutureOr<void> _onUpdateSelectedFiles(
    UpdateSelectedFilesEvent event,
    Emitter<TeamChatState> emit,
  ) {
    if (state is TeamChatDataLoadedState) {
      final currentState = state as TeamChatDataLoadedState;
      emit(currentState.copyWith(selectedFiles: event.files));
    }
  }

  FutureOr<void> _onTeamChatInitialEvent(
    TeamChatInitialEvent event,
    Emitter<TeamChatState> emit,
  ) {
    emit(TeamChatInitialState());
  }

  FutureOr<void> _onBackPressActionEvent(
    BackPressActionEvent event,
    Emitter<TeamChatState> emit,
  ) {
    emit(BackPressActionState());
  }

  FutureOr<void> _onLoadingEvent(
    LoadingEvent event,
    Emitter<TeamChatState> emit,
  ) {
    emit(LoadingState());
  }

  FutureOr<void> _onLoadingSuccessEvent(
    LoadingSuccessEvent event,
    Emitter<TeamChatState> emit,
  ) {
    emit(LoadingSuccessState());
  }

  FutureOr<void> _onLoadingErrorEvent(
    LoadingErrorEvent event,
    Emitter<TeamChatState> emit,
  ) {
    emit(
      LoadingErrorState(errorTitle: event.errorTitle, errorMsg: event.errorMsg),
    );
  }
}
