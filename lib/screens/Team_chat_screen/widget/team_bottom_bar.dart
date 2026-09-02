import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:berrytalks/Widgets_Component/Helper_Functions/attachmentSheetHelper.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppImages.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:berrytalks/screens/Chat_screen/widget/media_preview_screen.dart';
import 'package:berrytalks/screens/Team_chat_screen/bloc/team_chat_bloc.dart';
import 'package:berrytalks/screens/Chat_screen/widget/chat_bubble/quick_reply_bottm_sheet.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji_picker;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class TeamBottomBar extends StatefulWidget {
  /// Called after a send is dispatched (WhatsApp: jump list to latest).
  final String companyNumber;
  final VoidCallback? onMessageSent;

  const TeamBottomBar({super.key, required this.companyNumber, this.onMessageSent});

  @override
  State<TeamBottomBar> createState() => _TeamBottomBarState();
}

class _TeamBottomBarState extends State<TeamBottomBar> {
  final FocusNode focusNode = FocusNode();
  final TextEditingController messageController = TextEditingController();

  final ValueNotifier<bool> _hasTextNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<double> _dragOffsetYNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> _isDraggingMicNotifier = ValueNotifier<bool>(false);

  bool _isSending = false;

  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;
  StreamSubscription? _posSubscription;
  StreamSubscription? _durSubscription;
  StreamSubscription? _playerCompleteSubscription;
  

  @override
  void initState() {
    super.initState();
    messageController.addListener(() {
      final currentlyHasText = messageController.text.trim().isNotEmpty;
      if (_hasTextNotifier.value != currentlyHasText) {
        _hasTextNotifier.value = currentlyHasText;
      }
    });

    // Keyboard open → close emoji picker (never show both — causes overflow).
    focusNode.addListener(() {
      if (!mounted || !focusNode.hasFocus) return;
      final state = context.read<TeamChatBloc>().state;
      if (state is TeamChatDataLoadedState && state.showEmojiPicker) {
        context.read<TeamChatBloc>().add(ToggleEmojiPickerEvent());
      }
    });

    _posSubscription = _audioPlayer.onPositionChanged.listen((p) {
      final state = BlocProvider.of<TeamChatBloc>(context).state;
      if (state is TeamChatDataLoadedState) {
        BlocProvider.of<TeamChatBloc>(
          context,
        ).add(UpdatePreviewPositionEvent(p, state.previewTotalDuration));
      }
    });

    _durSubscription = _audioPlayer.onDurationChanged.listen((d) {
      final state = BlocProvider.of<TeamChatBloc>(context).state;
      if (state is TeamChatDataLoadedState) {
        BlocProvider.of<TeamChatBloc>(
          context,
        ).add(UpdatePreviewPositionEvent(state.previewPosition, d));
      }
    });

    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      BlocProvider.of<TeamChatBloc>(context).add(TogglePreviewPlaybackEvent());
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    messageController.dispose();
    _hasTextNotifier.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _timer?.cancel();
    _posSubscription?.cancel();
    _durSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    super.dispose();
  }

  bool _isImageFile(String path) {
    final mimeType = path.toLowerCase();
    return mimeType.endsWith('.jpg') ||
        mimeType.endsWith('.jpeg') ||
        mimeType.endsWith('.png') ||
        mimeType.endsWith('.webp') ||
        mimeType.endsWith('.gif');
  }

