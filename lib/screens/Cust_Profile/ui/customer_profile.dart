import 'package:berrytalks/Widgets_Component/Base_screen/Base_screen.dart';
import 'package:berrytalks/Widgets_Component/BottomNavBar/ui/BottomNavBar.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppConstants.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppUitilities.dart';
import 'package:berrytalks/main.dart';
import 'package:berrytalks/screens/Cust_Profile/bloc/customer_profile_bloc.dart';
import 'package:berrytalks/screens/Cust_Profile/widget/contact_info_card.dart';
import 'package:berrytalks/screens/Cust_Profile/widget/proflie_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerProfileScreen extends StatefulWidget {
  final String number;
  final String companyPublicId;
  final String agentId;
  final String channelId;

  const CustomerProfileScreen({
    super.key,
    required this.number,
    required this.companyPublicId,
    required this.agentId,
    required this.channelId,
  });

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final bool isScrollable = true;
  final isFullScreen = true;
  bool isBackEnable = true;

  @override
  void initState() {
    super.initState();
    context.read<CustomerProfileBloc>().add(
      LoadCustomerProfileEvent(
        number: widget.number,
        companyPublicId: widget.companyPublicId,
        agentId: widget.agentId,
        channelId: widget.channelId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = AppThemeUtilities.getAppBarShadowColor(context);

    final Color mainTextColor = AppThemeUtilities.getTextColor(context);
    final Color cardColor = AppThemeUtilities.getCardColor(context);
    final Color textColor = AppThemeUtilities.getTextColor(context);
    final backgroundColor = AppThemeUtilities.getCardColor(context);

    return BlocConsumer<CustomerProfileBloc, CustomerProfileState>(
      listenWhen: (previous, current) => current is CustomerProfileActionState,
      buildWhen: (previous, current) => current is! CustomerProfileActionState,
      listener: (context, state) {
        if (state is LoadingState) {
          AppUtilities.showLoadingDialog(context);
        } else if (state is LoadingSuccessState) {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        } else if (state is BackPressActionState) {
          if (GoRouter.of(context).canPop()) {
            context.pop();
          }
        }
      },
      builder: (BuildContext context, CustomerProfileState state) {
        switch (state.runtimeType) {
          case CustomerProfileInitialState:
            return BaseScreen(
              onPanUpdate: () {
                BlocProvider.of<CustomerProfileBloc>(
                  context,
                ).add(BackPressActionEvent());
              },

              onWillPop: () {
                BlocProvider.of<CustomerProfileBloc>(
                  context,
                ).add(BackPressActionEvent());
              },
              isScrollable: isScrollable,
              isFullScreen: isFullScreen,
              routeName: CUST_PROFILE,
              appBar: AppBar(
                toolbarHeight: 66,
                leadingWidth: 40,
                foregroundColor: mainTextColor,
                backgroundColor: backgroundColor,
                surfaceTintColor: Colors.transparent,
                bottomOpacity: 0.1,
                elevation: 1,
                shadowColor: cardColor,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).maybePop();
                    },
                    child: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Customer Profile",
                      style: GoogleFonts.poppins(
                        fontWeight: AppConstants.FontWeight_Semibold,
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              screenIndex: 5,
              bottomNavigationBar: const CustomBottomNavBar(),
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: cardColor,
                margin: EdgeInsets.only(left: 21, top: 0, right: 21, bottom: 0),
                padding: const EdgeInsets.only(
                  left: 0,
                  top: 0,
                  right: 0,
                  bottom: 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      child: ProfileHeader(name: 'Loading...', tags: []),
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
                      child: ContactInfoCard(
                        email: 'Loading...',
                        phone: 'Loading...',
                        location: 'Loading...',
                      ),
                    ),

                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(
                        left: 0,
                        top: 0,
                        right: 0,
                        bottom: 16,
                      ),
                      padding: const EdgeInsets.only(
                        left: 0,
                        top: 0,
                        right: 0,
                        bottom: 0,
                      ),
                      // child: OutlinedButton(
                      //   onPressed: () {},
                      //   style: OutlinedButton.styleFrom(
                      //     side: const BorderSide(color: Color(0xFF2EAD65)),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //     ),
                      //     padding: const EdgeInsets.symmetric(vertical: 14),
                      //   ),
                      //   child: Text(
                      //     'Customer at Shopify',
                      //     style: GoogleFonts.poppins(
                      //       color: const Color(0xFF2EAD65),
                      //       fontWeight: FontWeight.w500,
                      //     ),
                      //   ),
                      // ),
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
                      // child: TabBarSwitch(activeTab: activeTab),
                    ),
                  ],
                ),
              ),
            );
          case CustomerProfileDataState:
            final profiledata = state as CustomerProfileDataState;
            final contact = profiledata.contactData;
            final company = profiledata.companyData;
            final bool isDataLoading = profiledata.isLoading;
            return BaseScreen(
              onPanUpdate: () {
                BlocProvider.of<CustomerProfileBloc>(
                  context,
                ).add(BackPressActionEvent());
              },

              onWillPop: () {
                BlocProvider.of<CustomerProfileBloc>(
                  context,
                ).add(BackPressActionEvent());
              },
              isScrollable: isScrollable,
              isFullScreen: isFullScreen,
              routeName: CUST_PROFILE,
              appBar: AppBar(
                toolbarHeight: 66,
                leadingWidth: 40,
                foregroundColor: mainTextColor,
                backgroundColor: backgroundColor,
                surfaceTintColor: Colors.transparent,
                bottomOpacity: 0.1,
                elevation: 1,
                shadowColor: cardColor,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).maybePop();
                    },
                    child: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Customer Profile",
                      style: GoogleFonts.poppins(
                        fontWeight: AppConstants.FontWeight_Semibold,
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              screenIndex: 5,
              bottomNavigationBar: const CustomBottomNavBar(),
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: cardColor,
                margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
                padding: const EdgeInsets.only(
                  left: 0,
                  top: 0,
                  right: 0,
                  bottom: 200,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      // child: ProfileHeader(
                      //   name: profiledata.contactData.fullName.,
                      //   tags: ['VIP', 'Frequent Buyer'],
                      // ),
                      child: ProfileHeader(
                        name:
                            contact?.fullName ??
                            (isDataLoading
                                ? 'Loading...'
                                : 'No Name Available'),
                        tags:
                            contact?.contactTags
                                ?.map((t) => t.tagName ?? 'Loading...')
                                .where((name) => name.isNotEmpty)
                                .toList() ??
                            [],
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(
                        left: 21,
                        top: 10,
                        right: 21,
                        bottom: 0,
                      ),
                      padding: const EdgeInsets.only(
                        left: 0,
                        top: 0,
                        right: 0,
                        bottom: 0,
                      ),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: borderColor,
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(
                        left: 21,
                        top: 10,
                        right: 21,
                        bottom: 0,
                      ),
                      padding: const EdgeInsets.only(
                        left: 0,
                        top: 0,
                        right: 0,
                        bottom: 0,
                      ),
                      child:  ContactInfoCard(
      // <-- 2. UI fields ko company data ke sath replace kiya (Fallback lagaya contact par agar company null ho)
      email: isDataLoading
          ? 'Loading...'
          : (company?.email ?? contact?.email ?? 'N/A'),
      phone: isDataLoading
          ? 'Loading...'
          : (company?.businessNumber ?? company?.whatsappNumber ?? contact?.mobileNumber ?? 'N/A'),
      location: isDataLoading
          ? 'Loading...'
          : (company?.domain ?? contact?.address ?? 'No Address Specified'),
    ),
                    ),

                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(
                        left: 21,
                        top: 0,
                        right: 21,
                        bottom: 16,
                      ),
                      padding: const EdgeInsets.only(
                        left: 0,
                        top: 0,
                        right: 0,
                        bottom: 0,
                      ),
                      // child: OutlinedButton(
                      //   onPressed: () {},
                      //   style: OutlinedButton.styleFrom(
                      //     backgroundColor: backgroundColor,

                      //     side: BorderSide(color: borderColor),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //     ),
                      //     padding: const EdgeInsets.symmetric(vertical: 14),
                      //   ),
                      //   child: Text(
                      //     'Customer at Shopify',
                      //     style: TextStyle(
                      //       fontFamily: AppConstants.FontFamily_SFPro,
                      //       color: AppThemeUtilities.HexToColor("#15803D"),
                      //       fontWeight: AppConstants.FontWeight_MediumItalic,
                      //       fontSize: 16,
                      //     ),
                      //   ),
                      // ),
                    ),

                    Container(
                      margin: EdgeInsets.only(
                        left: 21,
                        top: 0,
                        right: 21,
                        bottom: 0,
                      ),
                      padding: const EdgeInsets.only(
                        left: 0,
                        top: 0,
                        right: 0,
                        bottom: 0,
                      ),
                      // child: TabBarSwitch(
                      //   activeTab: profiledata.activeTabIndex,
                      // ),
                    ),

                    // Container(
                    //   margin: EdgeInsets.only(
                    //     left: 21,
                    //     top: 10,
                    //     right: 21,
                    //     bottom: 0,
                    //   ),
                    //   padding: const EdgeInsets.only(
                    //     left: 0,
                    //     top: 0,
                    //     right: 0,
                    //     bottom: 0,
                    //   ),
                    //   child: profiledata.activeTabIndex == 1
                    //       ? Column(
                    //           children: [
                    //             const OrderCard(
                    //               orderId: '1234',
                    //               date: 'Jan 15, 2024',
                    //               status: 'fulfilled',
                    //               items: [
                    //                 OrderProductRow(
                    //                   title: 'Wireless Headphones',
                    //                   quantity: 1,
                    //                   price: 199.99,
                    //                 ),
                    //                 OrderProductRow(
                    //                   title: 'Phone Case',
                    //                   quantity: 2,
                    //                   price: 17.25,
                    //                 ),
                    //               ],
                    //               total: 234.50,
                    //             ),
                    //             const OrderCard(
                    //               orderId: '1235',
                    //               date: 'Jan 15, 2024',
                    //               status: 'pending',
                    //               items: [
                    //                 OrderProductRow(
                    //                   title: 'Smart Watch',
                    //                   quantity: 1,
                    //                   price: 199.99,
                    //                 ),
                    //                 OrderProductRow(
                    //                   title: 'Phone Case',
                    //                   quantity: 2,
                    //                   price: 17.25,
                    //                 ),
                    //               ],
                    //               total: 234.50,
                    //             ),
                    //           ],
                    //         )
                    //       : Container(
                    //           width: double.infinity,
                    //           margin: EdgeInsets.only(
                    //             left: 21,
                    //             top: 0,
                    //             right: 21,
                    //             bottom: 0,
                    //           ),
                    //           padding: const EdgeInsets.only(
                    //             left: 24,
                    //             top: 24,
                    //             right: 24,
                    //             bottom: 24,
                    //           ),
                    //           decoration: BoxDecoration(
                    //             color: backgroundColor,
                    //             borderRadius: BorderRadius.circular(12),
                    //             border: Border.all(color: borderColor),
                    //           ),
                    //           child: Center(
                    //             child: Text(
                    //               'Overview Module Content',
                    //               style: GoogleFonts.poppins(color: textColor),
                    //             ),
                    //           ),
                    //         ),
                    // ),
                  ],
                ),
              ),
            );
          default:
            return Container();
        }
      },
    );
  }
}
