import 'dart:io';

import 'package:berrytalks/Widgets_Component/Utils/AppConstants.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppUitilities.dart';
import 'package:berrytalks/Widgets_Component/Utils/MediaUrlResolver.dart';
import 'package:berrytalks/main.dart';
import 'package:berrytalks/network/ApiService.dart';
import 'package:berrytalks/screens/Chat_screen/bloc/chat_screen_bloc.dart';
import 'package:berrytalks/screens/Chat_screen/widget/chat_bubble/audio_bubble.dart';
import 'package:berrytalks/screens/Chat_screen/widget/chat_bubble/cached_video_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:video_player/video_player.dart';

class ChatBubble extends StatefulWidget {
  final String? message;
  final String time;
  final bool isMe;
  final String initials;
  final String isSent;
  final String messageStatus;
  final String messageType;
  final String? filePath;
  final int currentMessageIndex;
  final List<dynamic> allMessagesList;
  final VoidCallback? onRightSwipe;
  final bool enableSwipeToReply;
  final InboxMessage? inboxMessage;
  final InboxMessage? replyToMessage; 

  const ChatBubble({
    super.key,
    this.message,
    required this.time,
    required this.isMe,
    required this.initials,
    required this.isSent,
    required this.messageStatus,
    required this.messageType,
    this.filePath,
    required this.currentMessageIndex,
    required this.allMessagesList,
    this.onRightSwipe,
    this.inboxMessage,
    this.replyToMessage,
    this.enableSwipeToReply = true,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {


  
  @override
  Widget build(BuildContext context) {


  void showReactionPicker() {
  final String msgId =
      widget.inboxMessage?.publicId ??
      widget.inboxMessage?.messageId ?? '';
  final List<String> emojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];
  final bool isDark = Theme.of(context).brightness == Brightness.dark;

  final RenderBox renderBox = context.findRenderObject() as RenderBox;
  final Offset position = renderBox.localToGlobal(Offset.zero);
  final Size size = renderBox.size;
  final double screenWidth = MediaQuery.of(context).size.width;
  final double screenHeight = MediaQuery.of(context).size.height;

  final OverlayState overlay = Overlay.of(context);
  late OverlayEntry entry;

  // Animation controller ke liye ValueNotifier
  final ValueNotifier<bool> visible = ValueNotifier(false);

  entry = OverlayEntry(
    builder: (ctx) => GestureDetector(
      onTap: () async {
        visible.value = false;
        await Future.delayed(const Duration(milliseconds: 250));
        entry.remove();
      },
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          // Background overlay — fade in
          ValueListenableBuilder<bool>(
            valueListenable: visible,
            builder: (_, show, __) => AnimatedOpacity(
              opacity: show ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(color: Colors.black.withOpacity(0.35)),
            ),
          ),

          // Emoji bar — neche se upar slide + fade
          Positioned(
            left: widget.isMe
                ? null
                : position.dx.clamp(8.0, screenWidth - 220),
            right: widget.isMe
                ? (screenWidth - position.dx - size.width).clamp(8.0, screenWidth - 220)
                : null,
            top: (position.dy - 50).clamp(8.0, screenHeight - 100),
            child: ValueListenableBuilder<bool>(
              valueListenable: visible,
              builder: (_, show, __) => AnimatedOpacity(
                opacity: show ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                child: AnimatedSlide(
                  offset: show ? Offset.zero : const Offset(0, 0.3),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2A2A2A)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: emojis.asMap().entries.map((entry_) {
                          final int i = entry_.key;
                          final String emoji = entry_.value;

                          return ValueListenableBuilder<bool>(
                            valueListenable: visible,
                            builder: (_, show, __) => AnimatedOpacity(
                              opacity: show ? 1.0 : 0.0,
                              // Har emoji thodi delay se aaye — waterfall effect
                              duration: Duration(
                                  milliseconds: 200 + (i * 40)),
                              curve: Curves.easeOut,
                              child: AnimatedSlide(
                                offset: show
                                    ? Offset.zero
                                    : const Offset(0, 0.5),
                                duration: Duration(
                                    milliseconds: 250 + (i * 40)),
                                curve: Curves.easeOutBack,
                                child: GestureDetector(
                                  onTap: () async {
                                    visible.value = false;
                                    await Future.delayed(
                                        const Duration(milliseconds: 200));
                                    entry.remove();
                                    HapticFeedback.lightImpact();
                                    context.read<ChatBloc>().add(
                                      ReactToMessageEvent(
                                        messagePublicId: msgId,
                                        reaction: emoji,
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: Text(
                                      emoji,
                                      style:
                                          const TextStyle(fontSize: 28),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  overlay.insert(entry);

  // Next frame mein animate karo — pehle insert, phir visible true
  WidgetsBinding.instance.addPostFrameCallback((_) {
    visible.value = true;
  });
}

// Widget _buildQuotedBubble() {
//   final bool isDark = Theme.of(context).brightness == Brightness.dark;
//   final InboxMessage? original = widget.replyToMessage;

//   if (original == null) return const SizedBox.shrink();

//   final String preview =
//       (original.messageType ?? '').toLowerCase() == 'media'
//           ? '📎 Media'
//           : (original.body ?? 'Original message');

//   final String senderName = original.isSent == 'true'
//       ? 'You'
//       : (original.contactName ?? 'Customer');

//   return Container(
//     margin: const EdgeInsets.only(bottom: 6),
//     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//     decoration: BoxDecoration(
//       color: widget.isMe
//           ? Colors.white.withOpacity(0.15)
//           : isDark
//               ? Colors.white.withOpacity(0.08)
//               : Colors.black.withOpacity(0.06),
//       borderRadius: BorderRadius.circular(8),
//       border: Border(
//         left: BorderSide(
//           color: widget.isMe
//               ? Colors.white.withOpacity(0.6)
//               : AppThemeUtilities.HexToColor("#2EAD65"),
//           width: 3,
//         ),
//       ),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           senderName,
//           style: GoogleFonts.poppins(
//             fontSize: 11,
//             fontWeight: FontWeight.w600,
//             color: widget.isMe
//                 ? Colors.white
//                 : AppThemeUtilities.HexToColor("#2EAD65"),
//           ),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           preview,
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           style: GoogleFonts.poppins(
//             fontSize: 11,
//             color: widget.isMe
//                 ? Colors.white.withOpacity(0.8)
//                 : isDark
//                     ? Colors.grey.shade400
//                     : Colors.grey.shade600,
//           ),
//         ),
//       ],
//     ),
//   );
// }

Widget _buildQuotedBubble() {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;
  final InboxMessage? original = widget.replyToMessage;

  if (original == null) return const SizedBox.shrink();

  final bool originalIsMe = original.isSent == 'true';
  final String senderName = originalIsMe ? 'You' : (original.contactName ?? 'Customer');
  
  final String preview = (original.messageType ?? '').toLowerCase() == 'media'
      ? original.filePath?.toLowerCase().contains('.m4a') == true ||
        original.filePath?.toLowerCase().contains('.mp3') == true ||
        original.filePath?.toLowerCase().contains('.ogg') == true
          ? '🎵 Voice message'
          : original.filePath?.toLowerCase().contains('.jpg') == true ||
            original.filePath?.toLowerCase().contains('.png') == true ||
            original.filePath?.toLowerCase().contains('.jpeg') == true
              ? '📷 Photo'
              : '📎 Document'
      : (original.body ?? 'Original message');

  // Bubble ke andar ka background — slightly different shade
  final Color quotedBg = widget.isMe
      ? Colors.white.withOpacity(0.18)
      : isDark
          ? Colors.white.withOpacity(0.07)
          : Colors.black.withOpacity(0.05);

  final Color accentColor = widget.isMe
      ? Colors.white
      : AppThemeUtilities.HexToColor("#2EAD65");

  final Color nameColor = widget.isMe
      ? Colors.white
      : AppThemeUtilities.HexToColor("#2EAD65");

  final Color previewColor = widget.isMe
      ? Colors.white.withOpacity(0.75)
      : isDark
          ? Colors.grey.shade400
          : Colors.grey.shade600;

  return Container(
    margin: const EdgeInsets.only(bottom: 6),
    decoration: BoxDecoration(
      color: quotedBg,
      borderRadius: BorderRadius.circular(8),
      border: Border(
        left: BorderSide(color: accentColor, width: 3),
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left colored bar already done by border
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  senderName,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: nameColor,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  preview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: previewColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Agar media hai to thumbnail dikhao
        if ((original.messageType ?? '').toLowerCase() == 'media' &&
            original.filePath != null &&
            (original.filePath!.toLowerCase().contains('.jpg') ||
             original.filePath!.toLowerCase().contains('.jpeg') ||
             original.filePath!.toLowerCase().contains('.png')))
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            child: Image.network(
              original.filePath!,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
      ],
    ),
  );
}

    final String? filePath = MediaUrlResolver.resolve(this.widget.filePath);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color mainTextColor = AppThemeUtilities.getTextColor(context);
    final Color subTextColor = AppThemeUtilities.getTimeColor(context);
    final Color incomingBubbleColor = AppThemeUtilities.getCardColor(context);
    final Color borderColor = AppThemeUtilities.getAppBarShadowColor(context);

    String detectedType = 'TEXT';
    String fileName = 'Document';

    final String typeLower = widget.messageType.toLowerCase().trim();
    final bool isExplicitText = typeLower == 'text' || typeLower == 'string';

    // Only real file URLs/paths drive media detection — never the text body.
    // (Previously message body was used as pathToAnalyze, so any text became
    // DOCUMENT → "Uploading..." bubble.)
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

    //   return SwipeTo(
    //    offsetDx: 0.25,
    //     animationDuration: const Duration(milliseconds: 150),
    //     onRightSwipe: (details) {
    //       if (onRightSwipe != null) {
    //         onRightSwipe!();
    //       }
    //     },
    //     iconOnRightSwipe: Icons.reply_rounded,
    //     iconColor: AppThemeUtilities.HexToColor("#2ead65"),
    //     child: Container(
    //       // margin: EdgeInsets.zero,
    //       // padding: const EdgeInsets.only(left: 0, top: 10, right: 0, bottom: 0),
    //       color: Colors.transparent,
    //       width: double.infinity,
    //       padding: const EdgeInsets.only(top: 8, bottom: 2, left: 8, right: 8),
    //       child: Row(
    //         mainAxisAlignment: isMe
    //             ? MainAxisAlignment.end
    //             : MainAxisAlignment.start,
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           if (!isMe) ...[
    //             _buildAvatar(context),
    //             // Container(width: 4),
    //             // Container(
    //             //   margin: const EdgeInsets.only(
    //             //     left: 0,
    //             //     top: 0,
    //             //     right: 0,
    //             //     bottom: 0,
    //             //   ),
    //             //   padding: const EdgeInsets.only(
    //             //     left: 0,
    //             //     top: 0,
    //             //     right: 0,
    //             //     bottom: 0,
    //             //   ),
    //             //   width: 4,
    //             //   height: 0,
    //             // ),
    //           ],

    //           Expanded(
    //             child: Column(
    //               crossAxisAlignment: isMe
    //                   ? CrossAxisAlignment.end
    //                   : CrossAxisAlignment.start,
    //               children: [
    //                 Container(
    //                   margin: const EdgeInsets.only(
    //                     left: 0,
    //                     top: 0,
    //                     right: 4,
    //                     bottom: 4,
    //                   ),
    //                   child: Text(
    //                     isMe ? "You" : "",
    //                     style: GoogleFonts.poppins(
    //                       fontSize: 12,
    //                       color: subTextColor,
    //                     ),
    //                   ),
    //                 ),

    //                 Container(
    //                   constraints: BoxConstraints(
    //                     maxWidth: MediaQuery.of(context).size.width * 0.75,
    //                   ),
    //                   padding: detectedType == 'IMAGE' || detectedType == 'VIDEO'
    //                       ? const EdgeInsets.all(4)
    //                       : detectedType == 'AUDIO'
    //                       ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
    //                       : const EdgeInsets.symmetric(
    //                           horizontal: 14,
    //                           vertical: 12,
    //                         ),

    //                   decoration: BoxDecoration(
    //                     color: isMe
    //                         ? AppThemeUtilities.HexToColor("#2ead65")
    //                         : incomingBubbleColor,
    //                     border: isMe ? null : Border.all(color: borderColor),
    //                     borderRadius: BorderRadius.only(
    //                       topLeft: const Radius.circular(20),
    //                       topRight: const Radius.circular(20),
    //                       bottomLeft: isMe
    //                           ? const Radius.circular(20)
    //                           : const Radius.circular(0),
    //                       bottomRight: isMe
    //                           ? const Radius.circular(0)
    //                           : const Radius.circular(20),
    //                     ),
    //                   ),
    //                   child: _buildDynamicBody(
    //                     context,
    //                     detectedType,
    //                     fileName,
    //                     mainTextColor,
    //                     isDark,
    //                   ),
    //                 ),

    //                 Container(
    //                   margin: const EdgeInsets.only(
    //                     left: 4,
    //                     top: 4,
    //                     right: 4,
    //                     bottom: 0,
    //                   ),
    //                   child: Row(
    //                     mainAxisSize: MainAxisSize.min,
    //                     children: [
    //                       Text(
    //                         time,
    //                         style: GoogleFonts.poppins(
    //                           fontSize: 11,
    //                           color: subTextColor,
    //                         ),
    //                       ),

    //                       if (isMe) ...[
    //                         Container(width: 4),
    //                         _buildTickIcon(isDark),
    //                       ],
    //                     ],
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),

    //           if (isMe) ...[
    //             Container(
    //               margin: const EdgeInsets.only(
    //                 left: 0,
    //                 top: 0,
    //                 right: 0,
    //                 bottom: 0,
    //               ),
    //               padding: const EdgeInsets.only(
    //                 left: 0,
    //                 top: 0,
    //                 right: 0,
    //                 bottom: 0,
    //               ),
    //               width: 4,
    //               height: 0,
    //             ),
    //             _buildAvatar(context),
    //           ],
    //         ],
    //       ),
    //     ),
    //   );
    // }

    final Widget bubbleContent = Container(
      color: Colors.transparent,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8, bottom: 2, left: 8, right: 8),
      child: Row(
        mainAxisAlignment: widget.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isMe) ...[_buildAvatar(context)],
          Expanded(
            child: Column(
              crossAxisAlignment: widget.isMe
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
                    widget.isMe ? "You" : "",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: subTextColor,
                    ),
                  ),
                ),
                 BlocBuilder<ChatBloc, ChatState>(
      builder: (context, chatState) {
         final String? reaction = chatState is ChatDataLoadedState
          ? chatState.messageReactions[
              widget.inboxMessage?.publicId ??
              widget.inboxMessage?.messageId ??
              '']
          : null;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: detectedType == 'IMAGE' || detectedType == 'VIDEO'
                  ? const EdgeInsets.all(4)
                  : detectedType == 'AUDIO'
                      ? const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8)
                      : const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: widget.isMe
                    ? AppThemeUtilities.HexToColor("#2ead65")
                    : incomingBubbleColor,
                border: widget.isMe ? null : Border.all(color: borderColor),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: widget.isMe
                      ? const Radius.circular(20)
                      : const Radius.circular(0),
                  bottomRight: widget.isMe
                      ? const Radius.circular(0)
                      : const Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.replyToMessage != null)
        _buildQuotedBubble(),
                  // Quoted bubble — agar retryMessage hai
                  // TODO: jab InboxMessage ChatBubble mein pass ho
                  // tab yahan buildQuotedBubble(messageData) call karo

                  _buildDynamicBody(
                    context,
                    detectedType,
                    fileName,
                    mainTextColor,
                    isDark,
                  ),
                ],
              ),
            ),

            // Reaction badge
            if (reaction != null)
              Positioned(
                bottom: -10,
                right: widget.isMe ? 8 : null,
                left: widget.isMe ? null : 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF3A3A3A)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    reaction,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        );
      },
    ),

                // BlocBuilder<ChatBloc, ChatState>(
                //   builder: (context, chatState) {
                //     final String? reaction = chatState is ChatDataLoadedState
                //         ? chatState.messageReactions[messageData.publicId ?? '']
                //         : null;
                //     // TODO: implement listener
                //   },
                //   child: Center(
                //     child: Container(
                //       constraints: BoxConstraints(
                //         maxWidth: MediaQuery.of(context).size.width * 0.75,
                //       ),
                //       padding:
                //           detectedType == 'IMAGE' || detectedType == 'VIDEO'
                //           ? const EdgeInsets.all(4)
                //           : detectedType == 'AUDIO'
                //           ? const EdgeInsets.symmetric(
                //               horizontal: 10,
                //               vertical: 8,
                //             )
                //           : const EdgeInsets.symmetric(
                //               horizontal: 14,
                //               vertical: 12,
                //             ),
                //       decoration: BoxDecoration(
                //         color: isMe
                //             ? AppThemeUtilities.HexToColor("#2ead65")
                //             : incomingBubbleColor,
                //         border: isMe ? null : Border.all(color: borderColor),
                //         borderRadius: BorderRadius.only(
                //           topLeft: const Radius.circular(20),
                //           topRight: const Radius.circular(20),
                //           bottomLeft: isMe
                //               ? const Radius.circular(20)
                //               : const Radius.circular(0),
                //           bottomRight: isMe
                //               ? const Radius.circular(0)
                //               : const Radius.circular(20),
                //         ),
                //       ),
                //       child: _buildDynamicBody(
                //         context,
                //         detectedType,
                //         fileName,
                //         mainTextColor,
                //         isDark,
                //       ),
                //     ),
                //   ),
                // ),
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
                        widget.time,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: subTextColor,
                        ),
                      ),
                      if (widget.isMe) ...[
                        Container(width: 4),
                        _buildTickIcon(isDark),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (widget.isMe) ...[Container(width: 4), _buildAvatar(context)],
        ],
      ),
    );

    // 2. Disable Swipe logic jab enableSwipeToReply false ho
      final Widget bubbleWithGesture = GestureDetector(
      // onLongPress: _showReactionPicker,
        onLongPress: () {
    HapticFeedback.mediumImpact();
    // Keyboard band karo pehle
    FocusScope.of(context).unfocus();
    // Thodi delay do keyboard animation ke liye
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) showReactionPicker();
    });
  },
      child: bubbleContent,
    );

    // Return
    if (!widget.enableSwipeToReply) {
      return bubbleWithGesture;
    }

    return SwipeTo(
      offsetDx: 0.18,
      animationDuration: const Duration(milliseconds: 100),
      onRightSwipe: (details) {
        if (widget.onRightSwipe != null) {
          widget.onRightSwipe!();
        }
      },
      iconOnRightSwipe: Icons.reply_rounded,
      iconColor: AppThemeUtilities.HexToColor("#2ead65"),
      child: bubbleWithGesture,
    );
  }


  //   if (!enableSwipeToReply) {
  Widget _buildDynamicBody(
    BuildContext context,
    String type,
    String fileName,
    Color defaultTextColor,
    bool isDark,
  ) {
    final Color contentColor = widget.isMe
        ? AppThemeUtilities.HexToColor("#ffffff")
        : defaultTextColor;

    // Resolve relative server paths (e.g. WhatsApp `assets/….ogg`).
    final String? filePath = MediaUrlResolver.resolve(this.widget.filePath);

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
            if (widget.message != null && widget.message!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.only(
                  left: 6,
                  top: 8,
                  right: 6,
                  bottom: 2,
                ),
                child: Text(
                  widget.message!,
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
            if (widget.message != null && widget.message!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.only(
                  left: 6,
                  top: 8,
                  right: 6,
                  bottom: 2,
                ),
                child: Text(
                  widget.message!,
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
                    color: widget.isMe
                        ? AppThemeUtilities.HexToColor("#3Dffffff")
                        : AppThemeUtilities.HexToColor("#26757575"),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.insert_drive_file_rounded,
                    color: widget.isMe
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
                      color: widget.isMe
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
                  color: widget.isMe
                      ? AppThemeUtilities.HexToColor("#CCffffff")
                      : AppThemeUtilities.getTextColor(
                          context,
                        ).withOpacity(0.8),
                  size: 22,
                ),
                onPressed: () {
                  if (filePath != null && filePath!.isNotEmpty) {
                    context.read<ChatBloc>().add(
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
        final String playbackKey = '${widget.currentMessageIndex}::${filePath ?? ''}';

        return BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            bool isAudioPlaying = false;
            if (state is ChatDataLoadedState) {
              isAudioPlaying = state.playingAudios[playbackKey] ?? false;
            }

            return AudioBubbleContent(
              filePath: filePath ?? '',
              isMe: widget.isMe,
              contentColor: contentColor,
              currentMessageIndex: widget.currentMessageIndex,
              allMessagesList: widget.allMessagesList,
              isPlaying: isAudioPlaying,
              onTogglePlayback: () {
                context.read<ChatBloc>().add(
                  ToggleAudioPlaybackEvent(playbackKey),
                );
              },
              onPlaybackCompleted: () {
                context.read<ChatBloc>().add(
                  AudioPlaybackCompletedEvent(playbackKey),
                );
              },
              onRequestNextAudio: (nextIndex, nextPath) {
                context.read<ChatBloc>().add(
                  ToggleAudioPlaybackEvent('$nextIndex::$nextPath'),
                );
              },
              onSeekRequested: (playbackKey, targetDuration) {
                context.read<ChatBloc>().add(
                  UpdateAudioPositionEvent(playbackKey, targetDuration),
                );
              },
            );
          },
        );

      case 'text':
      default:
        final bool isUnsupported = widget.message == null || widget.message!.isEmpty;
        final String textToShow = isUnsupported
            ? "Unsupported message format"
            : widget.message!;

        return Text(
          textToShow,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: isUnsupported
                ? contentColor.withOpacity(0.75)
                : contentColor,
            fontStyle: isUnsupported ? FontStyle.italic : FontStyle.normal,
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

  Widget _buildTickIcon(bool isDark) {
    final String statusLower = widget.messageStatus.toLowerCase().trim();

    // 1. Pending / Queue State -> Clock Icon (Accessing clock icon)
    if (statusLower == "sending" || statusLower == "pending") {
      return Icon(
        Icons.access_time_rounded,
        size: 14,
        color: isDark
            ? AppThemeUtilities.HexToColor("#bdbdbd")
            : AppThemeUtilities.HexToColor("#757575"),
      );
    }

    // 2. Read State -> Blue Double Ticks
    if (widget.isSent == "true" && statusLower == "read") {
      return Icon(
        Icons.done_all_rounded,
        size: 16,
        color: isDark
            ? AppThemeUtilities.HexToColor("#64d2ff")
            : AppThemeUtilities.HexToColor("#5ebe88"),
      );
    }

    // 3. Delivered State -> Grey Double Ticks
    if (widget.isSent == "true" &&
        (statusLower == "sent" || statusLower == "delivered")) {
      return Icon(
        Icons.done_all_rounded,
        size: 16,
        color: isDark
            ? AppThemeUtilities.HexToColor("#bdbdbd")
            : AppThemeUtilities.HexToColor("#757575"),
      );
    }

    // 4. Sent from local but not delivered yet -> Single Tick
    if (widget.isSent == "true" &&
        (statusLower == "sent" || statusLower == "delivered")) {
      return Icon(
        Icons.done_all_rounded,
        size: 16,
        color: isDark
            ? AppThemeUtilities.HexToColor("#bdbdbd")
            : AppThemeUtilities.HexToColor("#757575"),
      );
    }

    if (widget.isSent == "false" && statusLower == "sent") {
      return Icon(
        Icons.done_rounded,
        size: 16,
        color: isDark
            ? AppThemeUtilities.HexToColor("#bdbdbd")
            : AppThemeUtilities.HexToColor("#757575"),
      );
    }

    // Fallback: If status is unknown or pending default, show clock icon
    return Container(
      margin: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
      padding: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
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
        widget.initials,
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
    margin: const EdgeInsets.only(top: 0, bottom: 0, left: 0, right: 0),
    padding: const EdgeInsets.only(top: 12, bottom: 12, left: 8, right: 8),
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
          margin: const EdgeInsets.only(top: 6, bottom: 0, left: 0, right: 0),
          padding: const EdgeInsets.only(top: 0, bottom: 0, left: 0, right: 0),
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
