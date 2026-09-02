import 'package:berrytalk/Widgets_Component/BottomNavBar/bloc/bottom_nav_bar_bloc.dart';
import 'package:berrytalk/Widgets_Component/BottomNavBar/ui/BottomNavBar.dart';
import 'package:berrytalk/Widgets_Component/Enum/desigantion_enum.dart';
import 'package:berrytalk/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:berrytalk/network/internet/bloc/network_bloc.dart';
import 'package:berrytalk/network/internet/ui/appNetworkError.dart';
import 'package:berrytalk/network/socket_service/local_push_notification_service.dart';
import 'package:berrytalk/network/socket_service/websocket_service.dart';
import 'package:berrytalk/screens/Chat_screen/args/ChatScreenArgs.dart';
import 'package:berrytalk/screens/Chat_screen/bloc/chat_screen_bloc.dart'
    hide BackPressActionEvent;
import 'package:berrytalk/screens/Chat_screen/ui/chat_screen.dart';
import 'package:berrytalk/screens/ComigSoon_screen/ComingSoon/UnderDevelopmentScreen.dart';
import 'package:berrytalk/screens/Cust_Profile/bloc/customer_profile_bloc.dart'
    hide BackPressActionEvent;
import 'package:berrytalk/screens/Cust_Profile/ui/customer_profile.dart';
import 'package:berrytalk/screens/Home_screen/bloc/home_screen_bloc.dart';
import 'package:berrytalk/screens/Home_screen/ui/Home_screen.dart';
import 'package:berrytalk/screens/Login_Screen/bloc/login_bloc.dart'
    hide BackPressActionEvent;
import 'package:berrytalk/screens/Login_Screen/ui/Login_screen.dart';
import 'package:berrytalk/screens/Settings/bloc/settings_bloc.dart'
    hide BackPressActionEvent;
import 'package:berrytalk/screens/Settings/ui/settings.dart';
import 'package:berrytalk/screens/Team_chat_screen/bloc/team_chat_bloc.dart'
    hide BackPressActionEvent;
import 'package:berrytalk/screens/Team_chat_screen/ui/team_chat_screen.dart';
import 'package:berrytalk/screens/Team_list_screen/bloc/team_bloc.dart'
    hide BackPressActionEvent;
import 'package:berrytalk/screens/Team_list_screen/ui/team_screen.dart';
import 'package:berrytalk/services/theme/app_theme_cubit.dart';
import 'package:berrytalk/services/storage/SharedPrefrences.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';

import 'network/ApiService.dart';

String initialRoute = LOGIN_ROUTE;
ThemeMode initialThemeMode = ThemeMode.light;

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  bool isLogged = await SharedPrefData.getIsUserLogin() ?? false;
  bool isTokenExpired = await SharedPrefData.isTokenExpired();

  if (isLogged && !isTokenExpired) {
    initialRoute = HOME_ROUTE;
  } else {
    initialRoute = LOGIN_ROUTE;
  }

  initialThemeMode = await AppThemeCubit.loadSavedTheme();

  // Real local-notification provider (swap for the custom push SDK later).
  final pushService = LocalPushNotificationService();
  await pushService.initialize();
  WebSocketService().setNotificationService(pushService);

  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AppThemeCubit>(
              create: (context) => AppThemeCubit(initialThemeMode),
            ),
            BlocProvider<NavigationBloc>(create: (context) => NavigationBloc()),
            BlocProvider<SettingBloc>(create: (context) => SettingBloc()),
            BlocProvider<NetworkBloc>(
              create: (context) => NetworkBloc()..add(MonitorNetworkEvent()),
            ),
          ],
          child: const MyApp(),
        );
      },
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppThemeCubit, ThemeMode>(  
      builder: (context, themeMode) {
        return MaterialApp.router(
          title: 'Berry Talks',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: AppThemeUtilities.lightTheme,
          darkTheme: AppThemeUtilities.darkTheme,
          routerConfig: _appRouter,
          locale: DevicePreview.locale(context),
          builder: (context, child) {
            final previewChild = DevicePreview.appBuilder(context, child);
            return AppNetworkWrapper(child: previewChild);
          },
        );
      },
    );
  }
}

final String LOGIN_ROUTE = '/login';
final String HOME_ROUTE = '/home';
final String NAVIGATION_ROUTE = '/navigation';
final String COMING_SOON_ROUTE = '/coming_soon';
final String TEAM_ROUTE = '/team';
final String SETTING_ROUTE = '/setting';
final String CHAT_ROUTE = '/chat';
final String TEAM_CHAT_ROUTE = '/team_chat';
final String CUST_PROFILE = '/customer_profile';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();
    

