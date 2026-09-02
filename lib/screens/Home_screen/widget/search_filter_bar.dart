import 'package:berrytalks/Widgets_Component/Utils/AppConstants.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppImages.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:berrytalks/screens/Home_screen/bloc/home_screen_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class SearchFilterBar extends StatefulWidget {
  const SearchFilterBar({super.key});

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color currentBgColor = AppThemeUtilities.getCardColor(context);
    final Color textColor = AppThemeUtilities.getTextColor(context);
    final Color hintColor = AppThemeUtilities.getTimeColor(context);
    final Color borderColor = AppThemeUtilities.getAppBarShadowColor(context);
    final Color statusIconColor = Theme.of(context).brightness == Brightness.dark 
        ? Colors.grey[400]! 
        : Colors.grey[600]!;

    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is ConversationLoadedState) {
          if (state.textQuery.isEmpty && _searchController.text.isNotEmpty) {
            _searchController.clear();
          }
        }
      },
      builder: (context, state) {
        String currentHint = "Search conversations...";
        bool showClearBtn = false;

        if (state is ConversationLoadedState) {
          currentHint = state.searchHint;
          showClearBtn = state.isFilterActive;
        }

        return Container(
          padding: const EdgeInsets.only(
            left: 20,
            top: 10,
            right: 10,
            bottom: 10,
          ),
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
                    controller: _searchController,
                    onChanged: (value) {
                      context.read<HomeBloc>().add(
                        SearchConversationEvent(value),
                      );
                      if (value.trim().isEmpty) {
                        FocusScope.of(context).unfocus();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: currentHint,
                      hintStyle: TextStyle(
                        color: hintColor,
                        fontSize: 14,
                        fontWeight: AppConstants.FontWeight_Regular,
                      ),
                      border: InputBorder.none,
                      suffixIcon: showClearBtn
                          ? IconButton(
                              icon: Icon(
                                Icons.cancel,
                                color: hintColor,
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                FocusScope.of(context).unfocus();
                                context.read<HomeBloc>().add(
                                  FilterConversationEvent(
                                    filterType: "clear",
                                    filterValue: "",
                                  ),
                                );
                              },
                            )
                          : null,
                    ),
                    cursorColor: hintColor,
                  ),
                ),
              ),

              // --- Filter Dropdown ---
              PopupMenuButton<Map<String, String>>(
                padding: EdgeInsets.zero,
                color: currentBgColor,
                elevation: 8,
                offset: const Offset(0, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onSelected: (result) {
                  FocusScope.of(context).unfocus();

                  context.read<HomeBloc>().add(
                    FilterConversationEvent(
                      filterType: result["type"]!,
                      filterValue: result["value"]!,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(
                    left: 5,
                    top: 0,
                    right: 0,
                    bottom: 0,
                  ),
                  padding: const EdgeInsets.only(
                    left: 15,
                    top: 15,
                    right: 15,
                    bottom: 15,
                  ),
                  decoration: BoxDecoration(
                    color: currentBgColor,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SvgPicture.asset(
                    AppImages.filter,
                    height: 16,
                    width: 15,
                    colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                  ),
                ),
                itemBuilder: (context) {
                  final channels = [
                    {"t": "WhatsApp", "i": AppImages.whatsapp},
                    {"t": "Email", "i": AppImages.email},
                    {"t": "SMS", "i": AppImages.sms},
                    {"t": "Facebook", "i": AppImages.messenger},
                    {"t": "Instagram", "i": AppImages.ig},
                    {"t": "Web Chat", "i": AppImages.wechat},
                    {"t": "Twitter", "i": AppImages.twitter},
                  ];

                  final statuses = [
                    {"t": "Open", "i": AppImages.open},
                    {"t": "Waiting", "i": AppImages.waiting},
                    {"t": "Solved", "i": AppImages.solvedFliter},
                    {"t": "Closed", "i": AppImages.closeFilter},
                    {"t": "Unread", "i": AppImages.unread},
                  ];

                  return [
                    _buildStyledHeader(context, "Filter by Channel"),
                    const PopupMenuDivider(height: 1),
                    ...channels.map(
                      (item) => _buildStyledItem(
                        context,
                        item["t"] as String,
                        item["i"] as String,
                        "channel",
                        null,
                      ),
                    ),
                    const PopupMenuDivider(height: 1),
                    _buildStyledHeader(context, "Filter by Status"),
                    const PopupMenuDivider(height: 1),
                    ...statuses.map(
                      (item) => _buildStyledItem(
                        context,
                        item["t"] as String,
                        item["i"] as String,
                        "status",
                        statusIconColor,
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        );
      },
    );
  }

  PopupMenuItem<Map<String, String>> _buildStyledHeader(
    BuildContext context,
    String title,
  ) {
    final Color hintColor = AppThemeUtilities.getTimeColor(context);
    return PopupMenuItem<Map<String, String>>(
      enabled: false,
      height: 35,
      child: Container(
        margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
        padding: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: hintColor.withOpacity(0.8),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<Map<String, String>> _buildStyledItem(
    BuildContext context,
    String title,
    String iconPath,
    String filterType,
    Color? overrideIconColor,
  ) {
    final Color textColor = AppThemeUtilities.getTextColor(context);
    return PopupMenuItem<Map<String, String>>(
      value: {"type": filterType, "value": title},
      padding: EdgeInsets.zero,
      height: 35,
      child: Container(
        padding: const EdgeInsets.only(left: 10, top: 0, right: 30, bottom: 0),
        child: Row(
          children: [
            Image.asset(iconPath, height: 18, width: 18, fit: BoxFit.contain,color: overrideIconColor),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 4, top: 0, right: 4, bottom: 0),
                padding: const EdgeInsets.only(
                  left: 4,
                  top: 0,
                  right: 4,
                  bottom: 0,
                ),
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
