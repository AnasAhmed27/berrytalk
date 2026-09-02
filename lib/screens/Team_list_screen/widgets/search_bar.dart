import 'package:berrytalks/Widgets_Component/Utils/AppConstants.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:berrytalks/screens/Team_list_screen/bloc/team_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final Color currentBgColor = AppThemeUtilities.getCardColor(context); 
    final Color hintColor = AppThemeUtilities.getTimeColor(context);
    final Color borderColor = AppThemeUtilities.getAppBarShadowColor(context);

    return Container(
      padding: const EdgeInsets.only(left: 20, top: 10, right: 10, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 20),
              decoration: BoxDecoration(
                color: currentBgColor,
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(8),
              ),

              child: TextField(
                onChanged: (value) {
                  context.read<TeamBloc>().add(
                    SearchTeamConversationEvent(value),
                  );
                },

                decoration: InputDecoration(
                  icon: Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: hintColor,
                  ),
                  hintText: "Search agents",
                  hintStyle: TextStyle(
                    color: hintColor,
                    fontSize: 14,
                    fontWeight: AppConstants.FontWeight_Regular,
                  ),
                  border: InputBorder.none,
                ),
                cursorColor: AppThemeUtilities.blackColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
