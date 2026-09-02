import 'package:berrytalks/network/internet/bloc/network_bloc.dart';
import 'package:berrytalks/network/internet/ui/noInternetScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppNetworkWrapper extends StatelessWidget {
  final Widget child;
  const AppNetworkWrapper({super.key, required this.child});

  @override
  // Widget build(BuildContext context) {
  //   final double topPadding = MediaQuery.of(context).padding.top;

  //   return Scaffold(
  //     body: BlocConsumer<NetworkBloc, NetworkState>(
  //       listener: (context, state) {
  //         if (state is NetworkConnectedState && state.isRestored) {
  //           ScaffoldMessenger.of(context).clearSnackBars();
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Row(
  //                 children: [
  //                   Icon(
  //                     Icons.check_circle_outline_rounded,
  //                     color: Colors.white,
  //                     size: 18,
  //                   ),
  //                   Container(
  //                     margin: const EdgeInsets.only(
  //                       left: 10,
  //                       top: 0,
  //                       right: 0,
  //                       bottom: 0,
  //                     ),
  //                     padding: const EdgeInsets.only(
  //                       left: 0,
  //                       top: 0,
  //                       right: 0,
  //                       bottom: 0,
  //                     ),
  //                   ),
  //                   Text(
  //                     "Network Restored! Connection is stable.",
  //                     style: TextStyle(
  //                       color: Colors.white,
  //                       fontWeight: FontWeight.w600,
  //                       fontSize: 13,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               backgroundColor: const Color(0xFF16A249),
  //               behavior: SnackBarBehavior.floating,
  //               margin: const EdgeInsets.all(16),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               duration: const Duration(seconds: 3),
  //             ),
  //           );
  //         }
  //       },
  //       builder: (context, state) {
  //         if (state is NetworkDisconnectedState) {
  //           return NoInternetScreen(
  //             onRetry: () {
  //               ScaffoldMessenger.of(context).clearSnackBars();
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(
  //                   content: const Text(
  //                     "Checking connection...",
  //                     style: TextStyle(
  //                       color: Colors.white,
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   ),
  //                   backgroundColor: Colors.black.withOpacity(0.9),
  //                   behavior: SnackBarBehavior.floating,
  //                   margin: const EdgeInsets.all(16),
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                   duration: const Duration(milliseconds: 1500),
  //                 ),
  //               );
  //               context.read<NetworkBloc>().add(MonitorNetworkEvent());
  //             },
  //           );
  //         }

  //         final bool isWeak = state is NetworkWeakState;

  //         return Stack(
  //           children: [
  //             child,
  //             AnimatedPositioned(
  //               duration: const Duration(milliseconds: 400),
  //               curve: Curves.fastOutSlowIn,
  //               top: isWeak ? topPadding : -60,
  //               left: 0,
  //               right: 0,
  //               child: AnimatedOpacity(
  //                 duration: const Duration(milliseconds: 300),
  //                 opacity: isWeak ? 1.0 : 0.0,
  //                 child: Container(
  //                   width: double.infinity,
  //                   decoration: BoxDecoration(
  //                     color: Colors.amber.shade700,
  //                     boxShadow: [
  //                       BoxShadow(
  //                         color: Colors.black.withOpacity(0.15),
  //                         blurRadius: 10,
  //                         offset: const Offset(0, 4),
  //                       ),
  //                     ],
  //                   ),
  //                   child: Container(
  //                     padding: const EdgeInsets.symmetric(
  //                       vertical: 10,
  //                       horizontal: 20,
  //                     ),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       crossAxisAlignment: CrossAxisAlignment.center,
  //                       children: [
  //                         Container(
  //                           margin: const EdgeInsets.only(right: 10),
  //                           child: const Icon(
  //                             Icons.warning_amber_rounded,
  //                             size: 16,
  //                             color: Colors.white,
  //                           ),
  //                         ),
  //                         Expanded(
  //                           child: Container(
  //                             child: const Text(
  //                               "Weak network connection detected...",
  //                               style: TextStyle(
  //                                 color: Colors.white,
  //                                 fontSize: 12,
  //                                 fontWeight: FontWeight.w600,
  //                                 letterSpacing: 0.2,
  //                               ),
  //                               overflow: TextOverflow.ellipsis,
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  // }
  @override
Widget build(BuildContext context) {
  final double topPadding = MediaQuery.of(context).padding.top;

  return Scaffold(
    body: BlocConsumer<NetworkBloc, NetworkState>(
      listener: (context, state) {
        if (state is NetworkConnectedState && state.isRestored) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Network Restored! Connection is stable.",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF16A249),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        final bool isDisconnected = state is NetworkDisconnectedState;
        final bool isWeak = state is NetworkWeakState;

        // FIX: child ko kabhi replace mat karo — sirf uske upar overlay lagao
        return Stack(
          children: [
            // Child hamesha alive — GoRouter ka state preserve hota hai
            child,

            // Net off hone par puri screen cover karo
            if (isDisconnected)
              Positioned.fill(
                child: NoInternetScreen(
                  onRetry: () {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          "Checking connection...",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: Colors.black.withOpacity(0.9),
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        duration: const Duration(milliseconds: 1500),
                      ),
                    );
                    context.read<NetworkBloc>().add(MonitorNetworkEvent());
                  },
                ),
              ),

            // Weak net banner — upar se slide karo
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.fastOutSlowIn,
              top: isWeak ? topPadding : -60,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isWeak ? 1.0 : 0.0,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.amber.shade700,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Weak network connection detected...",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
}
