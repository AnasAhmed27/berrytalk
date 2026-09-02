
import 'package:berrytalks/Widgets_Component/Base_screen/Base_screen.dart';
import 'package:berrytalks/Widgets_Component/PermissionDialog/PermissionDeniedDialog.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppConstants.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppUitilities.dart';
import 'package:berrytalks/Widgets_Component/utils/AppImages.dart';
import 'package:berrytalks/main.dart';
import 'package:berrytalks/screens/Login_Screen/bloc/login_bloc.dart';
import 'package:berrytalks/screens/Login_Screen/widget/Login_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final bool isScrollable = false;
  final isFullScreen = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<LoginBloc>().add(LoginInitialEvent());

    if(kDebugMode){
      _emailController.text = "hamza.hafeez@convexinteractive.com";
      // _emailController.text = "hamzahafeez93@gmail.com";
      _passwordController.text = "Hamza@123";
      // _emailController.text = "agentkedemo067@gmail.com";
      // _passwordController.text = "Agent@321";
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    AppUtilities.hideKeyboard(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = AppThemeUtilities.getCardColor(context);

    final Color cardColor = AppThemeUtilities.getCardColor(context);
    final Color textColor = AppThemeUtilities.getTextColor(context);
    final loginBloc = BlocProvider.of<LoginBloc>(context, listen: false);

    return BlocConsumer<LoginBloc, LoginState>(
      bloc: loginBloc,
      listenWhen: (previous, current) => current is LoginActionState,
      buildWhen: (previous, current) => current is! LoginActionState,

      listener: (context, state)  {
        if (state is LoadingState) {
          AppUtilities.showLoadingDialog(context);
        }
        else if (state is LoadingSuccessState) {
          print("LOADING SUCCESS: DISMISSING DIALOG");
          if (context.canPop()) {
            context.pop();
          }
        }
       else if (state is SubmitDataSuccessState) {
          print("LOGIN TOTALLY SUCCESSFUL -> NAVIGATING TO HOME");
         
          
          AppUtilities.showSuccessSnackBar(
            navigatorKey.currentContext!,
            title: "Success",
            message: "Login successful",
          );

          context.go(HOME_ROUTE); 
        }

        if (state is LoadingErrorState) {
          if (context.canPop()) {
            context.pop();
          }
          print("LOGIN FAILED");
       
          AppUtilities.showErrorSnackBar(
      navigatorKey.currentContext!,
      title: state.errorTitle.isNotEmpty ? state.errorTitle : "Error",
      message: state.errorMsg.isNotEmpty
          ? state.errorMsg
          : "A gateway error occurred. Please try again shortly.",
    );
        }
        if (state is BackPressActionState) {
          if (context.canPop()) {
            context.pop();
          } else if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        }
       
        if (state is PermissionDeniedActionState) {
          if (context.canPop()) {
            context.pop(); 
          }
          print("ACCESS DENIED: TRIGGERING CUSTOM DIALOG");
          
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return PermissionDeniedDialog(
                title: state.errorTitle, 
                message: state.errorMsg, 
              );
            },
          );
        }
      },

      builder: (BuildContext context, LoginState state) {
        return PopScope(
          canPop: false, 
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            print("Hardware Back Pressed on Login Screen");
            context.read<LoginBloc>().add(BackPressActionEvent());
          },
          child: BaseScreen(
            backgroundColor: backgroundColor,
            onPanUpdate: () {
              BlocProvider.of<LoginBloc>(context).add(BackPressActionEvent());
            },
            onWillPop: () {
              BlocProvider.of<LoginBloc>(context).add(BackPressActionEvent());
            },
            isScrollable: isScrollable,
            isFullScreen: isFullScreen,
            routeName: LOGIN_ROUTE,
            screenIndex: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: cardColor,
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.only(
                    left: 32,
                    top: 0,
                    right: 32,
                    bottom: 0,
                  ),
                  padding: const EdgeInsets.only(
                    left: 0,
                    top: 0,
                    right: 0,
                    bottom: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          left: 0,
                          top: 120,
                          right: 0,
                          bottom: 0,
                        ),
                        padding: const EdgeInsets.only(
                          left: 0,
                          top: 0,
                          right: 0,
                          bottom: 0,
                        ),
                        child: SvgPicture.asset(AppImages.appLogo, height: 70),
                      ),
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
                        child: Text(
                          "Berry Talks",
                          style: TextStyle(
                            fontFamily: AppConstants.FontFamily_SFPro,
                            fontWeight: AppConstants.FontWeight_Bold,
                            fontSize: 45,
                            color: textColor,
                          ),
                        ),
                      ),
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
                        child: Text(
                          "Agent Chat Platform",
                          style: TextStyle(
                            fontFamily: AppConstants.FontFamily_SFPro,
                            fontWeight: AppConstants.FontWeight_Regular,
                            fontSize: 17,
                            color: textColor,
                          ),
                        ),
                      ),

                      Container(
                        margin: EdgeInsets.only(
                          left: 0,
                          top: 15,
                          right: 0,
                          bottom: 15,
                        ),
                        padding: const EdgeInsets.only(
                          left: 0,
                          top: 0,
                          right: 0,
                          bottom: 0,
                        ),
                        child: LoginCredentialsCard(
                          emailController: _emailController,
                          passwordController: _passwordController,
                          onLoginPressed: () {
                            final String rawEmail = _emailController.text;
                            final String rawPassword = _passwordController.text;

                            if (rawEmail.isEmpty || rawPassword.isEmpty) {
                              AppUtilities.showErrorSnackBar(
                                context,
                                title: "Required Fields",
                                message: "Please fill in all input credentials.",
                              );
                              return;
                            }

                            if (!AppUtilities.isEmailValid(rawEmail)) {
                              AppUtilities.showErrorSnackBar(
                                context,
                                title: "Invalid Email Structure",
                                message: "Please enter a valid agent email address.",
                              );
                              return;
                            }

                            // if (!AppUtilities.isPasswordValid(rawPassword)) {
                            //   AppUtilities.showErrorSnackBar(
                            //     context,
                            //     title: "Weak Password",
                            //     message: "Must be 8+ characters with 1 Uppercase, 1 Number, and 1 Special character.",
                            //   );
                            //   return;
                            // }
                            AppUtilities.hideKeyboard(context);
                            context.read<LoginBloc>().add(
                              LoginSubmitEvent(rawEmail.trim(), rawPassword),
                            );
                            // print("LOGIN BUTTON CLICKED");

                            // context.read<LoginBloc>().add(
                            //   LoginSubmitEvent(
                            //     _emailController.text,
                            //     _passwordController.text,
                            //   ),
                            // );
                            
                          },
                        ),
                      ),

                      Container(
                        margin: EdgeInsets.only(
                          left: 0,
                          top: 15,
                          right: 0,
                          bottom: 15,
                        ),
                        padding: const EdgeInsets.only(
                          left: 0,
                          top: 0,
                          right: 0,
                          bottom: 0,
                        ),
                        child: Text(
                          "By signing in, you agree to our Terms of Service",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: AppConstants.FontWeight_Regular,
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
