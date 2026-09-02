import 'package:berrytalks/Widgets_Component/Enum/enum.dart';
import 'package:berrytalks/Widgets_Component/utils/AppImages.dart';
import 'package:berrytalks/network/ApiService.dart';
import 'package:berrytalks/screens/Chat_screen/bloc/chat_screen_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ChatMenuActions extends StatelessWidget {
  //final ContactData contactItem;
  final ConversationData contactItem;
  final SocialPlatform platform;
  final InboxMessage conversationid;

  const ChatMenuActions({
    super.key,
    required this.contactItem,
    required this.platform,
    required this.conversationid,
  });

  @override
  Widget build(BuildContext context) {
    final Color currentBgColor = AppThemeUtilities.getCardColor(context);
    final Color textColor = AppThemeUtilities.getTextColor(context);
    final Color borderColor = AppThemeUtilities.getAppBarShadowColor(context);

    final List<Map<String, String>> menuItems = [
      {"id": "transfer_chat", "title": "Transfer Chat"},
      {"id": "REOPENED", "title": "Reopen"},
      {"id": "PENDING", "title": "Waiting"},
      {"id": "RESOLVED", "title": "Resolve"},
    ];

    return Container(
      padding: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
            ),
            child: InkWell(
              onTap: () {
                print("Help icon clicked");
              },
              child: const Padding(
                padding: EdgeInsets.only(left: 4, top: 4, right: 4, bottom: 4),
                child: Icon(Icons.help_outline_rounded),
              ),
            ),
          ),

          Container(
            margin: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
            padding: const EdgeInsets.only(
              left: 4,
              top: 0,
              right: 0,
              bottom: 0,
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              padding: const EdgeInsets.only(
                left: 0,
                top: 0,
                right: 0,
                bottom: 0,
              ),
              offset: const Offset(0, 50),
              color: currentBgColor,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              constraints: const BoxConstraints(minWidth: 190),
              onSelected: (String value) {
                        final bloc = context.read<ChatBloc>();
              final savedContactItem = contactItem;
               final bool isClosed = 
      savedContactItem.status?.toUpperCase() == 'CLOSED';
                switch (value) {
                  case 'transfer_chat':
                    print("Transfer Chat Clicked");
                    context.read<ChatBloc>().add(
                      FetchTeamContactsEvent(page: 1),
                    );
                    if (isClosed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: Row(
              children: [
                const Icon(Icons.block_rounded, 
                  color: Colors.white, size: 18),
                Container(
      margin: const EdgeInsets.only(
        left: 8, // 8px horizontal spacing handled here
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
                Text(
                  "Closed chat cannot be transferred",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
        return;
      }

                  
                    _showTeamBottomSheet(
                      context: context,
                      chatBloc: bloc,
                      availableAgents: context.read<ChatBloc>().directoryAgents,
                      mainTextColor: textColor,
                      backgroundColor: currentBgColor,
                      subTextColor: textColor.withOpacity(0.6),
                      onAgentSelected: (selectedAgent) {
                        // print("===== TRANSFER PAYLOAD DEBUG =====");
                        // print("assignAgentId: ${selectedAgent.publicId}");
                        // print("chanelId: ${contactItem.chanelId}");
                        // print(
                        //   "companyId: ${selectedAgent.companyPublicId}",
                        // ); 
                        // print("currentAgentId: ${contactItem.agentId}");
                        // print("phoneNumber: ${contactItem.number}");
                        // print("==================================");
                          bloc.add(
                        SubmitTransferChatEvent(
                          assignAgentId: selectedAgent.publicId ?? '',
                          channelId: savedContactItem.chanelId ?? 'WHATSAPP',
                          companyId: selectedAgent.companyPublicId ?? '',
                          currentAgentId: savedContactItem.agentId ?? 'null',
                          phoneNumber: savedContactItem.number ?? '',
                        ),
                      );
                      },
                    );
                    break;

                  case 'REOPENED':
                  case 'PENDING':
                  case 'RESOLVED':
                    if (isClosed) {
        
        String blockedMsg = "";
        if (value == 'REOPENED') {
          blockedMsg = "Closed chat cannot be reopened";
        } else if (value == 'PENDING') {
          blockedMsg = "Closed chat cannot be set to waiting";
        } else if (value == 'RESOLVED') {
          blockedMsg = "Closed chat cannot be resolved";
        }
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: Row(
              children: [
                const Icon(Icons.lock_rounded,
                  color: Colors.white, size: 18),
                Container(
      margin: const EdgeInsets.only(
        left: 8, 
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
                Text(
                  blockedMsg,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
        return;
      }
                    print("Mark as Solved Clicked");
                    // context.read<ChatBloc>().add(MarkSolvedEvent());
                    context.read<ChatBloc>().add(
                      UpdateChatStatusEvent(
                        chatStatus:
                            value, // API Value (REOPENED, PENDING, ya RESOLVED)
                        companyId: contactItem.companyPublicId ?? '',
                        currentAgentId: contactItem.agentId ?? '',
                        phoneNumber: contactItem.number ?? '',
                        conversationId:
                            conversationid.conversationId ??
                            '', // Ensure contactItem has this
                      ),
                    );
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                return List.generate(menuItems.length, (index) {
                  final item = menuItems[index];

                  return PopupMenuItem<String>(
                    value: item["id"],
                    padding: const EdgeInsets.only(
                      left: 0,
                      top: 0,
                      right: 0,
                      bottom: 0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 14,
                            top: 12,
                            right: 14,
                            bottom: 12,
                          ),
                          child: Row(
                            children: [
                              _buildMenuIcon(item["id"]!),
                              Container(
                                margin: const EdgeInsets.only(left: 15),
                              ),
                              Text(
                                item["title"]!,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMenuIcon(String id) {
  String assetPath;

  switch (id) {
    case 'transfer_chat':
      assetPath = AppImages.transfer;
      break;
    case 'RESOLVED':
      assetPath = AppImages.solved;
      break;
    case 'REOPENED':
      assetPath = AppImages.reopen;
      break;
    case 'PENDING':
      assetPath = AppImages.pending;
      break;
    default:
      return const SizedBox.shrink(); 
  }


  return SvgPicture.asset(
    assetPath,
    width: 20,
    height: 20,
    colorFilter: ColorFilter.mode(
      AppThemeUtilities.HexToColor("#898989"),
      BlendMode.srcIn,
    ), 
  );
}

  void _showTeamBottomSheet({
    required BuildContext context,
    required ChatBloc chatBloc,
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
      builder: (modalContext) {
        return BlocProvider.value(
          value: chatBloc,
          child: DraggableScrollableSheet(
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

                    Container(margin: const EdgeInsets.only(top: 18)),

                    Text(
                      "Select Team Member",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: mainTextColor,
                      ),
                    ),

                    Container(margin: const EdgeInsets.only(top: 12)),

                    Expanded(
                      child: BlocBuilder<ChatBloc, ChatState>(
                        builder: (context, state) {
                          List<TeamContactData> displayList = availableAgents;

                          if (state is TeamContactsLoadedState) {
                            displayList = state.teamMembers;
                          }

                          if (state is TeamContactsLoadingState &&
                              displayList.isEmpty) {
                            return Center(
                              child: Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                child: LoadingAnimationWidget.discreteCircle(
                                  color: Colors.green,
                                  secondRingColor: Colors.orange,
                                  thirdRingColor: Colors.blue,
                                  size: 55,
                                ),
                              ),
                            );
                          }

                          if (displayList.isEmpty) {
                            return Center(
                              child: Text(
                                "No agents available",
                                style: GoogleFonts.poppins(color: subTextColor),
                              ),
                            );
                          }

                          return ListView.builder(
                            controller: scrollController,
                            itemCount: displayList.length,
                            itemBuilder: (context, index) {
                              final agent = displayList[index];

                              final bool hasValidPic =
                                  agent.profilePic != null &&
                                  agent.profilePic!.isNotEmpty &&
                                  agent.profilePic!.startsWith('http');
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: mainTextColor.withOpacity(
                                    0.1,
                                  ),
                                  backgroundImage:
                                      agent.profilePic != null &&
                                          agent.profilePic!.isNotEmpty
                                      ? NetworkImage(agent.profilePic!)
                                      : null,
                                  child: !hasValidPic
                                      ? Text(
                                          agent.displayName.isNotEmpty
                                              ? agent.displayName[0]
                                                    .toUpperCase()
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
                                  final savedBloc = context.read<ChatBloc>();

                                  Navigator.of(context).pop();

                                  Future.delayed(
                                    const Duration(milliseconds: 200),
                                    () {
                                      onAgentSelected(agent);
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
