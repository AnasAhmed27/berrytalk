import 'package:berrytalks/Widgets_Component/BottomNavBar/bloc/bottom_nav_bar_bloc.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:berrytalks/Widgets_Component/utils/AppImages.dart';
import 'package:berrytalks/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return BottomNavigationBar(
          currentIndex: state.selectedIndex,
          backgroundColor: isDark
              ? const Color(0xFF1A1A1A)
              : AppThemeUtilities.HexToColor("#F8F9FA"),
          onTap: (index) {
            context.read<NavigationBloc>().add(TabChanged(index));

            if (index == 0) {
             // print("[BottomNavBar Navigating]: Directing to HOME_ROUTE");
              context.go(HOME_ROUTE);
            } else if (index == 1) {
            //  print("[BottomNavBar Navigating]: Directing to TEAM_ROUTE");
            
              context.go(TEAM_ROUTE);
            }
          },
          selectedItemColor: AppThemeUtilities.HexToColor("#88cda6"),
          unselectedItemColor: isDark
              ? Colors.grey[500]
              : AppThemeUtilities.HexToColor("#868686"),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                AppImages.chat,
                height: 40,
                width: 40,
                colorFilter: ColorFilter.mode(
                  state.selectedIndex == 0
                      ? AppThemeUtilities.HexToColor("#2EAD66")
                      : (isDark
                            ? Colors.grey[500]!
                            : AppThemeUtilities.HexToColor("#868686")),
                  BlendMode.srcIn,
                ),
              ),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                AppImages.team,
                height: 40,
                width: 40,
                colorFilter: ColorFilter.mode(
                  state.selectedIndex == 1
                      ? AppThemeUtilities.HexToColor("#2EAD66")
                      : (isDark
                            ? Colors.grey[500]!
                            : AppThemeUtilities.HexToColor("#868686")),
                  BlendMode.srcIn,
                ),
              ),
              label: 'Team',
            ),
          ],
        );
      },
    );
  }
}
