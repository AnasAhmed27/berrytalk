import 'package:berrytalks/Widgets_Component/Utils/AppConstants.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickRepliesBottomSheet extends StatelessWidget {
  final TextEditingController controller;

  const QuickRepliesBottomSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final Color currentBgColor = AppThemeUtilities.getCardColor(context); 
    final Color mainTextColor = AppThemeUtilities.getTextColor(context);
    final Color subTextColor = AppThemeUtilities.getTimeColor(context);
   final Color separatorColor = AppThemeUtilities.getAppBarShadowColor(context);
    final List<Map<String, String>> templates = [
      {
        "title": "Welcome Message",
        "body": "Hello! Thank you for contacting us. How can I help you today",
      },
      {
        "title": "Order Status",
        "body":
            "Let me check the status of your order. Could you Please provide your order number?",
      },
      {
        "title": "Shipping Info",
        "body":
            "Your order has been shipped and you should receive it within 3-5 business days. Here's your tracking...",
      },
      {
        "title": "Refund Policy",
        "body":
            "We offer a 30-day return policy. Would you like me to help you process a return or refund?",
      },
      {
        "title": "Thank You",
        "body":
            "Thank you for reaching out is there anything else I can help you with?",
      },
      {
        "title": "Welcome Message",
        "body": "Hello! Thank you for contacting us. How can I help you today",
      },
      {
        "title": "Order Status",
        "body":
            "Let me check the status of your order. Could you Please provide your order number?",
      },
      {
        "title": "Shipping Info",
        "body":
            "Your order has been shipped and you should receive it within 3-5 business days. Here's your tracking...",
      },
      {
        "title": "Refund Policy",
        "body":
            "We offer a 30-day return policy. Would you like me to help you process a return or refund?",
      },
      {
        "title": "Thank You",
        "body":
            "Thank you for reaching out is there anything else I can help you with?",
      },
    ];

    final ScrollController scrollController = ScrollController();

    return Container(
      margin: const EdgeInsets.only(left: 15, top: 15, right: 15, bottom: 85),
      decoration: BoxDecoration(
        color: currentBgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              top: 20,
              right: 20,
              bottom: 4,
            ),
            child: Text(
              "Quick Replies",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: AppConstants.FontWeight_Bold,
                color: mainTextColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              top: 0,
              right: 20,
              bottom: 12,
            ),
            child: Text(
              "Select a template to insert",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: subTextColor,
              ),
            ),
          ),
         // const Divider(height: 1, thickness: 1),
         Divider(height: 1, thickness: 0.5, color: separatorColor.withOpacity(0.2)),
          Container(
            constraints: const BoxConstraints(
              maxHeight:
                  450, 
            ),
            child: Scrollbar(
              controller: scrollController,
              thumbVisibility:
                  true,
              thickness: 6, 
              radius: const Radius.circular(10),
              child: ListView.separated(
                controller: scrollController,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const ScrollPhysics(), 
                itemCount: templates.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, thickness: 0.5, color: separatorColor.withOpacity(0.2)),
                itemBuilder: (context, index) {
                  final item = templates[index];
                  return InkWell(
                    onTap: () {
                      controller.text = item["body"] ?? "";
                      controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.text.length),
                      );
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        top: 14,
                        right: 20,
                        bottom: 14,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item["title"]!,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: AppConstants.FontWeight_Semibold,
                              color: mainTextColor,
                            ),
                          ),
                          Container(margin: const EdgeInsets.only(top: 4)),
                          Text(
                            item["body"]!,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: subTextColor,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 8),
          ),
        ],
      ),
    );
  }
}
