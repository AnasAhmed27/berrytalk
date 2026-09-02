import 'dart:async';
import 'dart:developer' as developer;

import 'package:berrytalks/Widgets_Component/Base_screen/Base_screen.dart';
import 'package:berrytalks/Widgets_Component/Enum/enum.dart';
import 'package:berrytalks/Widgets_Component/Toaster/animated_toaster.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppImages.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppUitilities.dart';
import 'package:berrytalks/main.dart';
import 'package:berrytalks/network/socket_service/chat_notification_router.dart';
import 'package:berrytalks/network/socket_service/local_push_notification_service.dart';
import 'package:berrytalks/network/socket_service/socket_message_types.dart';
import 'package:berrytalks/network/socket_service/socket_screen_listener.dart';
import 'package:berrytalks/network/socket_service/websocket_service.dart';
import 'package:berrytalks/screens/Home_screen/bloc/home_screen_bloc.dart';
import 'package:berrytalks/screens/Home_screen/widget/conversation_card.dart';
import 'package:berrytalks/screens/Home_screen/widget/horizontal_color_loading_bar.dart';
import 'package:berrytalks/screens/Home_screen/widget/search_filter_bar.dart';
import 'package:berrytalks/screens/Home_screen/widget/workspace.dart';
import 'package:berrytalks/services/storage/SharedPrefrences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:berrytalks/screens/Settings/bloc/settings_bloc.dart'
    hide BackPressActionEvent, BackPressActionState, LoadingState, LoadingSuccessState, LoadingErrorState, FetchAgentProfileEvent;
