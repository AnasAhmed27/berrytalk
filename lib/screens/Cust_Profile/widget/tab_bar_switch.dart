import 'package:berrytalks/Widgets_Component/Utils/AppConstants.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:berrytalks/screens/Cust_Profile/bloc/customer_profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TabBarSwitch extends StatelessWidget {
  final int activeTab;
  const TabBarSwitch({super.key, required this.activeTab});

  @override
  Widget build(BuildContext context) {
    final Color currentBgColor = AppThemeUtilities.getCardColor(context); 
    final Color borderColor = AppThemeUtilities.getAppBarShadowColor(context);

    return Container(
      margin: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: currentBgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildTabItem(context, title: 'Overview', index: 0),
          _buildTabItem(context, title: 'Orders', index: 1),
        ],
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, {required String title, required int index}) {
    final isSelected = activeTab == index;
    final Color textColor = AppThemeUtilities.getTextColor(context);
    final Color hintColor = AppThemeUtilities.getTimeColor(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          BlocProvider.of<CustomerProfileBloc>(context).add(ToggleTabEvent(index));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected 
                ? (isDarkMode ? Colors.white.withOpacity(0.12) : AppThemeUtilities.HexToColor("#f9fafb")) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected && !isDarkMode 
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                : [],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppConstants.FontFamily_SFPro,
              fontSize: 14,
              fontWeight: AppConstants.FontWeight_Medium,
             
              color: isSelected ? textColor : hintColor, 
            ),
          ),
        ),
      ),
    );
  }
}