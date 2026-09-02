import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UnderDevelopmentScreen extends StatelessWidget {
  const UnderDevelopmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // NCCPL Brand Colors
    // const Color nccplBlue = Color(0xFF003366);
    Color berryBlue = AppThemeUtilities.appSecondaryBGColor;
    Color berryGreen = AppThemeUtilities.appPrimaryBGColor;
   // const Color nccplSecondary = Color(0xFF048be4);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.blue.shade50],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Interactive Icon/Image Area
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: berryBlue.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.construction_rounded,
                  size: 100,
                  color: berryBlue,
                ),
              ),
             Container(
                margin: const EdgeInsets.only(
                  left: 0,
                  top: 40,
                  right: 0,
                  bottom: 0,
                ),
                padding: const EdgeInsets.only(
                  left: 0,
                  top: 0,
                  right: 0,
                  bottom: 0,
                ),
              ),

              // Title
              Text(
                'Coming Soon',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: berryBlue,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  left: 0,
                  top: 16,
                  right: 0,
                  bottom: 0,
                ),
                padding: const EdgeInsets.only(
                  left: 0,
                  top: 0,
                  right: 0,
                  bottom: 0,
                ),
              ),

              // Message
              const Text(
                'Sorry for the inconvenience.\nThis Application Module is still in the Development Phase.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
             Container(
                margin: const EdgeInsets.only(
                  left: 0,
                  top: 40,
                  right: 0,
                  bottom: 0,
                ),
                padding: const EdgeInsets.only(
                  left: 0,
                  top: 0,
                  right: 0,
                  bottom: 0,
                ),
              ),

              // Brand Line
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: berryGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  left: 0,
                  top: 50,
                  right: 0,
                  bottom: 0,
                ),
                padding: const EdgeInsets.only(
                  left: 0,
                  top: 0,
                  right: 0,
                  bottom: 0,
                ),
              ),

              // Action Button
              Container(
                width: double.infinity,
                height: 55,
                margin: const EdgeInsets.only(
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
                child: ElevatedButton(
                  onPressed: (){
                    if(context.canPop()){
                      context.pop(context);
                    }
                    else{
                     // context.go(HOME_ROUTE);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: berryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}