import '../../../network/ApiService.dart';
import '../../Chat_screen/args/ChatScreenArgs.dart';
import '../widget/status/agent_availability_status.dart';
import '../widget/status/status_dropdown_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SocketScreenListener {
  final bool isScrollable = false;
  final isFullScreen = true;
  final WebSocketService _ws = WebSocketService();
  WebSocketStatus _status = WebSocketStatus.idle;
  String _statusMessage = 'Idle';
  String? publicAgentId;
  String? token;
  String? email;
  String? password;
  bool _isRefreshing = false;
  bool _chatListRequested = false;
  CompanyProfileData? companyProfileData = null;
 final ScrollController _scrollController = ScrollController();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _wasOffline = false;
  
  StatusDropdownController statusController = StatusDropdownController(initialStatus: AgentAvailabilityStatus.online);

  Future<void> _loadUserDataAndInit() async {
    final fetchedToken = await SharedPrefData.getAccessOnlyToken();
    final fetchedEmail = await SharedPrefData.getUserEmail();
    final fetchedPassword = await SharedPrefData.getUserPassword();
    final agentId = await SharedPrefData.getAgentPublicId();

    //SETSTATE USE FOR SOCKET
    if (mounted) {
      token = fetchedToken;
      email = fetchedEmail;
      password = fetchedPassword;
      // Keep profile API value if prefs has not been saved yet.
      if (publicAgentId == null || publicAgentId!.isEmpty) {
        publicAgentId = agentId;
      }

      initWebSocket();
    }
  }

   void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final isOnline = results.any((r) => r != ConnectivityResult.none);

      if (!isOnline) {
        _wasOffline = true;
      } else if (_wasOffline && isOnline) {
        _wasOffline = false;

        // Socket reconnect
        WebSocketService().connect();

        // Chat list silently refresh karo
      //    if (mounted) {
      //   context.read<HomeBloc>().add(
      //     FetchConversationEvent(isSilent: true, isRefresh: true), // <-- FIX
      //   );
      // }
       if (mounted) {
        // Chat route open hai to HomeBloc ko disturb mat karo
        final location = GoRouter.of(context)
            .routerDelegate.currentConfiguration.matches.last.matchedLocation;
        
        if (location != CHAT_ROUTE) {
          context.read<HomeBloc>().add(
            FetchConversationEvent(isSilent: true, isRefresh: true),
          );
        }
      }


        // Socket re-subscribe
        _requestChatListViaSocket(force: true);
      }
    });
  }

  void initWebSocket() {
    _ws.setParams(token: token ?? '');
    _ws.setAuthCredentials(username: email ?? '', password: password ?? '');

    listenSocketStatus((update) {
      _status = update.status;
      _statusMessage = update.message;

      // Server often does not emit `auth-status`; once connected + auto-auth
      // completes, request the chat list.
      if (update.status == WebSocketStatus.connected) {
        _scheduleChatListRequestAfterAuth();
      } else if (update.status == WebSocketStatus.disconnected ||
          update.status == WebSocketStatus.reconnecting) {
        _chatListRequested = false;
      }
    });

    listenSocketType(SocketMessageType.authStatus, (_) {
      _requestChatListViaSocket();
    });

    listenSocketType(SocketMessageType.pingResponse, (json) {
      developer.log("====== PINGING ======");
      developer.log("Socket_Connection_Stats : AgentPublicId: $publicAgentId");
      developer.log("Socket_Connection_Stats : PINGING $json");
      developer.log("Socket_Connection_Stats : Token $token");
      final code = json['message'] as String? ?? '99';
      AppUtilities.autoLogOut(
        statusCode: int.parse(code),
        onLogOut: () {
          print("[AUTO LOGOUT] - Home session detected.");
        },
      );
    });

    listenSocketType(SocketMessageType.contactListUpdate, (json) {
      developer.log("====== CONTACT LIST UPDATE ======");
      developer.log("Socket_Connection_Stats : $json");
      if (!mounted) return;
      context.read<HomeBloc>().add(UpdateChatListFromSocketEvent(payload: json));
    });

    listenSocketType(SocketMessageType.notificationResponse, (json) {
      developer.log("====== NOTIFICATION RESPONSE ======");
      developer.log("Socket_Connection_Stats : $json");
      ChatNotificationRouter.instance.handleNotificationResponse(json);
    });

    _ws.start();
  }

  /// Waits briefly after connect so central `auth-request` → `auth` can finish.
  void _scheduleChatListRequestAfterAuth() {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      _requestChatListViaSocket();
    });
  }

  Future<void> _requestChatListViaSocket({bool force = false}) async {
    if (!force && _chatListRequested) return;

    final agentId = publicAgentId ?? await SharedPrefData.getAgentPublicId();
    if (agentId == null || agentId.isEmpty) {
      developer.log(
        'Socket_Connection_Stats: update-chat-list skipped — agentId is null/empty',
      );
      return;
    }

    if (!_ws.isConnected) {
      developer.log(
        'Socket_Connection_Stats: update-chat-list skipped — socket not connected',
      );
      return;
    }

    _chatListRequested = true;
    developer.log(
      'Socket_Connection_Stats: sending update-chat-list agentPublicId=$agentId',
    );
    _ws.send({
      'type': SocketMessageType.updateChatList,
      'data': {'agentPublicId': agentId},
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<HomeBloc>().state;
      if (state is ConversationLoadedState) {
        if (!state.isFetchingMore && state.hasMore) {
          context.read<HomeBloc>().add(FetchConversationEvent(isRefresh: false));
        }
      }
    }
  }



  Future<void> _onRefresh() async {
    final bloc = context.read<HomeBloc>();
    final refreshFuture = bloc.stream.firstWhere(
      (state) => state is ConversationLoadedState || state is LoadingErrorState,
    );
    
    bloc.add(FetchConversationEvent(isRefresh: true));
    await _requestChatListViaSocket(force: true);
    await refreshFuture.timeout(const Duration(seconds: 30));
  }

  

  Widget _buildListDivider(Color borderColor, bool isFetchingMore) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(height: 1, thickness: 1, color: borderColor),
        if (isFetchingMore) const HorizontalColorLoadingBar(),
      ],
    );
  }

  Widget _wrapRefreshable({
    required Widget child,
  }) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (notification) {
        notification.disallowIndicator();
        return false;
      },
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Colors.transparent,
        backgroundColor: Colors.transparent,
        displacement: 0,
        strokeWidth: 0,
        elevation: 0,
        child: child,
      ),
    );
  }

  

  @override
  void initState() {
    super.initState();
    print(" [HomeScreen]: initState called. Fetching conversations.");
    _scrollController.addListener(_onScroll);
    context.read<HomeBloc>().add(FetchAgentProfileEvent());
    context.read<HomeBloc>().add(FetchCompanyProfileEvent());
    context.read<HomeBloc>().add(FetchConversationEvent(isRefresh: true));
    // Tapping a notification opens the matching chat.
    ChatNotificationRouter.instance.registerChatOpener(_openChatByNumber);
    _checkAndRequestNotifications();
    _setupConnectivityListener(); 
  }

  // Yeh helper method background mein check karegi
