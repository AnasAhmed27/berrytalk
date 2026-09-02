import 'dart:io';

import 'package:berrytalks/Widgets_Component/Utils/AppConstants.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppUitilities.dart';
import 'package:berrytalks/Widgets_Component/Utils/MediaUrlResolver.dart';
import 'package:berrytalks/main.dart';
import 'package:berrytalks/screens/Chat_screen/widget/chat_bubble/audio_bubble.dart';
import 'package:berrytalks/screens/Chat_screen/widget/chat_bubble/cached_video_thumbnail.dart';
import 'package:berrytalks/screens/Team_chat_screen/bloc/team_chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

class TeamBubble extends StatelessWidget {
  final String? message;
  final String time;
  final bool isMe;
  final String initials;
  final String messageType;
  final String? filePath;
  final int currentMessageIndex;
  final List<dynamic> allMessagesList;

  const TeamBubble({
    super.key,
    required this.message,
    required this.time,
    required this.isMe,
    required this.initials,
    required this.messageType,
    this.filePath,
    required this.currentMessageIndex,
    required this.allMessagesList,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color mainTextColor = AppThemeUtilities.getTextColor(context);
    final Color subTextColor = AppThemeUtilities.getTimeColor(context);
    final Color incomingBubbleColor = AppThemeUtilities.getCardColor(context);
    final Color borderColor = AppThemeUtilities.getAppBarShadowColor(context);

    String detectedType = 'TEXT';
    String fileName = 'Document';

    final String typeLower = messageType.toLowerCase().trim();
    final bool isExplicitText = typeLower == 'text' || typeLower == 'string';

    final String? mediaPath = (filePath != null && filePath!.trim().isNotEmpty)
        ? filePath!.trim()
        : null;
    final String lowerPath = mediaPath?.toLowerCase() ?? '';
    final String pathNoQuery = lowerPath.split('?').first;

    bool looksLikeImage() =>
        pathNoQuery.contains('.jpg') ||
        pathNoQuery.contains('.jpeg') ||
        pathNoQuery.contains('.png') ||
        pathNoQuery.contains('.webp') ||
        pathNoQuery.contains('.gif');

    bool looksLikeAudio() =>
        pathNoQuery.contains('.mp3') ||
        pathNoQuery.contains('.ogg') ||
        pathNoQuery.contains('.aac') ||
        pathNoQuery.contains('.m4a') ||
        pathNoQuery.contains('.wav') ||
        pathNoQuery.contains('audioclip');

    bool looksLikeVideo() =>
        pathNoQuery.contains('.mp4') ||
        pathNoQuery.contains('.3gp') ||
        pathNoQuery.contains('.3gpp') ||
        pathNoQuery.contains('.mov') ||
        pathNoQuery.contains('.mkv') ||
        pathNoQuery.contains('.webm') ||
        pathNoQuery.contains('vid_');

    if (isExplicitText) {
      detectedType = 'TEXT';
    } else if (typeLower == 'image' || looksLikeImage()) {
      detectedType = 'IMAGE';
      fileName = pathNoQuery.isNotEmpty ? pathNoQuery.split('/').last : 'Image';
    } else if (typeLower == 'video' || looksLikeVideo()) {
      detectedType = 'VIDEO';
      fileName = pathNoQuery.isNotEmpty ? pathNoQuery.split('/').last : 'Video';
    } else if (typeLower == 'audio' || looksLikeAudio()) {
      detectedType = 'AUDIO';
      fileName = pathNoQuery.isNotEmpty ? pathNoQuery.split('/').last : 'Audio';
    } else if (typeLower == 'media' || typeLower == 'document') {
      detectedType = 'DOCUMENT';
      fileName = pathNoQuery.isNotEmpty
          ? pathNoQuery.split('/').last
          : 'Document';
    } else if (mediaPath != null) {
      // Unknown type but a real file path exists → treat as document.
      detectedType = 'DOCUMENT';
      fileName = pathNoQuery.split('/').last;
    }

    if (fileName.length > 25 && !fileName.contains('.')) {
      fileName = "Document File";
    }

    return Container(
      margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
      padding: const EdgeInsets.only(left: 0, top: 10, right: 0, bottom: 0),

      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            _buildAvatar(context),
            // Container(width: 4),
            Container(
              margin: const EdgeInsets.only(
                left: 0,
                top: 0,
                right: 0,
                bottom: 0,
              ),
              padding: const EdgeInsets.only(
                left: 0,
                top: 0,
                right: 0,
                bottom: 0,
              ),
              width: 4,
              height: 0,
            ),
          ],

          Expanded(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    left: 0,
                    top: 0,
                    right: 4,
                    bottom: 4,
                  ),
                  child: Text(
                    isMe ? "You" : "",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: subTextColor,
                    ),
                  ),
                ),

                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: detectedType == 'IMAGE' || detectedType == 'VIDEO'
                      ? const EdgeInsets.all(4)
                      : detectedType == 'AUDIO'
                      ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
                      : const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),

                  decoration: BoxDecoration(
                    color: isMe
                        ? AppThemeUtilities.HexToColor("#2ead65")
                        : incomingBubbleColor,
                    border: isMe ? null : Border.all(color: borderColor),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isMe
                          ? const Radius.circular(20)
                          : const Radius.circular(0),
                      bottomRight: isMe
                          ? const Radius.circular(0)
                          : const Radius.circular(20),
                    ),
                  ),
                  child: _buildDynamicBody(
                    context,
                    detectedType,
                    fileName,
                    mainTextColor,
                    isDark,
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(
                    left: 4,
                    top: 4,
                    right: 4,
                    bottom: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        (time.isEmpty || time == "null")
                            ? DateFormat('hh:mm a').format(DateTime.now())
                            : time,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: subTextColor,
                        ),
                      ),

                      // if (isMe) ...[
                      //   Container(width: 4),
                      //   _buildTickIcon(isDark),
                      // ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (isMe) ...[
            Container(
              margin: const EdgeInsets.only(
                left: 0,
                top: 0,
                right: 0,
                bottom: 0,
              ),
              padding: const EdgeInsets.only(
                left: 0,
                top: 0,
                right: 0,
                bottom: 0,
              ),
              width: 4,
              height: 0,
            ),
            _buildAvatar(context),
          ],
        ],
      ),
    );
  }

  Widget _buildDynamicBody(
    BuildContext context,
    String type,
    String fileName,
    Color defaultTextColor,
    bool isDark,
  ) {
    final Color contentColor = isMe
        ? AppThemeUtilities.HexToColor("#ffffff")
        : defaultTextColor;

    // Resolve relative server paths (e.g. WhatsApp `assets/….ogg`).
    final String? filePath = MediaUrlResolver.resolve(this.filePath);

    final bool isNetwork = MediaUrlResolver.isNetworkUrl(filePath);
    final bool isLocalExisting =
        filePath != null &&
        filePath!.isNotEmpty &&
        !isNetwork &&
        File(filePath!).existsSync();
    // Uploading placeholder only when we have no network URL and no local file yet.
    final bool isUploading =
        filePath == null ||
        filePath!.isEmpty ||
        (!isNetwork && !isLocalExisting);

    switch (type) {
       case 'STICKER':
        final bool hasValidPath = filePath != null && filePath!.isNotEmpty;

        return Container(
          constraints: const BoxConstraints(minWidth: 120, minHeight: 100),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (hasValidPath && isNetwork)
                Image.network(
                  filePath!,
                  width: 130,
                  height: 130,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildWhatsAppLoader();
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      _buildStickerNotSupportedUI(contentColor),
                )
              else if (hasValidPath && isLocalExisting)
                Image.file(
                  File(filePath!),
                  width: 130,
                  height: 130,
                  fit: BoxFit.contain,
                )
              else
                // Jab path null ho
                _buildStickerNotSupportedUI(contentColor),

              if (isUploading) _buildWhatsAppLoader(),
            ],
          ),
        );


      case 'IMAGE':
        final bool hasValidPath = filePath != null && filePath!.isNotEmpty;
        final bool isNetworkUrl = hasValidPath && isNetwork;
        final bool hasLocalFile = isLocalExisting;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: (isUploading || !hasValidPath)
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              FullScreenImageViewer(imageUrl: filePath!),
                        ),
                      );
                    },
              child: AspectRatio(
                aspectRatio: 1.3,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white10
                        : Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (isNetworkUrl)
                        Image.network(
                          filePath!,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return _buildWhatsAppLoader();
                          },
                          frameBuilder:
                              (context, child, frame, wasSynchronouslyLoaded) {
                                if (wasSynchronouslyLoaded || frame != null) {
                                  return child;
                                }

                                return _buildWhatsAppLoader();
                              },
                          errorBuilder: (context, error, stackTrace) =>
                              _buildFallbackUI(
                                Icons.broken_image_rounded,
                                "Image not accessible",
                              ),
                        )
                      else if (hasLocalFile)
                        Image.file(
                          File(filePath!),
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                        )
                      else
                        _buildFallbackUI(Icons.image_outlined, "No Image Path"),

                      if (isUploading) _buildWhatsAppLoader(),
                    ],
                  ),
                ),
              ),
            ),
            if (message != null && message!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.only(
                  left: 6,
                  top: 8,
                  right: 6,
                  bottom: 2,
                ),
                child: Text(
                  message!,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: contentColor,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        );

      case 'VIDEO':
        final bool hasValidPath = filePath != null && filePath!.isNotEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: (isUploading || !hasValidPath)
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              FullScreenVideoViewer(videoUrl: filePath!),
                        ),
                      );
                    },
              child: hasValidPath
                  ? CachedVideoThumbnail(
                      videoPath: filePath!,
                      fallbackIconColor: contentColor,
                      isDark: isDark,
                      isUploading: isUploading,
                      uploadingOverlay: isUploading
                          ? _buildWhatsAppLoader()
                          : null,
                      fileName: fileName,
                    )
                  : AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white10
                              : Colors.black.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.videocam_rounded,
                            size: 48,
                            color: contentColor.withOpacity(0.85),
                          ),
                        ),
                      ),
                    ),
            ),
            if (message != null && message!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.only(
                  left: 6,
                  top: 8,
                  right: 6,
                  bottom: 2,
                ),
                child: Text(
                  message!,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: contentColor,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        );

      case 'DOCUMENT':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppThemeUtilities.HexToColor("#3Dffffff")
                        : AppThemeUtilities.HexToColor("#26757575"),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.insert_drive_file_rounded,
                    color: isMe
                        ? AppThemeUtilities.HexToColor("#ffffff")
                        : AppThemeUtilities.HexToColor("#ff5252"),
                    size: 24,
                  ),
                ),
                if (isUploading)
                  Container(
                    margin: const EdgeInsets.only(
                      left: 0,
                      top: 0,
                      right: 0,
                      bottom: 0,
                    ),
                    padding: const EdgeInsets.only(
                      left: 9,
                      top: 9,
                      right: 9,
                      bottom: 9,
                    ),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                    ),
                  ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(
                left: 10,
                top: 0,
                right: 0,
                bottom: 0,
              ),
              padding: const EdgeInsets.only(
                left: 0,
                top: 0,
                right: 0,
                bottom: 0,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isUploading ? "Uploading..." : fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: AppConstants.FontWeight_Medium,
                      color: contentColor,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 0,
                      top: 2,
                      right: 0,
                      bottom: 0,
                    ),
                    padding: const EdgeInsets.only(
                      left: 0,
                      top: 0,
                      right: 0,
                      bottom: 0,
                    ),
                  ),
                  Text(
                    isUploading ? "Please wait" : "Attachment Document",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isMe
                          ? AppThemeUtilities.HexToColor("#B3ffffff")
                          : AppThemeUtilities.getTextColor(
                              context,
                            ).withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                left: 6,
                top: 0,
                right: 0,
                bottom: 0,
              ),
              padding: const EdgeInsets.only(
                left: 0,
                top: 0,
                right: 0,
                bottom: 0,
              ),
            ),
            if (!isUploading)
              IconButton(
                icon: Icon(
                  Icons.download_for_offline_rounded,
                  color: isMe
                      ? AppThemeUtilities.HexToColor("#CCffffff")
                      : AppThemeUtilities.getTextColor(
                          context,
                        ).withOpacity(0.8),
                  size: 22,
                ),
                onPressed: () {
                  if (filePath != null && filePath!.isNotEmpty) {
                    context.read<TeamChatBloc>().add(
                      DownloadDocumentEvent(
                        filePath: filePath!,
                        fileName: fileName,
                        context: context,
                      ),
                    );
                  } else {
                    AppUtilities.showErrorSnackBar(
                      navigatorKey.currentContext!,
                      title: "Error",
                      message: "File URL not found",
                    );
                  }
                },
              )
            else
              Container(
                margin: const EdgeInsets.only(
                  left: 12,
                  top: 12,
                  right: 12,
                  bottom: 12,
                ),
                padding: const EdgeInsets.only(
                  left: 8,
                  top: 8,
                  right: 8,
                  bottom: 8,
                ),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
          ],
        );
      case 'AUDIO':
        final String playbackKey = '${currentMessageIndex}::${filePath ?? ''}';

        return BlocBuilder<TeamChatBloc, TeamChatState>(
          builder: (context, state) {
            bool isAudioPlaying = false;
            if (state is TeamChatDataLoadedState) {
              isAudioPlaying = state.playingAudios[playbackKey] ?? false;
            }

            return AudioBubbleContent(
              filePath: filePath ?? '',
              isMe: isMe,
              contentColor: contentColor,
              currentMessageIndex: currentMessageIndex,
              allMessagesList: allMessagesList,
              isPlaying: isAudioPlaying,
              onTogglePlayback: () {
                context.read<TeamChatBloc>().add(
                  ToggleAudioPlaybackEvent(playbackKey),
                );
              },
              onPlaybackCompleted: () {
                context.read<TeamChatBloc>().add(
                  AudioPlaybackCompletedEvent(playbackKey),
                );
              },
              onRequestNextAudio: (nextIndex, nextPath) {
                context.read<TeamChatBloc>().add(
                  ToggleAudioPlaybackEvent('$nextIndex::$nextPath'),
                );
              },
              onSeekRequested: (playbackKey, targetDuration) {
                context.read<TeamChatBloc>().add(
                  UpdateAudioPositionEvent(playbackKey, targetDuration),
                );
              },
            );
          },
        );

      case 'TEXT':
      default:
        return Text(
          message ?? "",
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: contentColor,
            height: 1.4,
          ),
        );
    }
  }

  Widget _buildWhatsAppLoader() {
    return Container(
      color: Colors.black38,
      child: Center(
        child: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  left: 0,
                  top: 0,
                  right: 0,
                  bottom: 0,
                ),
                padding: const EdgeInsets.only(
                  left: 16,
                  top: 16,
                  right: 16,
                  bottom: 16,
                ),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Icon(Icons.close, color: Colors.white.withOpacity(0.9), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackUI(IconData iconData, String text) {
    return Container(
      margin: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
      padding: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
      height: 150,
      width: 240,
      color: AppThemeUtilities.HexToColor("#1F000000"),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            size: 34,
            color: AppThemeUtilities.HexToColor("#9E9E9E"),
          ),

          Container(
            margin: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
            padding: const EdgeInsets.only(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
            ),
            height: 6,
            width: 0,
          ),

          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppThemeUtilities.HexToColor("#9E9E9E"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color avatarBgColor = AppThemeUtilities.getAvatarBgColor(context);

    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(left: 0, top: 22, right: 5, bottom: 0),
      padding: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
      decoration: BoxDecoration(color: avatarBgColor, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: AppConstants.FontWeight_Semibold,
          color: isDark
              ? AppThemeUtilities.HexToColor("#00B074")
              : AppThemeUtilities.HexToColor("#16A249"),
        ),
      ),
    );
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageViewer({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          clipBehavior: Clip.none,
          maxScale: 5.0,
          minScale: 1.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }
}

class FullScreenVideoViewer extends StatefulWidget {
  final String videoUrl;

  const FullScreenVideoViewer({super.key, required this.videoUrl});

  @override
  State<FullScreenVideoViewer> createState() => _FullScreenVideoViewerState();
}

class _FullScreenVideoViewerState extends State<FullScreenVideoViewer> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final url = widget.videoUrl.trim();
    try {
      final controller = url.startsWith('http://') || url.startsWith('https://')
          ? VideoPlayerController.networkUrl(Uri.parse(url))
          : VideoPlayerController.file(File(url));
      _controller = controller;
      await controller.initialize();
      await controller.play();
      if (!mounted) return;
      setState(() => _initialized = true);
      controller.addListener(() {
        if (mounted) setState(() {});
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final controller = _controller;
    if (!_initialized || controller == null) return;
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: _hasError
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to play video${_errorMessage != null ? '\n$_errorMessage' : ''}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
              )
            : !_initialized || controller == null
            ? const CircularProgressIndicator(color: Colors.white)
            : GestureDetector(
                onTap: _togglePlay,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: controller.value.aspectRatio == 0
                          ? 16 / 9
                          : controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                    if (!controller.value.isPlaying)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: VideoProgressIndicator(
                        controller,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: Color(0xFF2ead65),
                          bufferedColor: Colors.white24,
                          backgroundColor: Colors.white12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

Widget _buildStickerNotSupportedUI(Color textColor) {
  return Container(
    width: 130,
    height: 110,
    margin: const EdgeInsets.only(
      top: 0,
      bottom: 0,
      left: 0,
      right: 0,
    ),
    padding: const EdgeInsets.only(
      top: 12,
      bottom: 12,
      left: 8,
      right: 8,
    ),
    alignment: Alignment.center,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.sticky_note_2_outlined,
          size: 32,
          color: textColor.withOpacity(0.8),
        ),
        Container(
          margin: const EdgeInsets.only(
            top: 6,
            bottom: 0,
            left: 0,
            right: 0,
          ),
          padding: const EdgeInsets.only(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
          ),
          child: Text(
            "Sticker Not Supported",
            textAlign: TextAlign.center,
            maxLines: 2,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ],
    ),
  );
}