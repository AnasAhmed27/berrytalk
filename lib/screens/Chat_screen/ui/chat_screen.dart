import 'dart:async';
import 'dart:developer' as developer;

import 'package:berrytalks/Widgets_Component/Base_screen/Base_screen.dart';
import 'package:berrytalks/Widgets_Component/Enum/enum.dart';
import 'package:berrytalks/Widgets_Component/Enum/extensions.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppConstants.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppUitilities.dart';
import 'package:berrytalks/main.dart';
import 'package:berrytalks/network/ApiService.dart';
import 'package:berrytalks/network/socket_service/active_chat_tracker.dart';
import 'package:berrytalks/network/socket_service/message_sound_player.dart';
import 'package:berrytalks/network/socket_service/socket_message_types.dart';
import 'package:berrytalks/network/socket_service/socket_screen_listener.dart';
import 'package:berrytalks/network/socket_service/websocket_service.dart';
import 'package:berrytalks/screens/Chat_screen/bloc/chat_screen_bloc.dart';
import 'package:berrytalks/screens/Chat_screen/widget/chat_bubble/chat_bottom_bar.dart';
import 'package:berrytalks/screens/Chat_screen/widget/chat_bubble/chat_bubble_screen.dart';
import 'package:berrytalks/screens/Chat_screen/widget/chat_bubble/chat_window_timer_Bar.dart';
import 'package:berrytalks/screens/Chat_screen/widget/chat_bubble/typing_indicator.dart';
import 'package:berrytalks/screens/Chat_screen/widget/dropdown/chat_menu_actions.dart';
import 'package:berrytalks/services/storage/SharedPrefrences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../args/ChatScreenArgs.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  final SocialPlatform platform;
  final ChatScreenArgs chatScreenArgs;
  const ChatScreen({
    super.key,
    required this.name,
    required this.platform,
    required this.chatScreenArgs,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SocketScreenListener {
  final bool isScrollable = false;
  final isFullScreen = true;

  /// reverse:true list — offset ~0 means the user is on the latest messages.
  final ScrollController _messagesScrollController = ScrollController();

  /// True when the user has scrolled up to older messages.
  bool _isAwayFromLatest = false;

  /// WhatsApp-style: FAB only after a new message arrives while scrolled up.
  bool _showJumpToLatestFab = false;

  int _lastKnownMessageCount = 0;

  /// Cached so socket callbacks never call `context.read` after deactivate.
  ChatBloc? _chatBloc;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _wasOffline = false;
  late String _heldNumber;
  late String _heldCompanyPublicId;
  late String _heldChannelId;
  String? _heldAgentId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chatBloc = context.read<ChatBloc>();
  }

  @override
  void initState() {
    super.initState();
    developer.log("🔍 [LIFECYCLE] ChatScreen initState called");
    _heldNumber = widget.chatScreenArgs.contactItem.number ?? '';
    _heldCompanyPublicId =
        widget.chatScreenArgs.contactItem.companyPublicId ?? 'null';
    _heldChannelId = widget.chatScreenArgs.contactItem.chanelId ?? 'WHATSAPP';

    _messagesScrollController.addListener(_onMessagesScroll);

    final bloc = context.read<ChatBloc>();
    _chatBloc = bloc;

    context.read<ChatBloc>().add(
      InitChatEvent(name: widget.name, platform: widget.platform),
    );

    final bool alreadyLoaded = bloc.state is ChatDataLoadedState;

    developer.log(
      "🔍 [LIFECYCLE] ChatScreen initState | alreadyLoaded: $alreadyLoaded",
    );

    _bootstrapChat(isSilent: alreadyLoaded);
    //_bootstrapChat();

    // Mark this chat as the one currently open so the notification router
    // suppresses push banners for THIS conversation (WhatsApp behaviour).
    ActiveChatTracker.instance.setActiveChat(
      number: widget.chatScreenArgs.contactItem.number,
    );

    _dismissDeviceNotificationsForThisChat();
    _sendChatOpenSocketMessages();
    _setupConnectivityListener();

    // Live messages for THIS chat: append to the list as they arrive.
    listenSocketType(SocketMessageType.sendMessageDataResponse, (json) {
      if (!mounted) return;

      developer.log("📩 [SOCKET] Message received");
      final data = json['data'];
      if (data is! Map) return;

      // Only handle messages that belong to the conversation on screen.
      final incoming = ActiveChatTracker.normalize(
        data['contactNumber']?.toString(),
      );
      // final mine = ActiveChatTracker.normalize(
      //   widget.chatScreenArgs.contactItem.number,
      // );
      final mine = ActiveChatTracker.normalize(_heldNumber);
      if (incoming == null || incoming != mine) return;

      // WhatsApp-style: play the tone for messages RECEIVED from the customer
      // (not the ones we send ourselves).
      final sentByMe =
          data['isSent'] == true ||
          data['isSent']?.toString().toLowerCase() == 'true';
      if (!sentByMe) {
        MessageSoundPlayer.instance.playNewMessageTone();
        _sendReadMessageSocket(
          conversationId: data['conversationId']?.toString(),
        );
      }

      final bloc = _chatBloc;
      if (!mounted || bloc == null) return;
      bloc.add(IncomingChatMessageEvent(data: Map<String, dynamic>.from(data)));
    });

    listenSocketType(SocketMessageType.typing, (json) {
  if (!mounted) return;
  final data = json['data'];
  final String? convId = data?['conversationId']?.toString();
  final String myConvId =
      widget.chatScreenArgs.contactItem.publicId ?? '';

  if (convId == null || convId == myConvId) {
    final bloc = _chatBloc;
    if (bloc != null && !bloc.isClosed) {
      bloc.add(TypingIndicatorEvent(isTyping: true));
    }
  }
});

    listenSocketType(SocketMessageType.stopTyping, (json) {
  if (!mounted) return;
  final bloc = _chatBloc;
  if (bloc != null && !bloc.isClosed) {
    bloc.add(TypingIndicatorEvent(isTyping: false));
  }
});
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final isOnline = results.any((r) => r != ConnectivityResult.none);

      if (!isOnline) {
        // Net off hua — flag save kar liya
        _wasOffline = true;
        developer.log("[ChatScreen] Connection Lost. Offline mode.");
      } else if (_wasOffline && isOnline) {
        // Net OFF se ON wapis aaya!
        _wasOffline = false;
        developer.log(
          "[ChatScreen] Internet restored! Re-fetching chats and reconnecting sockets...",
        );

        // 1. WebSocket reconnection attempt (agar disconnect ho gaya tha)
        WebSocketService().connect();

        // 2. Refresh Chat API Call
        _bootstrapChat();

        // 3. Re-subscribe chat channel & mark read
        _sendChatOpenSocketMessages();
      }
    });
  }

  Future<String> _resolveAgentId() async {
    if (_heldAgentId != null && _heldAgentId!.isNotEmpty) {
      return _heldAgentId!;
    }

    final fromContact = widget.chatScreenArgs.contactItem.agentPublicId;
    if (fromContact != null &&
        fromContact.isNotEmpty &&
        fromContact.toLowerCase() != 'null') {
      _heldAgentId = fromContact;
      return fromContact;
    }

    final saved = await SharedPrefData.getAgentPublicId();
    if (saved != null && saved.isNotEmpty) {
      _heldAgentId = saved;
      return saved;
    }

    _heldAgentId = 'null';
    return 'null';
  }

  Future<void> _bootstrapChat({bool isSilent = false}) async {
    final agentId = await _resolveAgentId();
    if (!mounted) return;
    final bloc = _chatBloc ?? context.read<ChatBloc>();
    _chatBloc = bloc;
    bloc.add(
      FetchChatDetailsEvent(
        number: _heldNumber,
        companyPublicId: _heldCompanyPublicId,
        agentId: agentId,
        channelId: _heldChannelId,
        page: 0,
        isSilent: isSilent,
      ),
    );

    // ADD: Bootstrap ke waqt bhi pending messages check karo
    //bloc.add(SyncPendingMessagesEvent());
  }

  void _loadMoreMessages() async {
    if (!mounted) return;
    final bloc = _chatBloc;
    if (bloc == null) return;
    final state = bloc.state;
    if (state is! ChatDataLoadedState) return;

    if (state.hasReachedMax || state.isLoadingMore) return;

    final nextPage = state.currentPage + 1;
    final agentId = await _resolveAgentId();

    developer.log("[ChatScreen] Loading more messages - page $nextPage");

    if (!mounted) return;
    bloc.add(
      FetchChatDetailsEvent(
        number: widget.chatScreenArgs.contactItem.number ?? '',
        companyPublicId:
            widget.chatScreenArgs.contactItem.companyPublicId ?? 'null',
        agentId: agentId,
        channelId: widget.chatScreenArgs.contactItem.chanelId ?? 'WHATSAPP',
        page: nextPage,
        isLoadMore: true,
        isSilent: true,
      ),
    );
  }

  /// Removes this chat's banners from the device notification shade (WhatsApp).
  void _dismissDeviceNotificationsForThisChat() {
    final number = widget.chatScreenArgs.contactItem.number;
    if (number == null || number.isEmpty) return;
    WebSocketService().notificationService.dismissNotificationsForCustomer(
      number,
    );
  }

  /// Sends `read-message` to mark the conversation as read on the server.
  void _sendReadMessageSocket({String? conversationId}) {
    final id =
        conversationId?.trim() ??
        widget.chatScreenArgs.contactItem.publicId?.trim();
    if (id == null || id.isEmpty) return;

    final ws = WebSocketService();
    if (!ws.isConnected) return;

    ws.send({
      'type': SocketMessageType.readMessage,
      'data': {'conversationId': id},
    });
  }

  /// On chat open: `subscribe-chat` + `read-message` if there were unreads.
  void _sendChatOpenSocketMessages() {
    final conversationId = widget.chatScreenArgs.contactItem.publicId?.trim();
    if (conversationId == null || conversationId.isEmpty) return;

    final ws = WebSocketService();
    if (!ws.isConnected) return;

    ws.send({
      'type': SocketMessageType.subscribeChat,
      'data': {'conversationId': conversationId},
    });

    if (widget.chatScreenArgs.contactItem.calculatedUnreadCount >= 1) {
      _sendReadMessageSocket(conversationId: conversationId);
    }
  }

  void _onMessagesScroll() {
    if (!_messagesScrollController.hasClients) return;
    // reverse:true — small pixels = at the latest (visual bottom).
    final away = _messagesScrollController.position.pixels > 80;
    if (away != _isAwayFromLatest) {
      setState(() {
        _isAwayFromLatest = away;
        if (!away) {
          _showJumpToLatestFab = false;
        }
      });
    }

    if (_messagesScrollController.position.pixels >=
        _messagesScrollController.position.maxScrollExtent - 200) {
      _loadMoreMessages();
    }
  }

  /// Called after the message list rebuilds. Shows the jump FAB only when a
  /// NEW message arrived while the user is reading older ones.
  void _syncJumpFabForMessageCount(int messageCount) {
    if (messageCount > _lastKnownMessageCount &&
        _lastKnownMessageCount > 0 &&
        _isAwayFromLatest) {
      if (!_showJumpToLatestFab) {
        setState(() => _showJumpToLatestFab = true);
      }
    }
    _lastKnownMessageCount = messageCount;

    if (!_isAwayFromLatest && _showJumpToLatestFab) {
      setState(() => _showJumpToLatestFab = false);
    }
  }

  void _jumpToLatestMessages() {
    if (!_messagesScrollController.hasClients) return;
    _messagesScrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
    setState(() {
      _showJumpToLatestFab = false;
      _isAwayFromLatest = false;
    });
  }

  @override
  void deactivate() {
    developer.log("🚨 [LIFECYCLE] ChatScreen DEACTIVATE called!");
    super.deactivate();
  }

  @override
  void dispose() {
    developer.log("🚨 [LIFECYCLE] ChatScreen DISPOSE called!");
    _connectivitySubscription?.cancel();
    _chatBloc = null;
    _messagesScrollController.removeListener(_onMessagesScroll);
    _messagesScrollController.dispose();
    ActiveChatTracker.instance.clear();
    super.dispose();
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return "??";
    List<String> nameParts = name.trim().split(RegExp(r'\s+'));
    if (nameParts.length > 1) {
      return (nameParts[0][0] + nameParts[1][0]).toUpperCase();
    }
    return nameParts[0].length > 1
        ? nameParts[0].substring(0, 2).toUpperCase()
        : nameParts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = AppThemeUtilities.getCardColor(context);
    final Color mainTextColor = AppThemeUtilities.getTextColor(context);
    final Color subTextColor = AppThemeUtilities.getTimeColor(context);

    return BlocConsumer<ChatBloc, ChatState>(
      listenWhen: (previous, current) => current is ChatActionState,
      // Only rebuild for states this builder can actually render. Anything else
      // (errors, send/status/team/action states) is handled in `listener` and
      // must NOT rebuild the tree — otherwise the switch hits `default` and
      // shows a blank screen.
      buildWhen: (previous, current) =>
          current is ChatInitialState ||
          current is ChatHistoryLoadingState ||
          current is LoadingState ||
          current is ChatDataLoadedState ||
          current is LoadingErrorState,
      listener: (context, state) async {
        developer.log(
          "⚙️ [BLOC_LISTENER] New State Received: ${state.runtimeType}",
        );
        if (state is LoadingState) {
          developer.log("⚙️ [BLOC_LISTENER] Showing Loading Dialog");
          AppUtilities.showLoadingDialog(context);
        } else if (state is LoadingSuccessState) {
          developer.log("⚙️ [BLOC_LISTENER] Dismissing Loading Dialog");
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        } else if (state is LoadingErrorState) {
          developer.log(
            "⚙️ [BLOC_LISTENER] LoadingErrorState hit: ${state.errorMsg}",
          );
          //         if (Navigator.of(context, rootNavigator: true).canPop()) {
          //   // Only pop if a loading dialog is active
          // }
          // Only surface the error — do NOT pop here. The chat screen isn't
          // shown via a dialog, so popping the root navigator would kick the
          // user back to Home.
          AppUtilities.showErrorSnackBar(
            navigatorKey.currentContext!,
            title: state.errorTitle,
            message: state.errorMsg,
          );
        } else if (state is BackPressActionState) {
          developer.log(
            "⚙️ [BLOC_LISTENER_DEBUG] BackPressActionState RECEIVED! StackTrace:",
            stackTrace: StackTrace.current,
          );
          if (GoRouter.of(context).canPop()) {
            context.pop();
          }
        } else if (state is OpenCustomerProfileActionState) {
          developer.log(
            "📌 [CHAT_SCREEN] Navigating to Customer Profile Screen...",
          );

          await context.push(
            CUST_PROFILE,
            extra: {
              'number': widget.chatScreenArgs.contactItem.number ?? '',
              'companyPublicId':
                  widget.chatScreenArgs.contactItem.companyPublicId ?? '',
              'agentId':
                  widget.chatScreenArgs.contactItem.agentPublicId ?? 'null',
              'channelId': widget.chatScreenArgs.contactItem.chanelId ?? '',
            },
          );

          developer.log("🔙 [CHAT_SCREEN] Returned from Profile");

          final bloc = _chatBloc ?? context.read<ChatBloc>();
          bloc.add(RestoreChatStateEvent());
        } else if (state is ChatTransferSuccessActionState) {
          AppUtilities.showSuccessSnackBar(
            navigatorKey.currentContext!,
            title: "Chat Transferred",
            message: state.message,
          );
          // if (GoRouter.of(context).canPop()) {
          //   context.pop();
          // }
        } else if (state is ChatTransferErrorActionState) {
          AppUtilities.showErrorSnackBar(
            navigatorKey.currentContext!,
            title: "Transfer Failed",
            message: state.error,
          );
        } else if (state is SendMessageErrorActionState) {
          AppUtilities.showErrorSnackBar(
            navigatorKey.currentContext!,
            title: "Attachment not sent",
            message: state.error,
          );
        } else if (state is UpdateChatStatusSuccessActionState) {
          AppUtilities.showSuccessSnackBar(
            navigatorKey.currentContext!,
            title: "Success",
            message: state.message,
          );
        } else if (state is UpdateChatStatusErrorActionState) {
          AppUtilities.showErrorSnackBar(
            navigatorKey.currentContext!,
            title: state.errorTitle,
            message: state.errorMsg,
          );
        } else if (state is ForceLogoutActionState) {
          developer.log(
            "⚙️ [BLOC_LISTENER] ForceLogoutActionState hit - Redirecting to Login!",
          );
          context.go(LOGIN_ROUTE);
        }
        
      },
      builder: (BuildContext context, ChatState state) {
        switch (state.runtimeType) {
          case ChatInitialState:
          case ChatHistoryLoadingState:
          case LoadingState:
            return BaseScreen(
              backgroundColor: backgroundColor,
              dismissKeyboardOnTap: false,

              onPanUpdate: () {
                BlocProvider.of<ChatBloc>(context).add(BackPressActionEvent());
              },
              onWillPop: () {
                BlocProvider.of<ChatBloc>(context).add(BackPressActionEvent());
              },
              isScrollable: isScrollable,
              isFullScreen: isFullScreen,
              routeName: CHAT_ROUTE,
              appBar: AppBar(
                toolbarHeight: 66,
                leadingWidth: 40,
                foregroundColor: mainTextColor,
                backgroundColor: backgroundColor,
                surfaceTintColor: Colors.transparent,
                bottomOpacity: 0.1,
                elevation: 1,
                shadowColor: AppThemeUtilities.getCardColor(context),
                leading: Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    top: 0,
                    right: 0,
                    bottom: 0,
                  ),
                  child: InkWell(
                    onTap: () {
                      BlocProvider.of<ChatBloc>(
                        context,
                      ).add(BackPressActionEvent());
                    },
                    child: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                title: InkWell(
                  onTap: () {
                    print("APP BAR CLICKED");
                    context.read<ChatBloc>().add(OpenCustomerProfileEvent());
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.name,
                              style: GoogleFonts.poppins(
                                fontWeight: AppConstants.FontWeight_Semibold,
                                fontSize: 16,
                                color: mainTextColor,
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
                              "via ${widget.platform.title}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ChatMenuActions(
                        contactItem: ConversationData(
                          number: widget.chatScreenArgs.contactItem.number,
                          companyPublicId:
                              widget.chatScreenArgs.contactItem.companyPublicId,
                          agentId:
                              widget.chatScreenArgs.contactItem.agentPublicId,
                          chanelId: widget.chatScreenArgs.contactItem.chanelId,
                        ),
                        platform: widget.platform,
                        conversationid: InboxMessage(),
                      ),
                    ],
                  ),
                ),
              ),
              screenIndex: 3,
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: AppThemeUtilities.appScreenBGColor,
                child: Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ChatWindowTimerBar(),
                      Expanded(
                        child: Container(
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
                          color: backgroundColor,

                          child: Skeletonizer(
                            enabled: true,

                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              itemCount: 5,
                              itemBuilder: (context, index) {
                                final bool isMeMock = index % 2 == 0;
                                return Align(
                                  alignment: isMeMock
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,

                                  child: ChatBubble(
                                    message: index % 2 == 0
                                        ? "This is a dummy loading message layout structure."
                                        : "Short dummy msg text.",
                                    time: "12:00 PM",
                                    isMe: isMeMock,
                                    initials: isMeMock ? "AG" : "CU",
                                    isSent: "",
                                    currentMessageIndex: index,
                                    allMessagesList: isMeMock
                                        ? [
                                            "This is a dummy loading message layout structure.",
                                          ]
                                        : ["Short dummy msg text."],

                                    messageType: '',
                                    messageStatus: 'read',
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
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
                        // child: const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          case ChatDataLoadedState:
            final loadedState = state as ChatDataLoadedState;

            return BaseScreen(
              backgroundColor: backgroundColor,
              dismissKeyboardOnTap: false,
              onPanUpdate: () {
                BlocProvider.of<ChatBloc>(context).add(BackPressActionEvent());
              },
              onWillPop: () {
                BlocProvider.of<ChatBloc>(context).add(BackPressActionEvent());
              },
              isScrollable: isScrollable,
              isFullScreen: isFullScreen,
              routeName: CHAT_ROUTE,
              appBar: AppBar(
                toolbarHeight: 66,
                leadingWidth: 40,
                foregroundColor: mainTextColor,
                backgroundColor: backgroundColor,
                surfaceTintColor: Colors.transparent,
                bottomOpacity: 0.1,
                elevation: 1,
                shadowColor: AppThemeUtilities.getCardColor(context),
                leading: Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    top: 0,
                    right: 0,
                    bottom: 0,
                  ),
                  child: InkWell(
                    onTap: () {
                      BlocProvider.of<ChatBloc>(
                        context,
                      ).add(BackPressActionEvent());
                    },
                    child: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                title: InkWell(
                  onTap: () {
                    print("APP BAR CLICKED");
                    context.read<ChatBloc>().add(OpenCustomerProfileEvent());
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              loadedState.name ?? widget.name,
                              style: GoogleFonts.poppins(
                                fontWeight: AppConstants.FontWeight_Semibold,
                                fontSize: 16,
                                color: mainTextColor,
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
                              "via ${(loadedState.platform ?? widget.platform).title}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ChatMenuActions(
                        contactItem:
                            loadedState.conversation ??
                            ConversationData(
                              number: widget.chatScreenArgs.contactItem.number,
                              companyPublicId: widget
                                  .chatScreenArgs
                                  .contactItem
                                  .companyPublicId,
                              agentId: widget
                                  .chatScreenArgs
                                  .contactItem
                                  .agentPublicId,
                              chanelId:
                                  widget.chatScreenArgs.contactItem.chanelId,
                            ),
                        platform: loadedState.platform ?? widget.platform,
                        conversationid: loadedState.messages.isNotEmpty
                            ? loadedState.messages.first
                            : InboxMessage(),
                      ),
                    ],
                  ),
                ),
              ),
              screenIndex: 3,
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: backgroundColor,
                child: Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ChatWindowTimerBar(),

                      Expanded(
                        child: loadedState.messages.isEmpty
                            ? Center(
                                child: Text(
                                  "No conversations yet",
                                  style: GoogleFonts.poppins(
                                    color: subTextColor,
                                  ),
                                ),
                              )
                            : Builder(
                                builder: (context) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (!mounted) return;
                                    _syncJumpFabForMessageCount(
                                      loadedState.messages.length,
                                    );
                                  });
                                  return Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      ListView.builder(
                                        controller: _messagesScrollController,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        reverse: true,
                                        itemCount:
                                            loadedState.messages.length + 1,
                                        itemBuilder: (context, index) {
                                          if (index ==
                                              loadedState.messages.length) {
                                            return _buildTopLoader(loadedState);
                                          }
                                          

                                          final reversedIndex =
                                              loadedState.messages.length -
                                              1 -
                                              index;
                                          final messageData = loadedState
                                              .messages[reversedIndex];

                                          final bool isMe =
                                              messageData.isSent
                                                  ?.toString()
                                                  .toLowerCase() ==
                                              'true';

                                          bool showDateChip = false;
                                          if (index ==
                                              loadedState.messages.length - 1) {
                                            showDateChip = true;
                                          } else {
                                            final nextOlderReversedIndex =
                                                loadedState.messages.length -
                                                1 -
                                                (index + 1);
                                            final prevMessageData = loadedState
                                                .messages[nextOlderReversedIndex];

                                            if (messageData.timestamp != null &&
                                                prevMessageData.timestamp !=
                                                    null) {
                                              try {
                                                final currentSec = int.parse(
                                                  messageData.timestamp!,
                                                );
                                                final prevSec = int.parse(
                                                  prevMessageData.timestamp!,
                                                );

                                                final currentDt =
                                                    DateTime.fromMillisecondsSinceEpoch(
                                                      currentSec * 1000,
                                                    ).toLocal();
                                                final prevDt =
                                                    DateTime.fromMillisecondsSinceEpoch(
                                                      prevSec * 1000,
                                                    ).toLocal();

                                                if (currentDt.year !=
                                                        prevDt.year ||
                                                    currentDt.month !=
                                                        prevDt.month ||
                                                    currentDt.day !=
                                                        prevDt.day) {
                                                  showDateChip = true;
                                                }
                                              } catch (e) {
                                                print(
                                                  "Error comparing timestamps: $e",
                                                );
                                              }
                                            }
                                          }

                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (showDateChip)
                                                _buildWhatsAppDateChip(
                                                  context,
                                                  messageData.timestamp,
                                                ),
                                              Align(
                                                alignment: isMe
                                                    ? Alignment.centerRight
                                                    : Alignment.centerLeft,
                                                child: ChatBubble(
                                                  currentMessageIndex: index,
                                                  allMessagesList:
                                                      loadedState.messages,
                                                  message:
                                                      messageData.body ?? "",
                                                  time: messageData
                                                      .formattedMessageTime,
                                                  isMe: isMe,
                                                  enableSwipeToReply: !loadedState.isWindowClosed,
                                                  initials: isMe
                                                      ? _getInitials(
                                                          loadedState
                                                                  .conversation
                                                                  ?.agentName ??
                                                              "Agent Name",
                                                        )
                                                      : _getInitials(
                                                          loadedState.name ??
                                                              "",
                                                        ),
                                                  isSent:
                                                      messageData.wasSentByMe
                                                      ? "true"
                                                      : "false",
                                                  messageStatus:
                                                      messageData
                                                          .messageStatus ??
                                                      "",
                                                  messageType:
                                                      messageData.messageType ??
                                                      "text",
                                                      inboxMessage: messageData,
                                                       replyToMessage: messageData.replyToMessage,
                                                  filePath:
                                                      messageData.filePath,
                                                      onRightSwipe: loadedState.isWindowClosed
      ? null
      : () {
          HapticFeedback.lightImpact();
          context.read<ChatBloc>().add(
            SetReplyMessageEvent(replyMessage: messageData),
          );
          // Keyboard focus karo — reply bar dikhe
          FocusScope.of(context).requestFocus(FocusNode());
        },
      //                                                  onRightSwipe: loadedState.isWindowClosed
      // ? null
      // : () {
      //     context.read<ChatBloc>().add(
      //       SetReplyMessageEvent(replyMessage: messageData),
      //     );
      //   },
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      
                                      if (_showJumpToLatestFab)
                                        Positioned(
                                          right: 16,
                                          bottom: 12,
                                          child: Material(
                                            elevation: 4,
                                            shape: const CircleBorder(),
                                            color:
                                                AppThemeUtilities.getButtonColor(
                                                  context,
                                                ),
                                            shadowColor:
                                                AppThemeUtilities.getAppBarShadowColor(
                                                  context,
                                                ),
                                            child: InkWell(
                                              customBorder:
                                                  const CircleBorder(),
                                              onTap: _jumpToLatestMessages,
                                              child: SizedBox(
                                                width: 44,
                                                height: 44,
                                                child: Icon(
                                                  Icons
                                                      .keyboard_arrow_down_rounded,
                                                  color: mainTextColor,
                                                  size: 28,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (_showJumpToLatestFab)
       if (_showJumpToLatestFab)
                            Positioned(
                              right: 16,
                              bottom: 12,
                              child: Material(
                                elevation: 3,
                                shape: const CircleBorder(),
                                color: AppThemeUtilities.getCardColor(context),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: _jumpToLatestMessages,
                                  child: SizedBox(
                                    width: 42,
                                    height: 42,
                                    child: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: mainTextColor,
                                      size: 26,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                                    ],
                                  );
                                },
                              ),
                      ),
                      
                      
                      // IconButton(
                      //   icon: const Icon(Icons.edit),
                      //   onPressed: () {
                      //     context.read<ChatBloc>().add(
                      //       TypingIndicatorEvent(isTyping: true),
                      //     );
                      //   },
                      // ),
                      if (loadedState.isOtherUserTyping)
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: TypingIndicator(),
                        ),
                      if (!loadedState.isWindowClosed)
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
                          child: ChatBottomBar(
                            companyNumber:
                                widget
                                    .chatScreenArgs
                                    .companyProfileData
                                    ?.whatsappNumber ??
                                '',
                            onMessageSent: () {
                              // Wait for the optimistic message to land in the
                              // list, then jump to latest (keyboard stays open).
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!mounted) return;
                                _jumpToLatestMessages();
                              });
                            },
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            );

          default:
            return Container();
        }
      },
    );
  }

  Widget _buildTopLoader(ChatDataLoadedState state) {
    if (state.hasReachedMax) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        child: Text(
          "No more messages",
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppThemeUtilities.getTimeColor(context),
          ),
        ),
      );
    }

    if (state.isLoadingMore) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppThemeUtilities.HexToColor("#2ead65"),
            ),
          ),
        ),
      );
    }

    return const SizedBox(height: 8);
  }
}

