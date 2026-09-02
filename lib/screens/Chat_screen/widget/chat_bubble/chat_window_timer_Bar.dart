import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:berrytalks/screens/Chat_screen/bloc/chat_screen_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatWindowTimerBar extends StatelessWidget {
  const ChatWindowTimerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (previous, current)
       {
        if (previous is ChatDataLoadedState && current is ChatDataLoadedState) {
          return previous.formattedTime != current.formattedTime || 
                 previous.isWindowClosed != current.isWindowClosed;
        }
        return current is ChatDataLoadedState;
      },
      builder: (context, state) {
        String timeText = "00h 00m 00s";
        bool isClosed = false;

       if (state is ChatDataLoadedState) {
          if (state.conversation == null) {
           return Container(
              margin: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
              padding: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
            );
          }
          
          timeText = state.formattedTime;
          isClosed = state.isWindowClosed;
        } else {
          return Container(
              margin: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
              padding: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
            );
        }

        final Color bgColor = isClosed 
            ? AppThemeUtilities.HexToColor("#F5F5F5") // Expired grey background
            : AppThemeUtilities.HexToColor("#FFF7E6"); // Active orange background

        final Color borderColor = isClosed 
            ? AppThemeUtilities.HexToColor("#D9D9D9") 
            : AppThemeUtilities.HexToColor("#FFD59A");

        final Color contentColor = isClosed 
            ? AppThemeUtilities.HexToColor("#8C8C8C") // Expired text/icon color
            : AppThemeUtilities.HexToColor("#D46B08"); // Active text/icon color

        final String barText = isClosed 
            ? "Chat window has been closed" 
            : "Chat window closed in: $timeText";

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            left: 8,
            top: 13,
            right: 8,
            bottom: 13,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              bottom: BorderSide(color: borderColor, width: 1),
              top: BorderSide(color: borderColor, width: 3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isClosed ? Icons.lock_clock_rounded : Icons.access_time_rounded,
                size: 16,
                color: contentColor,
              ),
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
                barText,
                style: GoogleFonts.poppins(
                  color: contentColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}