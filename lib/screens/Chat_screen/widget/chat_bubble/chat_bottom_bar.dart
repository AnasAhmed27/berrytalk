import 'dart:async';
import 'dart:io';
import 'package:berrytalks/Widgets_Component/EditText.dart';
import 'package:berrytalks/Widgets_Component/Helper_Functions/attachmentSheetHelper.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppImages.dart';
import 'package:berrytalks/network/ApiService.dart';
import 'package:berrytalks/screens/Chat_screen/widget/chat_bubble/quick_reply_bottm_sheet.dart';
import 'package:berrytalks/screens/Chat_screen/widget/media_preview_screen.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji_picker;
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:berrytalks/screens/Chat_screen/bloc/chat_screen_bloc.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';

class ChatBottomBar extends StatefulWidget {
  final String companyNumber;
  final VoidCallback? onMessageSent;

  const ChatBottomBar({super.key, required this.companyNumber, this.onMessageSent});

  @override
  State<ChatBottomBar> createState() => _ChatBottomBarState();
}

class _ChatBottomBarState extends State<ChatBottomBar>
    with TickerProviderStateMixin {
  final FocusNode focusNode = FocusNode();
  final TextEditingController messageController = TextEditingController();

  final ValueNotifier<bool> _hasTextNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<double> _dragOffsetYNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<double> _dragOffsetXNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> _isDraggingMicNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<double> _playbackSpeedNotifier = ValueNotifier<double>(1.0);

  bool _isSending = false;
  bool _isSendingVoice = false;
  bool _recordingCancelledByGesture = false;

  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;
  StreamSubscription? _posSubscription;
  StreamSubscription? _durSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription<Amplitude>? _ampSubscription;
  List<String> _segmentPaths = [];

  late final AnimationController _lockController;
  late final Animation<double> _lockFadeAnimation;

  late final AnimationController _arrowController;
  late final Animation<double> _arrowTranslationAnimation;

  late final AnimationController _micScaleController;
  late final Animation<double> _micScaleAnimation;

  @override
  void initState() {
    super.initState();
    messageController.addListener(() {
      final currentlyHasText = messageController.text.trim().isNotEmpty;
      if (_hasTextNotifier.value != currentlyHasText) {
        _hasTextNotifier.value = currentlyHasText;
      }
    });

    focusNode.addListener(() {
      if (!mounted || !focusNode.hasFocus) return;
      final state = context.read<ChatBloc>().state;
      if (state is ChatDataLoadedState && state.showEmojiPicker) {
        context.read<ChatBloc>().add(ToggleEmojiPickerEvent());
      }
    });

    _posSubscription = _audioPlayer.onPositionChanged.listen((p) {
      final state = BlocProvider.of<ChatBloc>(context).state;
      if (state is ChatDataLoadedState) {
        BlocProvider.of<ChatBloc>(
          context,
        ).add(UpdatePreviewPositionEvent(p, state.previewTotalDuration));
      }
    });

    _durSubscription = _audioPlayer.onDurationChanged.listen((d) {
      final state = BlocProvider.of<ChatBloc>(context).state;
      if (state is ChatDataLoadedState) {
        BlocProvider.of<ChatBloc>(
          context,
        ).add(UpdatePreviewPositionEvent(state.previewPosition, d));
      }
    });

    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      BlocProvider.of<ChatBloc>(context).add(TogglePreviewPlaybackEvent());
    });

    _lockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _lockFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lockController, curve: Curves.easeIn),
    );

    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _arrowTranslationAnimation = Tween<double>(begin: 0.0, end: -12.0).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );

    _micScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _micScaleAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: _micScaleController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    focusNode.dispose();
    messageController.dispose();
    _hasTextNotifier.dispose();
    _dragOffsetYNotifier.dispose();
    _dragOffsetXNotifier.dispose();
    _isDraggingMicNotifier.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _timer?.cancel();
    _ampSubscription?.cancel();
    _posSubscription?.cancel();
    _durSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _lockController.dispose();
    _arrowController.dispose();
    _micScaleController.dispose();
    _playbackSpeedNotifier.dispose();
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

  void _listenAmplitude() {
    _ampSubscription?.cancel();
    _ampSubscription = _audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 40))
        .listen((amp) {
      if (!mounted) return;
      final double db = amp.current;
      final double normalized = ((db + 60) / 60).clamp(0.05, 1.0);
      BlocProvider.of<ChatBloc>(context).add(AmplitudeChangedEvent(normalized));
    });
  }

  Future<void> _cyclePlaybackSpeed() async {
  final double next = _playbackSpeedNotifier.value == 1.0
      ? 1.5
      : _playbackSpeedNotifier.value == 1.5
          ? 2.0
          : 1.0;
  _playbackSpeedNotifier.value = next;
  await _audioPlayer.setPlaybackRate(next);
}

  Future<void> _startRecordingLogic() async {
    _recordingCancelledByGesture = false;
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) return;
    }
    if (!mounted) return;

    _segmentPaths = [];

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _audioRecorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
      path: path,
    );

    if (!mounted) return;
    BlocProvider.of<ChatBloc>(context).add(StartRecordingEvent());
    _listenAmplitude();

    _timer?.cancel();
    Duration currentDuration = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      currentDuration += const Duration(seconds: 1);
      if (!mounted) return;
      BlocProvider.of<ChatBloc>(
        context,
      ).add(UpdateRecordingTimerEvent(currentDuration));
    });
  }

  Future<void> _stopRecordingLogic(ChatDataLoadedState state) async {
    if (_recordingCancelledByGesture) return;
    _timer?.cancel();
    _ampSubscription?.cancel();
    final path = await _audioRecorder.stop();

    if (path == null || path.isEmpty) return;
    if (_isSendingVoice) return;
    _isSendingVoice = true;
    try {
      _sendMediaMessage(state, File(path), type: "voice");
      if (mounted) {
        BlocProvider.of<ChatBloc>(context).add(CancelRecordingEvent());
        widget.onMessageSent?.call();
      }
    } finally {
      Future.delayed(const Duration(milliseconds: 800), () {
        _isSendingVoice = false;
      });
    }
  }

  Future<void> _cancelActiveRecording() async {
    _recordingCancelledByGesture = true; 
    _timer?.cancel();
    _ampSubscription?.cancel();
    try {
      final path = await _audioRecorder.stop();
      if (path != null) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
    } catch (_) {}
    _segmentPaths = [];
    _dragOffsetXNotifier.value = 0.0;
    _dragOffsetYNotifier.value = 0.0;
    if (!mounted) return;
    BlocProvider.of<ChatBloc>(context).add(CancelRecordingEvent());
  }

  Future<void> _cancelLockedOrPreviewRecording(ChatDataLoadedState state) async {
    _timer?.cancel();
    _ampSubscription?.cancel();
    if (state.isPlayingPreview) {
      await _audioPlayer.stop();
    }
    try {
      final path = await _audioRecorder.stop();
      if (path != null) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
    } catch (_) {}

    for (final p in _segmentPaths) {
      try {
        final file = File(p);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
    _segmentPaths = [];

    if (!mounted) return;
    BlocProvider.of<ChatBloc>(context).add(CancelRecordingEvent());
  }

  Future<void> _pauseRecording() async {
    _timer?.cancel();
    _ampSubscription?.cancel();
    final path = await _audioRecorder.stop();
    if (!mounted) return;
    if (path != null && path.isNotEmpty) {
      _segmentPaths.add(path);
      BlocProvider.of<ChatBloc>(context).add(StopAndPreviewRecordingEvent(path));
    }
  }

  Future<void> _resumeRecording(ChatDataLoadedState state) async {
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

    BlocProvider.of<ChatBloc>(context).add(ResumeRecordingEvent());
    _listenAmplitude();

    int seconds = state.recordingDuration.inSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      seconds++;
      if (!mounted) return;
      BlocProvider.of<ChatBloc>(
        context,
      ).add(UpdateRecordingTimerEvent(Duration(seconds: seconds)));
    });
  }

  Future<String?> _mergeSegments(List<String> segments) async {
    try {
      final dir = await getTemporaryDirectory();
      final listFile = File(
        '${dir.path}/voice_concat_${DateTime.now().millisecondsSinceEpoch}.txt',
      );
      final buffer = StringBuffer();
      for (final path in segments) {
        buffer.writeln("file '$path'");
      }
      await listFile.writeAsString(buffer.toString());

      final outputPath =
          '${dir.path}/voice_final_${DateTime.now().millisecondsSinceEpoch}.m4a';

      final session = await FFmpegKit.execute(
        '-f concat -safe 0 -i "${listFile.path}" -c copy "$outputPath"',
      );
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return outputPath;
      }
      debugPrint("ffmpeg merge failed, falling back to last segment");
      return null;
    } catch (e) {
      debugPrint("Segment merge error: $e");
      return null;
    }
  }

  Future<void> _finalizeAndSendRecording(ChatDataLoadedState state) async {
    if (_isSendingVoice) return;
    _isSendingVoice = true;
    try {
      _timer?.cancel();
      _ampSubscription?.cancel();
      if (state.isPlayingPreview) {
        await _audioPlayer.stop();
      }

      final segments = List<String>.from(_segmentPaths);
      if (!state.hasRecordedPreview) {
        final path = await _audioRecorder.stop();
        if (path != null && path.isNotEmpty) segments.add(path);
      }

      if (segments.isEmpty) {
        if (mounted) {
          BlocProvider.of<ChatBloc>(context).add(CancelRecordingEvent());
        }
        return;
      }

      final String finalPath;
      if (segments.length == 1) {
        finalPath = segments.first;
      } else {
        finalPath = await _mergeSegments(segments) ?? segments.last;
      }

      _sendMediaMessage(state, File(finalPath), type: "voice");
      if (mounted) {
        BlocProvider.of<ChatBloc>(context).add(CancelRecordingEvent());
        widget.onMessageSent?.call();
      }
      _segmentPaths = [];
    } finally {
      Future.delayed(const Duration(milliseconds: 800), () {
        _isSendingVoice = false;
      });
    }
  }

  void _sendMediaMessage(
    ChatDataLoadedState chatState,
    File file, {
    required String type,
  }) {
    final currentConversation = chatState.conversation;
    if (currentConversation == null) return;

    BlocProvider.of<ChatBloc>(context).add(
      SendMessageEvent(
        type: type,
        textBody: type == "text" ? messageController.text.trim() : "",
        phoneNumber: currentConversation.number ?? "",
        recipientNumber: widget.companyNumber,
        chanelId: currentConversation.chanelId ?? "",
        name: currentConversation.agentName ?? "",
        agentId: currentConversation.agentId ?? "",
        conversationId: currentConversation.publicId ?? "",
        companyPublicId: currentConversation.companyPublicId ?? "",
        files: type != "text" ? [file] : const [],
      ),
    );

    if (type == "text") {
      widget.onMessageSent?.call();
    }
  }

  Widget _buildReplyPreview(InboxMessage msg) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String senderName =
        msg.isSent == 'true' ? 'You' : (msg.contactName ?? 'Customer');
    final String preview =
        msg.messageType == 'media' ? '📎 Media' : (msg.body ?? '');

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: AppThemeUtilities.HexToColor("#2EAD65"),
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  senderName,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppThemeUtilities.HexToColor("#2EAD65"),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              context.read<ChatBloc>().add(
                    SetReplyMessageEvent(replyMessage: null),
                  );
            },
            child: Icon(
              Icons.close_rounded,
              size: 18,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = AppThemeUtilities.getCardColor(context);
    final currentBgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color borderColor = AppThemeUtilities.getAppBarShadowColor(context);
    final Color hintColor = AppThemeUtilities.getTimeColor(context);
    final Color textColor = AppThemeUtilities.getTextColor(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<ChatBloc, ChatState>(
      listenWhen: (previous, current) {
        if (current is! ChatDataLoadedState) return false;
        if (previous is! ChatDataLoadedState) return true;
        return previous.isRecording != current.isRecording;
      },
      listener: (context, blocState) {
        if (blocState is! ChatDataLoadedState) return;
        if (blocState.isRecording) {
          _micScaleController.forward();
          _lockController.forward();
          _arrowController.repeat(reverse: true);
        } else {
          _micScaleController.reverse();
          _lockController.reverse();
          _arrowController.stop();
          _dragOffsetYNotifier.value = 0.0;
          _dragOffsetXNotifier.value = 0.0;
        }
      },
      buildWhen: (previous, current) {
        if (current is! ChatDataLoadedState) return false;
        if (previous is! ChatDataLoadedState) return true;
        // replyingToMessage change pe rebuild karo
        return previous.replyingToMessage != current.replyingToMessage ||
            previous.isRecording != current.isRecording ||
            previous.hasRecordedPreview != current.hasRecordedPreview ||
            previous.showEmojiPicker != current.showEmojiPicker ||
            previous.isRecordingLocked != current.isRecordingLocked ||
            previous.recordingDuration != current.recordingDuration ||
            previous.recordedSamples != current.recordedSamples ||
            previous.isPlayingPreview != current.isPlayingPreview ||
            previous.previewPosition != current.previewPosition;
      },
      builder: (context, blocState) {
        if (blocState is! ChatDataLoadedState) {
          return Container();
        }
        final state = blocState;
        final bool isEmojiVisible = state.showEmojiPicker;
        final List<File> currentFiles = state.selectedFiles;
        final bool isLockedOrPreview =
            state.isRecordingLocked || state.hasRecordedPreview;

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
              if (state.replyingToMessage != null)
                _buildReplyPreview(state.replyingToMessage!),
              Row(
                children: [
                  if (!state.isRecording && !state.hasRecordedPreview) ...[
                    InkWell(
                      onTap: currentFiles.isNotEmpty
                          ? () {}
                          : () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                builder: (context) => QuickRepliesBottomSheet(
                                  controller: messageController,
                                ),
                              );
                            },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.transparent
                              : AppThemeUtilities.HexToColor("#F0F9F4"),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SvgPicture.asset(
                          AppImages.thunder,
                          width: 22,
                          height: 22,
                        ),
                      ),
                    ),
                    Container(width: 12),
                    InkWell(
                      onTap: () {
                        AttachmentSheetHelper.showAttachmentMenu(context, (
                          List<File> files,
                          String type,
                        ) {
                          if (files.isNotEmpty) {
                            final file = files.first;
                            final chatBloc = BlocProvider.of<ChatBloc>(context);
                            final chatState = chatBloc.state;

                            if (chatState is ChatDataLoadedState) {
                              final currentConversation = chatState.conversation;
                              if (currentConversation != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MediaPreviewScreen(
                                      file: file,
                                      isImage: _isImageFile(file.path),
                                      fileName: file.path.split('/').last,
                                      onSend: () {
                                        chatBloc.add(
                                          SendMessageEvent(
                                            type: type.isNotEmpty ? type : "media",
                                            textBody: "",
                                            phoneNumber:
                                                currentConversation.number ?? "",
                                            recipientNumber: widget.companyNumber,
                                            chanelId:
                                                currentConversation.chanelId ?? "",
                                            name:
                                                currentConversation.agentName ?? "",
                                            agentId:
                                                currentConversation.agentId ?? "",
                                            conversationId:
                                                currentConversation.publicId ?? "",
                                            companyPublicId: currentConversation
                                                    .companyPublicId ??
                                                "",
                                            files: [file],
                                          ),
                                        );
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
                              final bloc = BlocProvider.of<ChatBloc>(context);
                              if (isEmojiVisible) {
                                bloc.add(ToggleEmojiPickerEvent());
                                focusNode.requestFocus();
                              } else {
                                focusNode.unfocus();
                                await Future<void>.delayed(
                                  const Duration(milliseconds: 120),
                                );
                                if (!mounted) return;
                                bloc.add(ToggleEmojiPickerEvent());
                              }
                            },
                      child: SvgPicture.asset(
                        isEmojiVisible ? AppImages.keyboard : AppImages.emoji,
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
                    child: isLockedOrPreview
                        ? _buildLockedBar(state, textColor)
                        : state.isRecording
                            ? _buildSlideToCancelPill(state)
                            : _buildStandardInputWidget(state, textColor),
                  ),

                  ValueListenableBuilder<bool>(
                    valueListenable: _hasTextNotifier,
                    builder: (context, hasText, child) {
                      if (isLockedOrPreview) {
                        return const SizedBox.shrink();
                      }

                      final bool showSendButton = hasText && !state.isRecording;

                      return Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: showSendButton
                            ? InkWell(
                                onTap: () {
                                  _sendMediaMessage(
                                    state,
                                    File(''),
                                    type: "text",
                                  );
                                  messageController.clear();
                                  focusNode.requestFocus();
                                  widget.onMessageSent?.call();
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

  // ================= Mic button + slide-to-lock indicator =================

  Widget _buildMicSection(ChatDataLoadedState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomRight,
        children: [
          if (state.isRecording && !state.isRecordingLocked)
            _buildLockIndicator(),
          AnimatedBuilder(
            animation: Listenable.merge([
              _dragOffsetXNotifier,
              _dragOffsetYNotifier,
              _micScaleAnimation,
            ]),
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  _dragOffsetXNotifier.value,
                  _dragOffsetYNotifier.value,
                ),
                child: ScaleTransition(
                  scale: _micScaleAnimation,
                  child: child,
                ),
              );
            },
            child: RawGestureDetector(
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
                      _dragOffsetXNotifier.value = 0.0;
                      _dragOffsetYNotifier.value = 0.0;
                      _startRecordingLogic();
                    };
                    instance.onLongPressMoveUpdate = (details) {
                      final latest = context.read<ChatBloc>().state;
                      if (latest is! ChatDataLoadedState) return;
                      if (latest.isRecordingLocked) return;

                      final dx = details.localOffsetFromOrigin.dx;
                      final dy = details.localOffsetFromOrigin.dy;

                      if (dy.abs() > dx.abs() && dy < 0) {
                        final clampedDy = dy.clamp(-120.0, 0.0);
                        _dragOffsetYNotifier.value = clampedDy;
                        _dragOffsetXNotifier.value = 0.0;
                        if (clampedDy <= -90) {
                          context.read<ChatBloc>().add(LockRecordingEvent());
                          _dragOffsetYNotifier.value = 0.0;
                        }
                      } else if (dx < 0) {
                        final clampedDx = dx.clamp(-140.0, 0.0);
                        _dragOffsetXNotifier.value = clampedDx;
                        _dragOffsetYNotifier.value = 0.0;
                        if (clampedDx <= -130) {
                          _isDraggingMicNotifier.value = false;
                          _cancelActiveRecording();
                        }
                      }
                    };
                    instance.onLongPressEnd = (details) {
                      _isDraggingMicNotifier.value = false;
                      if (_recordingCancelledByGesture) return;
                      final latest = context.read<ChatBloc>().state;
                      if (latest is ChatDataLoadedState &&
                          latest.isRecording &&
                          !latest.isRecordingLocked) {
                        _stopRecordingLogic(latest);
                      }
                    };
                    instance.onLongPressCancel = () {
                      _isDraggingMicNotifier.value = false;
                      if (_recordingCancelledByGesture) return;
                      final latest = context.read<ChatBloc>().state;
                      if (latest is ChatDataLoadedState &&
                          latest.isRecording &&
                          !latest.isRecordingLocked) {
                        _cancelActiveRecording();
                      }
                    };
                  },
                ),
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: state.isRecording
                      ? AppThemeUtilities.HexToColor("#FF5252")
                      : AppThemeUtilities.HexToColor("#2EAD65"),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  state.isRecording ? Icons.mic : Icons.mic_none_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockIndicator() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned(
      bottom: 18,
      right: 0,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _lockController,
          _arrowController,
          _dragOffsetYNotifier,
        ]),
        builder: (context, child) {
          final double currentDy = _dragOffsetYNotifier.value.clamp(-120.0, 0.0);
          final bool isNearLock = currentDy <= -75;

          return Opacity(
            opacity: _lockFadeAnimation.value,
            child: Transform.translate(
              offset: Offset(0, currentDy * 0.45),
              child: Container(
                width: 48,
                height: 130,
                padding: const EdgeInsets.only(top: 14, bottom: 20),
                decoration: BoxDecoration(
                  color:  isDark ? Colors.white10 : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      isNearLock ? Icons.lock_rounded : Icons.lock_open_rounded,
                      color: isNearLock
                        ? const Color(0xFF00A884)
                        : (isDark ? Colors.white70 : Colors.black54),
                      size: 22,
                    ),
                    const SizedBox(height: 16),
                    AnimatedBuilder(
                      animation: _arrowTranslationAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _arrowTranslationAnimation.value),
                          child: child,
                        );
                      },
                      child:  Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: isDark ? Colors.white54 : Colors.black38,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlideToCancelPill(ChatDataLoadedState state) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 48,
      padding: const EdgeInsets.only(left: 14, right: 14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.mic, color: Colors.redAccent, size: 22),
          const SizedBox(width: 8),
          Text(
            _formatDuration(state.recordingDuration),
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const Spacer(),
          ValueListenableBuilder<double>(
            valueListenable: _dragOffsetXNotifier,
            builder: (context, dx, _) {
              return Opacity(
                opacity: (1.0 + (dx / 140)).clamp(0.0, 1.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.chevron_left, color: Colors.grey, size: 18),
                    const SizedBox(width: 2),
                    Text(
                      "Slide to cancel",
                      style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= Standard text field =================

  Widget _buildStandardInputWidget(ChatDataLoadedState state, Color textColor) {
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

  // ================= Locked bar (waveform + trash/pause-resume/send) =================

  Widget _buildLockedBar(ChatDataLoadedState state, Color textColor) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isPaused = state.hasRecordedPreview;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2C34) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: isPaused
                ? _buildPausedPreviewRow(state, textColor)
                : _buildLiveRecordingRow(state, textColor),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: () => _cancelLockedOrPreviewRecording(state),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red.shade600,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      isPaused ? _resumeRecording(state) : _pauseRecording(),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: isPaused
                          ? AppThemeUtilities.HexToColor("#2EAD65")
                              .withOpacity(0.12)
                          : (isDark ? Colors.white10 : Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isPaused ? Icons.mic_none_rounded : Icons.pause_rounded,
                          color: isPaused
                              ? AppThemeUtilities.HexToColor("#2EAD65")
                              : textColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isPaused ? "Resume" : "Pause",
                          style: GoogleFonts.poppins(
                            color: isPaused
                                ? AppThemeUtilities.HexToColor("#2EAD65")
                                : textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _finalizeAndSendRecording(state),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppThemeUtilities.HexToColor("#2EAD65"),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveRecordingRow(ChatDataLoadedState state, Color textColor) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
  final Color barColor = isDark ? Colors.white : Colors.black87;
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
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 28,
            child: ChatVoiceWaveform(
              samples: state.recordedSamples,
              isPlayback: false,
              
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPausedPreviewRow(ChatDataLoadedState state, Color textColor) {
    double progress = 0.0;
    if (state.previewTotalDuration.inMilliseconds > 0) {
      progress = state.previewPosition.inMilliseconds /
          state.previewTotalDuration.inMilliseconds;
    }

    return Row(
      children: [
        GestureDetector(
          onTap: () async {
            if (state.recordedFilePath == null) return;
            if (state.isPlayingPreview) {
              await _audioPlayer.pause();
              BlocProvider.of<ChatBloc>(context).add(TogglePreviewPlaybackEvent());
            } else {
              await _audioPlayer.play(
                DeviceFileSource(state.recordedFilePath!),
              );
              BlocProvider.of<ChatBloc>(context).add(TogglePreviewPlaybackEvent());
            }
          },
          child: Icon(
            state.isPlayingPreview
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            color: textColor,
            size: 26,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 28,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final dotLeft =
                    (constraints.maxWidth - 10) * progress.clamp(0.0, 1.0);
                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    ChatVoiceWaveform(
                      samples: state.recordedSamples,
                      isPlayback: true,
                    ),
                    Positioned(
                      left: dotLeft.clamp(0.0, constraints.maxWidth - 10),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppThemeUtilities.HexToColor("#2EAD65"),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
                const SizedBox(width: 8),
        ValueListenableBuilder<double>(
          valueListenable: _playbackSpeedNotifier,
          builder: (context, speed, _) {
            return GestureDetector(
              onTap: _cyclePlaybackSpeed,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppThemeUtilities.HexToColor("#2EAD65").withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${speed == speed.roundToDouble() ? speed.toInt() : speed}x",
                  style: GoogleFonts.poppins(
                    color: AppThemeUtilities.HexToColor("#2EAD65"),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}

// ================= WhatsApp-style waveform (shared by live + preview) =================
//
// Named distinctly (Chat-prefixed) so it never collides if some other part
// of the app also has a demo/reference copy of the same widget.

class ChatVoiceWaveform extends StatelessWidget {
  final List<double> samples;
  final bool isPlayback;
  final Color? color;

  const ChatVoiceWaveform({
    super.key,
    required this.samples,
    this.isPlayback = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color effectiveColor = color ?? (isDark ? Colors.white : Colors.black87);
    return CustomPaint(
      size: const Size(double.infinity, 28.0),
      painter: ChatVoiceWaveformPainter(
        samples: samples,
        isPlayback: isPlayback,
        color: effectiveColor,
      ),
    );
  }
}

class ChatVoiceWaveformPainter extends CustomPainter {
  final List<double> samples;
  final bool isPlayback;
  final Color color;

  ChatVoiceWaveformPainter({
    required this.samples,
    this.isPlayback = false,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty) return;

    const double barWidth = 1.0;
    const double barGap = 1.5;
    const double barStep = barWidth + barGap;
    const double minHeight = 1.1;

    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth;

    final int maxFitBars = (size.width / barStep).floor();

    if (!isPlayback) {
      final int sampleCount = samples.length;
      for (int i = 0; i < maxFitBars; i++) {
        int sampleIndex = sampleCount - 1 - i;
        if (sampleIndex < 0) break;

        double sampleVal = samples[sampleIndex];
        double height = minHeight + (sampleVal * (size.height - minHeight));
        double x = size.width - (i * barStep) - (barWidth / 2);

        canvas.drawLine(
          Offset(x, (size.height / 2) - (height / 2)),
          Offset(x, (size.height / 2) + (height / 2)),
          paint,
        );
      }
    } else {
      final int totalBars = maxFitBars;
      if (totalBars <= 0) return;

      for (int i = 0; i < totalBars; i++) {
        final int sampleIndex =
            ((i / totalBars) * samples.length).floor().clamp(
                  0,
                  samples.length - 1,
                );
        double sampleVal = samples[sampleIndex];
        double height = minHeight + (sampleVal * (size.height - minHeight));
        double x = (i * barStep) + (barWidth / 2);

        canvas.drawLine(
          Offset(x, (size.height / 2) - (height / 2)),
          Offset(x, (size.height / 2) + (height / 2)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant ChatVoiceWaveformPainter oldDelegate) {
    return true;
  }
}