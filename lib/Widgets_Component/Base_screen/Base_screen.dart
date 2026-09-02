import 'dart:async';
import 'dart:io';

import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../Buttons/RippleButton.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class BaseScreen extends StatefulWidget {
  final VoidCallback onPanUpdate;
  final VoidCallback onWillPop;
  final bool isScrollable;
  final bool isFullScreen;
  final String routeName;
  final int screenIndex;
  final Widget child;
  final Color? backgroundColor;
  final AppBar? appBar;
  final bool? isSwipeRefresh;
  final Widget? bottomNavigationBar;
  final Future<void> Function(Completer<void>)? onSwipeRefresh;

  /// When true (default), any tap on the screen dismisses the soft keyboard.
  /// Chat keeps this false so Send / composer taps don't close the keyboard.
  final bool dismissKeyboardOnTap;

  const BaseScreen({
    super.key,
    required this.onPanUpdate,
    required this.onWillPop,
    required this.isScrollable,
    required this.isFullScreen,
    required this.routeName,
    required this.screenIndex,
    required this.child,
    this.backgroundColor,
    this.appBar,
    this.isSwipeRefresh = false,
    this.onSwipeRefresh,
    this.bottomNavigationBar,
    this.dismissKeyboardOnTap = true,
  });

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  static const double edgeWidth = 20;
  static const double minSwipeDistance = 60;

  double _dragDx = 0;
  bool _gestureHandled = false;
  bool isBackEnable = true;

  Future<void> _initializeAsyncData() async {
    // final isThreeButton = await NavigationModeService.isThreeButtonNavigation();
    // print("isThreeButtonSystemUI: ${isThreeButton}");
  }

  @override
  void initState() {
    _initializeAsyncData();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge, 
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      behavior: HitTestBehavior.translucent,
      gestures: {
        // Only claim taps when we actually want to dismiss the keyboard.
        // Otherwise the arena steals the first tap from buttons (e.g. Send).
        if (widget.dismissKeyboardOnTap)
          TapGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                () => TapGestureRecognizer(),
                (TapGestureRecognizer recognizer) {
                  recognizer.onTap = () {
                    FocusManager.instance.primaryFocus?.unfocus();
                  };
                },
              ),

        HorizontalDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<
              HorizontalDragGestureRecognizer
            >(() => HorizontalDragGestureRecognizer(), (
              HorizontalDragGestureRecognizer recognizer,
            ) {
              recognizer
                ..onStart = (details) {
                  _gestureHandled = false;
                  _dragDx = 0;

                  // ✅ HARD EDGE CHECK (UIKit-safe)
                  if (details.localPosition.dx > edgeWidth) {
                    recognizer.dispose();
                  }
                }
                ..onUpdate = (details) {
                  if (_gestureHandled) return;

                  _dragDx += details.primaryDelta ?? 0;

                  //print("BACKK GestureDetector ${Platform.isIOS && !Platform.isAndroid}, Value: ${details.delta.dx}, _dragDx: ${_dragDx}, minSwipeDistance: ${minSwipeDistance}");
                  if (Platform.isIOS && _dragDx > minSwipeDistance) {
                    _gestureHandled = true;
                    widget.onPanUpdate.call(); // GoRouter pop
                  }
                };
            }),
      },

      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (_, __) async {
          final routeName = GoRouterState.of(context).name;
          if (mounted && isBackEnable) {
            isBackEnable = false;
            widget.onWillPop.call();
            await Future.delayed(const Duration(seconds: 1));
            //print("BackPressActionState =======>> ${mounted}, ${routeName} ${mounted && routeName == "ips_account"}");
            isBackEnable = true;
          }
        },
        child: _buildBody(),
      ),
     
    );
  }

  Widget _buildBody() {
    if (widget.isFullScreen) {
      return Scaffold(
        backgroundColor:
            widget.backgroundColor ?? AppThemeUtilities.appScreenBGColor,
        appBar: appBar(),
        bottomNavigationBar: widget.bottomNavigationBar,
        body: SafeArea(
          top: false,
          child: widget.isScrollable
              ? SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: widget.child,
                )
              : widget.isSwipeRefresh!
              ? RefreshIndicator(
                  color: AppThemeUtilities.HexToColor("#00599B"),
                  onRefresh: () async {
                    if (widget.onSwipeRefresh != null) {
                      final completer = Completer<void>();
                      widget.onSwipeRefresh!.call(completer);
                      return completer.future;
                    }
                  },
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: widget.child,
                  ),
                )
              : widget.child,
        ),
      );
    }

    return SafeArea(
      top: false,
      // bottom: false,
      child: Scaffold(
        backgroundColor:
            widget.backgroundColor ?? AppThemeUtilities.appScreenBGColor,
        appBar: appBar(),
        bottomNavigationBar: widget.bottomNavigationBar,
        body: widget.isScrollable
            ? SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: widget.child,
              )
            : widget.isSwipeRefresh!
            ? RefreshIndicator(
                color: AppThemeUtilities.HexToColor("#00599B"),
                onRefresh: () async {
                  if (widget.onSwipeRefresh != null) {
                    final completer = Completer<void>();
                    widget.onSwipeRefresh!.call(completer);
                    return completer.future;
                  }
                },
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: widget.child,
                ),
              )
            : widget.child,
      ),
    );
  }

  AppBar? appBar() {
    if (widget.appBar != null) {
      return widget.appBar;
    } else {
      // ✅ WEB SAFE CHECK
      if (!kIsWeb &&
          (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
        if (context.canPop()) {
          return AppBar(
            backgroundColor: AppThemeUtilities.appScreenBGColor,
            leading: RippleButton(
              onPressed: () {
                widget.onWillPop.call();
              },
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppThemeUtilities.blackColor,
              ),
            ),
          );
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
  }
}