final GoRouter _appRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: initialRoute,
  debugLogDiagnostics: true,
  observers: [NavObserver()],
  routes: [
    //----------LOGIN SCREEN ROUTE----------//
    GoRoute(
      name: "login",
      path: LOGIN_ROUTE,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: BlocProvider<LoginBloc>(
            create: (context) => LoginBloc(),
            child: LoginScreen(),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeOutCirc).animate(animation),
              child: child,
            );
          },
        );
      },
    ),

    //----------COMING SOON SCREEN ROUTE----------//
    GoRoute(
      name: "coming_soon",
      path: COMING_SOON_ROUTE,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: UnderDevelopmentScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeOutCirc).animate(animation),
              child: child,
            );
          },
        );
      },
    ),

    // ---------- GLOBAL SHELL ROUTE ---------- //
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<HomeBloc>(create: (context) => HomeBloc()),
            BlocProvider<TeamBloc>(create: (context) => TeamBloc()),
          ],
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              final String location = state.matchedLocation;
              if (location == HOME_ROUTE) {
                context.read<HomeBloc>().add(BackPressActionEvent());
              } else {
                context.read<NavigationBloc>().add(TabChanged(0));
                context.go(HOME_ROUTE);
              }
            },
            child: Scaffold(
              body: child,
              bottomNavigationBar: const CustomBottomNavBar(),
            ),
          ),
        );
      },
      routes: [
        // ---------- HOME SCREEN ROUTE ---------- //
        GoRoute(
          name: "home",
          path: HOME_ROUTE,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: HomeScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: CurveTween(
                        curve: Curves.easeOutCirc,
                      ).animate(animation),
                      child: child,
                    );
                  },
            );
          },
        ),

        // ---------- TEAM SCREEN ROUTE ---------- //
        GoRoute(
          name: "team",
          path: TEAM_ROUTE,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: const TeamScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: CurveTween(
                        curve: Curves.easeOutCirc,
                      ).animate(animation),
                      child: child,
                    );
                  },
            );
          },
        ),

        // ---------- SETTING SCREEN ROUTE ---------- //
        GoRoute(
          name: "setting",
          path: SETTING_ROUTE,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: SettingScreen(onLogoutPressed: () {}),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: CurveTween(
                        curve: Curves.easeOutCirc,
                      ).animate(animation),
                      child: child,
                    );
                  },
            );
          },
        ),
      ],
    ),

    //----------CHAT SCREEN ROUTE----------//
    GoRoute(
      name: "chat",
      path: CHAT_ROUTE,
      pageBuilder: (BuildContext context, GoRouterState state) {
        ChatScreenArgs args = state.extra as ChatScreenArgs;
        return CustomTransitionPage(
          key: state.pageKey,
          child: BlocProvider<ChatBloc>(
            create: (context) => ChatBloc(),
            child: ChatScreen(
              name: args.contactItem.displayName,
              platform: args.contactItem.platform,
              chatScreenArgs: args,
            ),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeOutCirc).animate(animation),
              child: child,
            );
          },
        );
      },
    ),

    // ---------- TEAM CHAT SCREEN ROUTE ---------- //
    GoRoute(
      name: "team_chat",
      path: TEAM_CHAT_ROUTE,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final String name = extra["name"] ?? "Unknown Team";
        final DesigantionStatus desStatus =
            extra["desStatus"] ?? DesigantionStatus.agent;
            final String recipientAgentId = extra["recipientAgentId"] ?? "";

        return CustomTransitionPage(
          key: state.pageKey,
          child: BlocProvider<TeamChatBloc>(
            create: (context) => TeamChatBloc(),

            child: TeamChatScreen(name: name, desStatus: desStatus,recipientAgentId: recipientAgentId,),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeOutCirc).animate(animation),
              child: child,
            );
          },
        );
      },
    ),
    //----------CUSTOMER SCREEN ROUTE----------//
    GoRoute(
      name: "customer_profile",
      path: CUST_PROFILE,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final Map<String, String> args = {};
        if (state.extra is Map) {
          (state.extra as Map).forEach((key, value) {
            args[key.toString()] = value.toString();
          });
        }

        return CustomTransitionPage(
          key: state.pageKey,
          child: BlocProvider<CustomerProfileBloc>(
            create: (context) => CustomerProfileBloc(),
            child: CustomerProfileScreen(
              number: args['number'] ?? '',
              companyPublicId: args['companyPublicId'] ?? '',
              agentId: args['agentId'] ?? '',
              channelId: args['channelId'] ?? '',
            ),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeOutCirc).animate(animation),
              child: child,
            );
          },
        );
      },
    ),
  ],
);

class NavObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    if (kDebugMode) {
      print("PUSH: ${route.settings.name ?? route.settings}");
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (kDebugMode) {
      //print("POP: ${route.settings.name ?? route.settings}");
    }
  }
}
