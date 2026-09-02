import 'package:berrytalks/Widgets_Component/Utils/AppConstants.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppImages.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OrderProductRow {
  final String title;
  final int quantity;
  final double price;
  const OrderProductRow({
    required this.title,
    required this.quantity,
    required this.price,
  });
}

class OrderCard extends StatelessWidget {
  final String orderId;
  final String date;
  final String status;
  final List<OrderProductRow> items;
  final double total;

  const OrderCard({
    super.key,
    required this.orderId,
    required this.date,
    required this.status,
    required this.items,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
        final backgroundColor = AppThemeUtilities.getCardColor(context);

    // final currentBgColor = Theme.of(context).scaffoldBackgroundColor;
        final Color borderColor = AppThemeUtilities.getAppBarShadowColor(context);
    final Color statusColor = AppThemeUtilities.getStatusColor(context);
    final Color textColor = AppThemeUtilities.getTextColor(context);
    final Color buttonColor = AppThemeUtilities.getButtonColor(context);

    return Container(
      margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 16),

      padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #$orderId',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: AppConstants.FontFamily_SFPro,
                  fontWeight: AppConstants.FontWeight_Medium,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                  left: 10,
                  top: 6,
                  right: 10,
                  bottom: 6,
                ),
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontFamily: AppConstants.FontFamily_SFPro,
                    fontSize: 13,
                    fontWeight: AppConstants.FontWeight_Medium,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
            padding: const EdgeInsets.only(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
            ),
          ),
          Row(
            children: [
              SvgPicture.asset(AppImages.calender, width: 13, height: 13),
              Container(
                margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
                padding: const EdgeInsets.only(
                  left: 10,
                  top: 0,
                  right: 0,
                  bottom: 0,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  color: AppThemeUtilities.HexToColor("#707070"),
                  fontFamily: AppConstants.FontFamily_SFPro,
                  fontWeight: AppConstants.FontWeight_Medium,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(left: 0, top: 10, right: 0, bottom: 10),
            padding: const EdgeInsets.only(
              left: 10,
              top: 0,
              right: 0,
              bottom: 0,
            ),
          ),

          ...items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(
                    left: 0,
                    top: 0,
                    right: 0,
                    bottom: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.title}  x  ${item.quantity}',
                        style: TextStyle(
                          fontFamily: AppConstants.FontFamily_SFPro,
                          fontWeight: AppConstants.FontWeight_Regular,
                          color: AppThemeUtilities.HexToColor("#707070"),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: AppConstants.FontFamily_SFPro,
                          fontWeight: AppConstants.FontWeight_Medium,
                          color: AppThemeUtilities.HexToColor("#000000"),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              ,

          Container(
            margin: EdgeInsets.only(left: 0, top: 10, right: 0, bottom: 10),
            padding: const EdgeInsets.only(
              left: 10,
              top: 0,
              right: 0,
              bottom: 0,
            ),
            color: borderColor,
            height: 1,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'USD Payment',
                style: TextStyle(
                  fontFamily: AppConstants.FontFamily_SFPro,
                  fontWeight: AppConstants.FontWeight_Regular,
                  color: textColor,
                  fontSize: 14,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: AppConstants.FontFamily_SFPro,
                  fontWeight: AppConstants.FontWeight_Medium,
                  color:textColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(left: 0, top: 16, right: 0, bottom: 0),
            padding: const EdgeInsets.only(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
            ),
          ),

          Container(
            margin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
            padding: const EdgeInsets.only(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
            ),
            width: double.infinity,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.only(
                  left: 8,
                  top: 8,
                  right: 8,
                  bottom: 8,
                ),
              ),
              child: Text(
                'View in Shopify',
                style: TextStyle(
                  fontFamily: AppConstants.FontFamily_SFPro,
                  color: textColor,
                  fontWeight: AppConstants.FontWeight_Medium,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