Future<void> _checkAndRequestNotifications() async {
  try {
    // SharedPref se check karein ke user ne kahin notification settings off toh nahi ki hui
    final bool isNotificationEnabledInSettings = 
        await SharedPrefData.getPushNotificationPreference() ?? true; // Default true rakhein

    if (isNotificationEnabledInSettings) {
      final pushService = LocalPushNotificationService();
      
      // Agar pehle se allow hai toh chup-chaap true return ho jayega (no pop-up).
      // Agar pehle allow nahi thi aur new user hai, toh system pop-up dikha dega.
      await pushService.requestNotificationPermission();
    }
  } catch (e) {
    if (kDebugMode) {
      print("Error requesting notification permission: $e");
    }
  }
}

  /// Opens the chat for a customer [number] coming from a notification tap.
  void _openChatByNumber(String number) {
    if (!mounted) return;
    final bloc = context.read<HomeBloc>();
    final contact = bloc.findContactByNumber(number);
    if (contact == null) {
      developer.log('ChatNotification: no contact found for $number');
      return;
    }
    bloc.add(OpenChatEvent(item: contact));
  }

  // Future<void> _refreshChatListOnReturnFromChat() async {
  //   if (!mounted) return;
  //   _chatListRequested = false;
  //   developer.log(
  //     'Socket_Connection_Stats: refreshing chat list after returning from chat',
  //   );
  //   await _requestChatListViaSocket(force: true);
  // }

  Future<void> _openChatScreen(ContactData item) async {
    final args = ChatScreenArgs(
      contactItem: item,
      companyProfileData: companyProfileData,
    );
    await context.push(CHAT_ROUTE, extra: args);
    // Refresh after route pop — never from ChatScreen.dispose (Home may
    // already be unmounted during widget-tree finalization).
    if (!mounted) return;
    context.read<HomeBloc>().add(FetchConversationEvent());
  }

  @override
  void dispose() {
    ChatNotificationRouter.instance.unregisterChatOpener();
     _connectivitySubscription?.cancel();
    super.dispose();
  }

  // socket subscriptions also disposed by [SocketScreenListener] mixin.

  @override
  Widget build(BuildContext context) {
    final Color borderColor = AppThemeUtilities.getAppBarShadowColor(context);
    return BlocConsumer<HomeBloc, HomeState>(
      listenWhen: (previous, current) => current is HomeActionState,
      buildWhen: (previous, current) => current is! HomeActionState,
      listener: (context, state) async {
        print("[HomeScreen Listener]: New HomeState -> ${state.runtimeType}");
        if (state is LoadingState) {
           final bool isChatOpen = GoRouter.of(context).routerDelegate
        .currentConfiguration.matches
        .any((m) => m.matchedLocation == CHAT_ROUTE);
          if (!isChatOpen) {
      AppUtilities.showLoadingDialog(context);
    }
          //AppUtilities.showLoadingDialog(context);
        }
        else if (state is LoadingSuccessState) {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        }
        if (state is LoadingErrorState) {
          print("API Parsing or Fetching Error: ${state.errorMsg}");
          AnimatedToast.show(context, "Api End Error");
        }
        else if (state is BackPressActionState) {
          print(" [HomeScreen Listener]: BackPressActionState detected.");
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        }
        else if (state is ShowExitWarningActionState) {
          print("[HomeScreen Listener]: Showing AnimatedToast Now!");
          AnimatedToast.show(context, 'Press back again to leave');
        }
        else if (state is ExitAppActionState) {
          SystemNavigator.pop();
        }
        else if (state is OpenChatActionState) {
          print(
            " [HomeScreen Listener]: Navigating to Chat Screen -> ${state.item.displayName}",
          );
          print("NAVIGATING TO CHAT SCREEN VIA GO_ROUTER");

          await _openChatScreen(state.item);
        }
        else if (state is ChangeOnlineStatusActionState) {
          statusController.setStatusFromApi(state.status);
        }
        else if (state is GetAgentProfileActionState) {
          publicAgentId = state.data?.publicId;

          final id = publicAgentId;
          if (id != null && id.isNotEmpty) {
            await SharedPrefData.saveAgentPublicId(id);
          }

          print("Socket_Connection_Stats: AGENT PUBLIC ID: $publicAgentId");
          await _loadUserDataAndInit();
          await _requestChatListViaSocket(force: true);
          statusController.setStatusFromApi(state.data?.status);
        }
        else if (state is ForceLogoutActionState) {
          print("[HomeScreen] Force logout - going to login");
          context.go(LOGIN_ROUTE);
        }
        else if (state is GetCompanyProfileDataActionState) {
          companyProfileData = state.data!;
          print("Company Profile Data: Company Number: ${state.data!.whatsappNumber}");
          await SharedPrefData.saveCompanyProfileData(state.data!);
        }
      },

      builder: (BuildContext context, HomeState state) {
        final backgroundColor = AppThemeUtilities.getCardColor(context);
        switch (state.runtimeType) {
          case HomeInitialState:
            return BaseScreen(
              onPanUpdate: () {
                BlocProvider.of<HomeBloc>(context).add(BackPressActionEvent());
              },
              onWillPop: () async {
                BlocProvider.of<HomeBloc>(context).add(BackPressActionEvent());
              },
              isScrollable: isScrollable,
              isFullScreen: isFullScreen,
              routeName: HOME_ROUTE,
              screenIndex: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: backgroundColor,
                child: Container(
                  margin: EdgeInsets.only(
                    left: 0,
                    top: 40,
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
                      Container(
                        margin: EdgeInsets.only(
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
                        child: WorkspaceHeader(statusController: statusController,onStatusChanged: (status) {
                          BlocProvider.of<HomeBloc>(context,).add(ChangeOnlineStatusEvent(status: status.apiValue, publicAgentId: publicAgentId));
                        },),
                      ),
                      Container(
                        margin: EdgeInsets.only(
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
                        child: const SearchFilterBar(),
                      ),
                      _buildListDivider(borderColor, false),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
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
                          child: _wrapRefreshable(
                            child: Skeletonizer(
                              enabled: true,
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: 1,
                                itemBuilder: (context, index) {
                                  return SizedBox(
                                    height:
                                        MediaQuery.sizeOf(context).height * 0.55,
                                    child: ConversationCard(
                                      name: "Loading Name",
                                      message: "Loading message...",
                                      time: "0m ago",
                                      unreadCount: 0,
                                      status: "Loading Status",
                                      onTap: () {},
                                      platform: SocialPlatform.whatsapp,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          case ConversationLoadedState:
            final loadedState = state as ConversationLoadedState;
            return BaseScreen(
              onPanUpdate: () {
                BlocProvider.of<HomeBloc>(context).add(BackPressActionEvent());
              },
              onWillPop: () async {
                BlocProvider.of<HomeBloc>(context).add(BackPressActionEvent());

                //return false;
              },
              isScrollable: isScrollable,
              isFullScreen: isFullScreen,
              routeName: HOME_ROUTE,
              screenIndex: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: backgroundColor,
                child: Container(
                  margin: EdgeInsets.only(
                    left: 0,
                    top: 40,
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
                      Container(
                        margin: EdgeInsets.only(
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
                        child: WorkspaceHeader(statusController: statusController,onStatusChanged: (status) {
                          BlocProvider.of<HomeBloc>(context,).add(ChangeOnlineStatusEvent(status: status.apiValue, publicAgentId: publicAgentId));
                        },),
                      ),
                      Container(
                        margin: EdgeInsets.only(
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
                        child: const SearchFilterBar(),
                      ),
                     _buildListDivider(borderColor, loadedState.isFetchingMore),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
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
                          child: _wrapRefreshable(
                            child: ListView.builder(
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                              padding: EdgeInsets.zero,
                              itemCount: loadedState.conversations.isEmpty
                                  ? 1
                                  : loadedState.conversations.length,
                              itemBuilder: (context, index) {
                                if (loadedState.conversations.isEmpty) {
                                  return SizedBox(
                                    height:
                                        MediaQuery.sizeOf(context).height * 0.55,
                                  );
                                }

                                final item = loadedState.conversations[index];

                                return ConversationCard(
                                  name: item.displayName,
                                  message: item.lastMessage ?? "",
                                  time: item.formattedTime,
                                  unreadCount: (item.unReadCount is int) ? item.unReadCount : (int.tryParse(item.unReadCount?.toString() ?? '0',) ?? 0),
                                  status: item.status ?? "NO STATUS",
                                  platform: item.platform,
                                  onTap: () {
                                    print("CARD TAPPED: ${item.displayName} (ID: ${item.id})",);

                                    context.read<HomeBloc>().add(OpenChatEvent(item: item),);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          case ConversationNoLoadedState:
            return BaseScreen(
              onPanUpdate: () {
                BlocProvider.of<HomeBloc>(context).add(BackPressActionEvent());
              },
              onWillPop: () async {
                BlocProvider.of<HomeBloc>(context).add(BackPressActionEvent());
              },
              isScrollable: isScrollable,
              isFullScreen: isFullScreen,
              routeName: HOME_ROUTE,
              screenIndex: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: backgroundColor,
                child: Container(
                  margin: EdgeInsets.only(
                    left: 0,
                    top: 40,
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
                      Container(
                        margin: EdgeInsets.only(
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
                        child: WorkspaceHeader(statusController: statusController,onStatusChanged: (status) {
                          BlocProvider.of<HomeBloc>(context,).add(ChangeOnlineStatusEvent(status: status.apiValue, publicAgentId: publicAgentId));
                        },),
                      ),
                      Container(
                        margin: EdgeInsets.only(
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
                        child: const SearchFilterBar(),
                      ),
                    _buildListDivider(borderColor, false),
                      Expanded(
                        child: Container(
                          width: ((MediaQuery.of(context).size.width)),
                          //  height: ((MediaQuery.of(context).size.height)),
                          color: AppThemeUtilities.appScreenBGColor,
                          child: _wrapRefreshable(
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight:
                                      MediaQuery.sizeOf(context).height * 0.55,
                                ),
                                child: Container(
                                width: ((MediaQuery.of(context).size.width)),
                                color: AppThemeUtilities.appScreenBGColor,
                                child: Stack(
                                  children: [
                                    Container(
                                      height:
                                          View.of(context).physicalSize.height /
                                          3.5,
                                      margin: EdgeInsets.only(
                                        left: 0,
                                        top: 20,
                                        right: 0,
                                        bottom: 24,
                                      ),
                                      padding: EdgeInsets.only(
                                        left: 0,
                                        top: 0,
                                        right: 0,
                                        bottom: 24,
                                      ),
                                      child: Center(
                                        child: Wrap(
                                          direction: Axis.vertical,
                                          alignment: WrapAlignment.center,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          spacing: 0,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                left: 0,
                                                top: 20,
                                                right: 0,
                                                bottom: 0,
                                              ),
                                              child: Text(
                                                "No data is available",
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800,
                                                  color:
                                                      AppThemeUtilities.HexToColor(
                                                        "#00599B",
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
                                              child: SvgPicture.asset(
                                                AppImages.noRecord,
                                                width: 200,
                                                height: 200,
                                                fit: BoxFit.scaleDown,
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                left: 0,
                                                top: 0,
                                                right: 0,
                                                bottom: 0,
                                              ),
                                              child: Text(
                                                "There are no records available right\nPlease try again later.",
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      AppThemeUtilities.HexToColor(
                                                        "#00599B",
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
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
              ),
            );
          default:
            return Container();
        }
      },
    );
  }
}