Widget _buildWhatsAppDateChip(BuildContext context, String? timestampStr) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;

  String label = "";

  if (timestampStr != null && timestampStr.isNotEmpty) {
    int ts = int.tryParse(timestampStr) ?? 0;

    if (ts == 0) {
      label = timestampStr;
    } else {
      if (timestampStr.length == 10) {
        ts = ts * 1000;
      }

      final messageDateTime = DateTime.fromMillisecondsSinceEpoch(ts);
      final now = DateTime.now();

      final today = DateTime(now.year, now.month, now.day);
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final messageDate = DateTime(
        messageDateTime.year,
        messageDateTime.month,
        messageDateTime.day,
      );

      if (messageDate == today) {
        label = "Today";
      } else if (messageDate == yesterday) {
        label = "Yesterday";
      } else {
        final day = messageDateTime.day.toString().padLeft(2, '0');
        final month = messageDateTime.month.toString().padLeft(2, '0');
        final year = messageDateTime.year.toString();
        label = "$day/$month/$year";
      }
    }
  }

  if (label.isEmpty) return const SizedBox.shrink();

  return Center(
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AppThemeUtilities.HexToColor("#1Fffffff")
            : AppThemeUtilities.HexToColor("#F2F5F7"),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isDark
              ? AppThemeUtilities.HexToColor("#B3ffffff")
              : AppThemeUtilities.HexToColor("#54656F"),
        ),
      ),
    ),
  );
}
