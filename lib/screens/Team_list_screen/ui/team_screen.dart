import 'package:berrytalks/Widgets_Component/Base_screen/Base_screen.dart';
import 'package:berrytalks/Widgets_Component/BottomNavBar/bloc/bottom_nav_bar_bloc.dart';
import 'package:berrytalks/Widgets_Component/Enum/desigantion_enum.dart';
import 'package:berrytalks/Widgets_Component/Enum/desigantion_ext.dart';
import 'package:berrytalks/Widgets_Component/Enum/teamStatus.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppConstants.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppImages.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppUitilities.dart';
import 'package:berrytalks/main.dart';
import 'package:berrytalks/network/ApiService.dart';
import 'package:berrytalks/screens/Team_list_screen/bloc/team_bloc.dart';
import 'package:berrytalks/screens/Team_list_screen/widgets/conversation_team_card.dart';
import 'package:berrytalks/screens/Team_list_screen/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final bool isScrollable = false;
  final isFullScreen = true;
  bool isBackEnable = true;

  @override
  void initState() {
    super.initState();
    context.read<TeamBloc>().add(FetchTeamConversationEvent());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = AppThemeUtilities.getCardColor(context);
    final Color mainTextColor = AppThemeUtilities.getTextColor(context);
    final Color subTextColor = AppThemeUtilities.getTimeColor(context);
    return BlocConsumer<TeamBloc, TeamState>(
      listenWhen: (previous, current) => current is TeamActionState,
      buildWhen: (previous, current) => current is! TeamActionState,
      listener: (context, state) {
        if (state is LoadingState) {
          AppUtilities.showLoadingDialog(context);
        } else if (state is LoadingSuccessState) {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        } else if (state is LoadingErrorState) {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        } else if (state is BackPressActionState) {
          if (GoRouter.of(context).canPop()) {
            context.pop();
          } else {
            context.read<NavigationBloc>().add(TabChanged(0));
            context.go(HOME_ROUTE);
          }
        } else if (state is OpenTeamChatActionState) {
          context.push(
            TEAM_CHAT_ROUTE,
            extra: {
              "name": state.name,
              "desStatus": state.desStatus,
              "recipientAgentId": state.id,
            },
          );
        }
        print("STATE RECEIVED: $state");
      },

      builder: (BuildContext context, TeamState state) {
        switch (state.runtimeType) {
          case TeamInitialState:
            return BaseScreen(
              onPanUpdate: () {
                BlocProvider.of<TeamBloc>(context).add(BackPressActionEvent());
              },
              onWillPop: () {
                BlocProvider.of<TeamBloc>(context).add(BackPressActionEvent());
              },
              isScrollable: isScrollable,
              isFullScreen: isFullScreen,
              routeName: TEAM_ROUTE,

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
                      BlocProvider.of<TeamBloc>(
                        context,
                      ).add(BackPressActionEvent());
                    },
                    child: const Icon(Icons.arrow_back_rounded),
                  ),
                ),

                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Team Chat",
                      style: GoogleFonts.poppins(
                        fontWeight: AppConstants.FontWeight_Semibold,
                        fontSize: 16,
                        color: AppThemeUtilities.HexToColor("#010207"),
                      ),
                    ),

                    Text(
                      "",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              screenIndex: 1,
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
                        child: const CustomSearchBar(),
                      ),

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
                          child: Skeletonizer(
                            enabled: true,
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: 6,
                              itemBuilder: (context, index) {
                                return ConversationTeamCard(
                                  name: "Loading Name",
                                  designation: "Loading message...",
                                  // time: "0m ago",
                                  // unreadCount: 0,
                                  statusColor: Colors.grey,
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
          case ConversationLoadedState:
            final loadedState = state as ConversationLoadedState;

            final onlineAgentsCount = loadedState.conversations.where((item) {
              final statusStr = (item.status ?? '').trim().toUpperCase();
              return statusStr == 'ONLINE';
            }).length;
            return BaseScreen(
              onPanUpdate: () {
                BlocProvider.of<TeamBloc>(context).add(BackPressActionEvent());
              },
              onWillPop: () {
                BlocProvider.of<TeamBloc>(context).add(BackPressActionEvent());
              },
              isScrollable: isScrollable,
              isFullScreen: isFullScreen,
              routeName: TEAM_ROUTE,
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
                      BlocProvider.of<TeamBloc>(
                        context,
                      ).add(BackPressActionEvent());
                    },
                    child: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Team Chat",
                      style: GoogleFonts.poppins(
                        fontWeight: AppConstants.FontWeight_Semibold,
                        fontSize: 16,
                        color: mainTextColor,
                      ),
                    ),

                    Text(
                      "$onlineAgentsCount ${onlineAgentsCount == 1 ? 'Agent' : 'Agents'} Online",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline_rounded,
                        size: 28,
                      ),
                      onPressed: () {
                        _showTeamBottomSheet(
                          context: context,
                          availableAgents: loadedState.directoryAgents,
                          mainTextColor: mainTextColor,
                          backgroundColor: backgroundColor,
                          subTextColor: subTextColor,
                          onAgentSelected: (agent) {
                            context.read<TeamBloc>().add(
                              SelectAgentFromSheetEvent(agent),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              screenIndex: 1,
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
                        child: const CustomSearchBar(),
                      ),

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
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: loadedState.conversations.length,
                            itemBuilder: (context, index) {
                              final item = loadedState.conversations[index];

                              final DesigantionStatus designation =
                                  DesigantionStatusExtension.fromRoleString(
                                    item.role,
                                  );

                              final bool isCurrentAgentOnline =
                                  (item.status ?? '').trim().toUpperCase() ==
                                  'ONLINE';

                              return ConversationTeamCard(
                                name: item.displayName,
                                designation: designation.title,
                                statusColor: isCurrentAgentOnline
                                    ? Colors.green
                                    : Colors.grey,
                                onTap: () {
                                  context.read<TeamBloc>().add(
                                    OpenTeamChatEvent(
                                      name: item.displayName,
                                      desStatus: designation,
                                      id: item.recipientAgentId ?? "",
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

          case LoadingErrorState:
            return BaseScreen(
              onPanUpdate: () {
                BlocProvider.of<TeamBloc>(context).add(BackPressActionEvent());
              },
              onWillPop: () {
                BlocProvider.of<TeamBloc>(context).add(BackPressActionEvent());
              },
              isScrollable: isScrollable,
              isFullScreen: isFullScreen,
              routeName: TEAM_ROUTE,

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
                      BlocProvider.of<TeamBloc>(
                        context,
                      ).add(BackPressActionEvent());
                    },
                    child: const Icon(Icons.arrow_back_rounded),
                  ),
                ),

                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Team Chat",
                      style: GoogleFonts.poppins(
                        fontWeight: AppConstants.FontWeight_Semibold,
                        fontSize: 16,
                        color: AppThemeUtilities.HexToColor("#010207"),
                      ),
                    ),

                    Text(
                      "",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              screenIndex: 1,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: backgroundColor,

                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,

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
                          child: const CustomSearchBar(),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: 0,
                            top: 180,
                            right: 0,
                            bottom: 180,
                          ),
                          padding: const EdgeInsets.only(
                            left: 0,
                            top: 0,
                            right: 0,
                            bottom: 0,
                          ),
                          child: SvgPicture.asset(
                            AppImages.nodata,
                            height: 180,
                            width: 180,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          default:
            return BaseScreen(
              onPanUpdate: () {
                BlocProvider.of<TeamBloc>(context).add(BackPressActionEvent());
              },
              onWillPop: () {
                BlocProvider.of<TeamBloc>(context).add(BackPressActionEvent());
              },
              isScrollable: isScrollable,
              isFullScreen: isFullScreen,
              routeName: TEAM_ROUTE,

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
                      BlocProvider.of<TeamBloc>(
                        context,
                      ).add(BackPressActionEvent());
                    },
                    child: const Icon(Icons.arrow_back_rounded),
                  ),
                ),

                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Team Chat",
                      style: GoogleFonts.poppins(
                        fontWeight: AppConstants.FontWeight_Semibold,
                        fontSize: 16,
                        color: AppThemeUtilities.HexToColor("#010207"),
                      ),
                    ),

                    Text(
                      "",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              screenIndex: 1,
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
                        child: const CustomSearchBar(),
                      ),

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
                          child: Skeletonizer(
                            enabled: true,
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: 6,
                              itemBuilder: (context, index) {
                                return ConversationTeamCard(
                                  name: "Loading Name",
                                  designation: "Loading message...",
                                  // time: "0m ago",
                                  // unreadCount: 0,
                                  statusColor: Colors.grey,
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
        }
      },
    );
  }
}

void _showTeamBottomSheet({
  required BuildContext context,
  required List<TeamContactData> availableAgents,
  required Color mainTextColor,
  required Color backgroundColor,
  required Color subTextColor,
  required ValueChanged<TeamContactData> onAgentSelected,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: backgroundColor,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.only(
              top: 14,
              left: 16,
              right: 16,
              bottom: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: subTextColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(
                    top: 18,
                    bottom: 0,
                    left: 0,
                    right: 0,
                  ),
                ),

                Text(
                  "Select Team Member",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: mainTextColor,
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(
                    top: 12,
                    bottom: 0,
                    left: 0,
                    right: 0,
                  ),
                ),

                Expanded(
                  child: availableAgents.isEmpty
                      ? Center(
                          child: Text(
                            "No agents available",
                            style: GoogleFonts.poppins(color: subTextColor),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: availableAgents.length,
                          itemBuilder: (context, index) {
                            final agent = availableAgents[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: mainTextColor.withOpacity(0.1),
                                backgroundImage:
                                    agent.profilePic != null &&
                                        agent.profilePic!.isNotEmpty
                                    ? NetworkImage(agent.profilePic!)
                                    : null,
                                child:
                                    agent.profilePic == null ||
                                        agent.profilePic!.isEmpty
                                    ? Text(
                                        agent.displayName.isNotEmpty
                                            ? agent.displayName[0].toUpperCase()
                                            : "?",
                                        style: GoogleFonts.poppins(
                                          color: mainTextColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              title: Text(
                                agent.displayName,
                                style: GoogleFonts.poppins(
                                  color: mainTextColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: agent.displayRole.isNotEmpty
                                  ? Text(
                                      agent.displayRole,
                                      style: GoogleFonts.poppins(
                                        color: subTextColor,
                                        fontSize: 12,
                                      ),
                                    )
                                  : null,
                              trailing: CircleAvatar(
                                radius: 5,
                                backgroundColor: agent.isOnline
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                onAgentSelected(agent);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
