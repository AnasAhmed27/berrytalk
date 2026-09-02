import 'package:berrytalks/Widgets_Component/Base_screen/Base_screen.dart';
import 'package:berrytalks/Widgets_Component/Enum/desigantion_enum.dart';
import 'package:berrytalks/Widgets_Component/Enum/desigantion_ext.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppConstants.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppUitilities.dart';
import 'package:berrytalks/main.dart';
import 'package:berrytalks/screens/Team_chat_screen/bloc/team_chat_bloc.dart';
import 'package:berrytalks/screens/Team_chat_screen/widget/team_bottom_bar.dart';
import 'package:berrytalks/screens/Team_chat_screen/widget/team_chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TeamChatScreen extends StatefulWidget {
  final String name;
  final DesigantionStatus desStatus;
  final String recipientAgentId;
  const TeamChatScreen({
    super.key,
    required this.name,
    required this.desStatus,
    required this.recipientAgentId,
  });

  @override
  State<TeamChatScreen> createState() => _TeamChatScreenState();
}

class _TeamChatScreenState extends State<TeamChatScreen> {
  final bool isScrollable = false;
  final isFullScreen = true;
  int _lastKnownMessageCount = 0;
  bool _isAwayFromLatest = false;
  bool _showJumpToLatestFab = false;
    final ScrollController _messagesScrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    
    context.read<TeamChatBloc>().add(
      InitTeamChatEvent(
        name: widget.name,
        desStatus: widget.desStatus,
        recipientAgentId: widget.recipientAgentId,
      ),
    );

    context.read<TeamChatBloc>().add(
      FetchTeamChatHistoryEvent(
        recipientAgentId: widget.recipientAgentId,
        name: widget.name, desStatus: widget.desStatus,
      ),
    );
  }

void _syncJumpFabForMessageCount(int messageCount) {
  if (messageCount > _lastKnownMessageCount &&
      _lastKnownMessageCount > 0 &&
      _isAwayFromLatest) {
    _showJumpToLatestFab = true;
  }
  
  _lastKnownMessageCount = messageCount;

  if (!_isAwayFromLatest) {
    _showJumpToLatestFab = false;
  }
}

  @override
  Widget build(BuildContext context) {
    final backgroundColor = AppThemeUtilities.getCardColor(context);
    final Color mainTextColor = AppThemeUtilities.getTextColor(context);
    final Color subTextColor = AppThemeUtilities.getTimeColor(context);

    return BlocConsumer<TeamChatBloc, TeamChatState>(
      listenWhen: (previous, current) => current is TeamChatActionState,
      buildWhen: (previous, current) => current is! TeamChatActionState,
      listener: (context, state) {
        if (state is LoadingState) {
          AppUtilities.showLoadingDialog(context);
        } else if (state is LoadingSuccessState) {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        } else if (state is BackPressActionState) {
          if (GoRouter.of(context).canPop()) {
            context.pop();
          }
        }
      },

      builder: (BuildContext context, TeamChatState state) {
        print(
          "[TeamChatScreen Builder] Current State Type: ${state.runtimeType}",
        );
        switch (state.runtimeType) {
          case TeamChatInitialState:
          case TeamChatHistoryLoadingState:
            print(
              "⏳ [TeamChatScreen Builder] Rendering TeamChatInitialState View with Skeletonizer",
            );

            return BaseScreen(
              backgroundColor: backgroundColor,
              onPanUpdate: () {
                BlocProvider.of<TeamChatBloc>(
                  context,
                ).add(BackPressActionEvent());
              },
              onWillPop: () {
                BlocProvider.of<TeamChatBloc>(
                  context,
                ).add(BackPressActionEvent());
              },
              isScrollable: isScrollable,
              isFullScreen: isFullScreen,
              routeName: TEAM_CHAT_ROUTE,
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
                  padding: const EdgeInsets.only(left: 10),
                  child: InkWell(
                    onTap: () {
                      BlocProvider.of<TeamChatBloc>(
                        context,
                      ).add(BackPressActionEvent());
                    },
                    child: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                title: Row(
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
                            "via ${widget.desStatus.title}",
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
                  ],
                ),
              ),
              screenIndex: 3,
              child: Skeletonizer(
                enabled: true,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: backgroundColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          physics: const NeverScrollableScrollPhysics(),
                          children: const [
                            TeamBubble(
                              message:
                                  "Loading message content placeholder data",
                              time: "00:00 AM",
                              isMe: false,
                              initials: "XX", messageType: 'text',
                              currentMessageIndex: 0,
                      allMessagesList: [],
                            ),
                         
                          ],
                        ),
                      ),
                      const TeamBottomBar(companyNumber: '',),
                    ],
                  ),
                ),
              ),
            );

          case TeamChatDataLoadedState:
            final loadedState = state as TeamChatDataLoadedState;

            return BaseScreen(
              backgroundColor: backgroundColor,
              onPanUpdate: () {
                BlocProvider.of<TeamChatBloc>(
                  context,
                ).add(BackPressActionEvent());
              },
              onWillPop: () {
                BlocProvider.of<TeamChatBloc>(
                  context,
                ).add(BackPressActionEvent());
              },
              isScrollable: isScrollable,
              isFullScreen: isFullScreen,
              routeName: TEAM_CHAT_ROUTE,
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
                      BlocProvider.of<TeamChatBloc>(
                        context,
                      ).add(BackPressActionEvent());
                    },
                    child: const Icon(Icons.arrow_back_rounded),
                  ),
                ),

                title: InkWell(
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
                                top: 2, // 2px vertical spacing handled here
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
                              "via ${loadedState.desStatus.title}",

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

                      // const TeamMenuActions(),
                    ],
                  ),
                ),
              ),

              screenIndex: 3,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: backgroundColor,

                child: Container(
                  margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
                  padding: const EdgeInsets.only(
                    left: 0,
                    top: 0,
                    right: 0,
                    bottom: 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            : 
                            Builder(

                              builder: ( context ){
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
                                        messageData.senderAgentId !=
                                        widget.recipientAgentId;
                              
                                        final String avatarInitials = !isMe
                                                    ? (messageData.name != null && messageData.name!.isNotEmpty
                                                        ? messageData.name!.substring(0, messageData.name!.length > 1 ? 2 : 1).toUpperCase()
                                                        : "AG")
                                                    : "ME";

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
                                          child: TeamBubble(
                                            message: messageData.textBody ?? "",
                                            time: messageData.formattedMessageTime,
                                            isMe: isMe,
                                            initials: avatarInitials,
                                            messageType: messageData.formattedMessageTime, 
                                                        filePath: messageData.filePath,  
                                                        currentMessageIndex: index, 
                      allMessagesList: loadedState.messages,              
                                                       
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                    ]
                                  );
                              }
                            ),
                      ),
                      const TeamBottomBar(companyNumber: '',),
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

  Widget _buildTopLoader(TeamChatDataLoadedState state) {
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
}