  Future<void> _startRecordingLogic() async {
    // Prefer cached grant — avoids slow permission dialog on every hold.
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) return;
    }
    if (!mounted) return;

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _audioRecorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
      path: path,
    );

    if (!mounted) return;
    BlocProvider.of<TeamChatBloc>(context).add(StartRecordingEvent());

    _timer?.cancel();
    Duration currentDuration = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      currentDuration += const Duration(seconds: 1);
      if (!mounted) return;
      BlocProvider.of<TeamChatBloc>(
        context,
      ).add(UpdateRecordingTimerEvent(currentDuration));
    });
  }

  bool _isSendingVoice = false;

  Future<void> _stopRecordingLogic(
    TeamChatDataLoadedState state, {
    required bool requestSend,
  }) async {
    _timer?.cancel();
    final path = await _audioRecorder.stop();

    if (path != null && path.isNotEmpty) {
      if (requestSend) {
        if (_isSendingVoice) return;
        _isSendingVoice = true;
        try {
          _sendMediaMessage(state, File(path), type: "voice");
          if (mounted) {
            BlocProvider.of<TeamChatBloc>(context).add(CancelRecordingEvent());
            widget.onMessageSent?.call();
          }
        } finally {
          Future.delayed(const Duration(milliseconds: 800), () {
            _isSendingVoice = false;
          });
        }
      } else {
        if (!mounted) return;
        BlocProvider.of<TeamChatBloc>(
          context,
        ).add(StopAndPreviewRecordingEvent(path));
      }
    }
  }

  Future<void> _cancelActiveRecording() async {
    _timer?.cancel();
    try {
      final path = await _audioRecorder.stop();
      if (path != null) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
    } catch (_) {}
    if (!mounted) return;
    BlocProvider.of<TeamChatBloc>(context).add(CancelRecordingEvent());
  }

  // void _sendMediaMessage(
  //   TeamChatDataLoadedState chatState,
  //   File file, {
  //   required String type,
  // }) {
  //   //final currentConversation = chatState.conversation;
  //  // if (currentConversation == null) return;

  //   // BlocProvider.of<TeamChatBloc>(context).add(
  //   //   SendMessageEvent(
  //   //     type: type,
  //   //     textBody: type == "text" ? messageController.text.trim() : "",
  //   //     phoneNumber: currentConversation.number ?? "",
  //   //     recipientNumber: _resolveRecipientNumber(chatState),
  //   //     chanelId: currentConversation.chanelId ?? "",
  //   //     name: currentConversation.agentName ?? "",
  //   //     agentId: currentConversation.agentId ?? "",
  //   //     conversationId: currentConversation.publicId ?? "",
  //   //     companyPublicId: currentConversation.companyPublicId ?? "",
  //   //     files: type != "text" ? [file] : const [],
  //   //   ),
  //   // );

  //   if (type == "text") {
  //     widget.onMessageSent?.call();
  //   }
  // }

  void _sendMediaMessage(
  TeamChatDataLoadedState chatState,
  File file, {
  required String type,
}) {
  final textBody = type == "text" ? messageController.text.trim() : "";
  
  // Agar text message hai aur text khali hai toh kuch na karein
  if (type == "text" && textBody.isEmpty) return;

  BlocProvider.of<TeamChatBloc>(context).add(
    SendTeamMessageEvent(
      type: type, // "text", "voice", "image", "document" etc.
      textBody: textBody,
      name: chatState.name,
      recipientAgentId: chatState.recipientAgentId,
      file: type != "text" ? file : null, // File pass ho rahi hai yahan
    ),
  );

  if (type == "text") {
    widget.onMessageSent?.call();
  }
}

  /// Prefer recipient from recent messages; fall back to company WhatsApp number.
  // String _resolveRecipientNumber(TeamChatDataLoadedState chatState) {
  //   for (final message in chatState.messages.reversed) {
  //     final number = message.recipientNumber?.trim();
  //     if (number != null && number.isNotEmpty) return number;
  //   }
  //   return widget.companyNumber;
  // }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = AppThemeUtilities.getCardColor(context);

    final currentBgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color borderColor = AppThemeUtilities.getAppBarShadowColor(context);
    final Color hintColor = AppThemeUtilities.getTimeColor(context);
    final Color textColor = AppThemeUtilities.getTextColor(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<TeamChatBloc, TeamChatState>(
      builder: (context, blocState) {
        if (blocState is! TeamChatDataLoadedState) {
          return Container(); 
        }
        final state = blocState;
        final bool isEmojiVisible = state.showEmojiPicker;
        final List<File> currentFiles = state.selectedFiles;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border(
              top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
   

              Row(
                children: [
                  if (!state.isRecording && !state.hasRecordedPreview) ...[
                   
                 
                   
                    InkWell(
                    
                      onTap: () {
    AttachmentSheetHelper.showAttachmentMenu(context, (
      List<File> files,
      String type, 
    ) {
      if (files.isNotEmpty) {
        final file = files.first;
        final chatBloc = BlocProvider.of<TeamChatBloc>(context);
        final chatState = chatBloc.state;

        if (chatState is TeamChatDataLoadedState) {
          final currentConversation = chatState.messages;
          if (currentConversation != null) {
           // final recipientNumber = _resolveRecipientNumber(chatState);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MediaPreviewScreen(
                  file: file,
                  isImage: _isImageFile(file.path),
                  fileName: file.path.split('/').last,
                  onSend: () {
                    // TeamChatBloc.add(
                    //   SendMessageEvent(
                    //     // Prefer picker type (video/image/document); bloc also
                    //     // resolves from file extension for WhatsApp streams.
                    //     type: type.isNotEmpty ? type : "media",
                    //     textBody: "",
                    //     phoneNumber: currentConversation.number ?? "",
                    //     recipientNumber: recipientNumber,
                    //     chanelId: currentConversation.chanelId ?? "",
                    //     name: currentConversation.agentName ?? "",
                    //     agentId: currentConversation.agentId ?? "",
                    //     conversationId: currentConversation.publicId ?? "",
                    //     companyPublicId: currentConversation.companyPublicId ?? "",
                    //     files: [file],
                    //   ),
                    // );
                  },
                ),
              ),
            );
          }
        }
      }
    });
  },
                      child: SvgPicture.asset(
                        AppImages.attachment,
                        width: 22,
                        height: 22,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF4A5568),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Container(width: 12),

                   
                    InkWell(
                      onTap: currentFiles.isNotEmpty
                          ? () {}
                          : () async {
                              final bloc = BlocProvider.of<TeamChatBloc>(context);
                              if (isEmojiVisible) {
                                // Switch back to keyboard.
                                bloc.add(ToggleEmojiPickerEvent());
                                focusNode.requestFocus();
                              } else {
                                // Close keyboard first, then open emoji
                                // (showing both overflows the Column).
                                focusNode.unfocus();
                                await Future<void>.delayed(
                                  const Duration(milliseconds: 120),
                                );
                                if (!mounted) return;
                                bloc.add(ToggleEmojiPickerEvent());
                              }
                            },
                      child: SvgPicture.asset(
                        isEmojiVisible
                            ? AppImages.keyboard
                            : AppImages
                                  .emoji, 
                        width: 22,
                        height: 22,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF4A5568),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Container(width: 12),
                  ],

                  Expanded(
                    child: state.hasRecordedPreview
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white10
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _buildAudioPreviewWidget(state, textColor),
                          )
                        : state.isRecording
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white10
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: _buildRecordingTrackWidget(state, textColor),
                              )
                            : _buildStandardInputWidget(state, textColor),
                  ),

                  ValueListenableBuilder<bool>(
                    valueListenable: _hasTextNotifier,
                    builder: (context, hasText, child) {
                      // WhatsApp: locked recording → send button (not mic).
                      final bool showSendButton = hasText ||
                          state.hasRecordedPreview ||
                          state.isRecordingLocked;

                      return Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: showSendButton
                            ? InkWell(
                                onTap: () async {
                                  if (state.isRecordingLocked) {
                                    final latest =
                                        context.read<TeamChatBloc>().state;
                                    if (latest is TeamChatDataLoadedState) {
                                      await _stopRecordingLogic(
                                        latest,
                                        requestSend: true,
                                      );
                                    }
                                    return;
                                  }
                                  if (state.hasRecordedPreview) {
                                    if (state.recordedFilePath != null) {
                                      _sendMediaMessage(
                                        state,
                                        File(state.recordedFilePath!),
                                        type: "voice",
                                      );
                                    }
                                    BlocProvider.of<TeamChatBloc>(
                                      context,
                                    ).add(CancelRecordingEvent());
                                    widget.onMessageSent?.call();
                                  } else {
                                    _sendMediaMessage(
                                      state,
                                      File(''),
                                      type: "text",
                                    );
                                    messageController.clear();
                                    focusNode.requestFocus();
                                    widget.onMessageSent?.call();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppThemeUtilities.HexToColor(
                                      "#2EAD65",
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: SvgPicture.asset(
                                    AppImages.send,
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                              )
                            : _buildMicSection(state),
                      );
                    },
                  ),
                ],
              ),

              if (isEmojiVisible)
                Builder(
                  builder: (context) {
                    final media = MediaQuery.of(context);
                    // Keep picker below ~1/3 screen and never fight the keyboard.
                    final double emojiHeight = (media.size.height * 0.32)
                        .clamp(180.0, 250.0);
                    if (media.viewInsets.bottom > 0) {
                      return const SizedBox.shrink();
                    }
                    return SizedBox(
                      height: emojiHeight,
                      width: media.size.width,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: emoji_picker.EmojiPicker(
                          textEditingController: messageController,
                          config: emoji_picker.Config(
                            height: emojiHeight,
                            checkPlatformCompatibility: true,
                            emojiViewConfig: emoji_picker.EmojiViewConfig(
                              columns: 9,
                              emojiSizeMax: 25,
                              backgroundColor: backgroundColor,
                            ),
                            searchViewConfig: emoji_picker.SearchViewConfig(
                              backgroundColor: backgroundColor,
                              buttonIconColor: hintColor,
                              hintText: "Search emoji...",
                            ),
                            categoryViewConfig: emoji_picker.CategoryViewConfig(
                              backgroundColor: backgroundColor,
                              indicatorColor:
                                  AppThemeUtilities.HexToColor("#2ead65"),
                              iconColorSelected:
                                  AppThemeUtilities.HexToColor("#2ead65"),
                              iconColor: hintColor,
                              initCategory: emoji_picker.Category.RECENT,
                            ),
                            bottomActionBarConfig:
                                emoji_picker.BottomActionBarConfig(
                              backgroundColor: backgroundColor,
                              buttonColor: backgroundColor,
                              buttonIconColor: hintColor,
                            ),
                            skinToneConfig: emoji_picker.SkinToneConfig(
                              enabled: true,
                              dialogBackgroundColor: currentBgColor,
                              indicatorColor:
                                  AppThemeUtilities.appGreyBorderColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

Widget _buildMicSection(TeamChatDataLoadedState state) {
    final bool showLockIndicator =
        state.isRecording && !state.isRecordingLocked;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            top: showLockIndicator ? -95 : 10,
            child: AnimatedOpacity(
              opacity: showLockIndicator ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.grey,
                    size: 20,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 6, bottom: 2),
                    child: const Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: Colors.grey,
                      size: 14,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    child: const Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: Colors.grey,
                      size: 14,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    child: const Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: Colors.grey,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ~150ms hold (not Flutter's default ~500ms) — WhatsApp-like start.
          RawGestureDetector(
            gestures: <Type, GestureRecognizerFactory>{
              LongPressGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<
                      LongPressGestureRecognizer>(
                () => LongPressGestureRecognizer(
                  duration: const Duration(milliseconds: 150),
                ),
                (LongPressGestureRecognizer instance) {
                  instance.onLongPressStart = (details) {
                    _isDraggingMicNotifier.value = true;
                    _startRecordingLogic();
                  };
                  instance.onLongPressMoveUpdate = (details) {
                    final latest = context.read<TeamChatBloc>().state;
                    if (latest is! TeamChatDataLoadedState) return;
                    if (details.localPosition.dy < -50 &&
                        !latest.isRecordingLocked) {
                      context.read<TeamChatBloc>().add(LockRecordingEvent());
                    }
                  };
                  instance.onLongPressEnd = (details) {
                    _isDraggingMicNotifier.value = false;
                    // Read fresh state — build-time `state` is stale after lock.
                    final latest = context.read<TeamChatBloc>().state;
                    if (latest is TeamChatDataLoadedState &&
                        latest.isRecording &&
                        !latest.isRecordingLocked) {
                      _stopRecordingLogic(latest, requestSend: true);
                    }
                  };
                  instance.onLongPressCancel = () {
                    _isDraggingMicNotifier.value = false;
                    final latest = context.read<TeamChatBloc>().state;
                    if (latest is TeamChatDataLoadedState &&
                        latest.isRecording &&
                        !latest.isRecordingLocked) {
                      _cancelActiveRecording();
                    }
                  };
                },
              ),
            },
            child: ValueListenableBuilder<bool>(
              valueListenable: _isDraggingMicNotifier,
              builder: (context, isDragging, child) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: state.isRecording
                        ? AppThemeUtilities.HexToColor("#FF5252")
                        : AppThemeUtilities.HexToColor("#2EAD65"),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    state.isRecording ? Icons.mic : Icons.mic_none_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildStandardInputWidget(TeamChatDataLoadedState state, Color textColor) {
    final currentBgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color hintColor = AppThemeUtilities.getTimeColor(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: currentBgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
      ),
      child: TextField(
        cursorColor: AppThemeUtilities.HexToColor("#010207"),
        controller: messageController,
        minLines: 1,
        maxLines: 5,
        focusNode: focusNode,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: "Type a message...",
          hintStyle: GoogleFonts.poppins(fontSize: 14, color: hintColor),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        style: GoogleFonts.poppins(fontSize: 14),
      ),
    );
  }

  Widget _buildRecordingTrackWidget(
    TeamChatDataLoadedState state,
    Color textColor,
  ) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(right: 8),
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        Text(
          _formatDuration(state.recordingDuration),
          style: GoogleFonts.poppins(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          state.isRecordingLocked
              ? "Recording locked..."
              : "Slide up to lock recording",
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
        ),
        Container(width: 8),
        // Locked: trash cancels (send is the green button on the right).
        if (state.isRecordingLocked)
          InkWell(
            onTap: _cancelActiveRecording,
            child: Icon(
              Icons.delete_outline_rounded,
              color: Colors.red.shade600,
              size: 22,
            ),
          ),
      ],
    );
  }

  Widget _buildAudioPreviewWidget(TeamChatDataLoadedState state, Color textColor) {
    double progress = 0.0;
    if (state.previewTotalDuration.inMilliseconds > 0) {
      progress =
          state.previewPosition.inMilliseconds /
          state.previewTotalDuration.inMilliseconds;
    }

    return Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.delete_outline_rounded,
            color: Colors.red.shade600,
            size: 22,
          ),
          onPressed: () {
            if (state.recordedFilePath != null) {
              final file = File(state.recordedFilePath!);
              if (file.existsSync()) file.deleteSync();
            }
            BlocProvider.of<TeamChatBloc>(context).add(CancelRecordingEvent());
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Container(width: 12),
        IconButton(
          icon: Icon(
            state.isPlayingPreview
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            color: textColor,
            size: 24,
          ),
          onPressed: () async {
            if (state.recordedFilePath == null) return;
            if (state.isPlayingPreview) {
              await _audioPlayer.pause();
              BlocProvider.of<TeamChatBloc>(
                context,
              ).add(TogglePreviewPlaybackEvent());
            } else {
              await _audioPlayer.play(
                DeviceFileSource(state.recordedFilePath!),
              );
              BlocProvider.of<TeamChatBloc>(
                context,
              ).add(TogglePreviewPlaybackEvent());
            }
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppThemeUtilities.HexToColor("#2ead65"),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ),
        Text(
          _formatDuration(
            state.isPlayingPreview
                ? state.previewPosition
                : state.recordingDuration,
          ),
          style: GoogleFonts.poppins(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds.remainder(60))}';
  }
}
