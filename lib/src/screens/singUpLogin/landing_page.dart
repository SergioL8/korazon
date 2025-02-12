import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:korazon/src/utilities/design_variables.dart';



class LandingPage extends StatelessWidget {

  const LandingPage({super.key});


  @override
  Widget build(BuildContext context) {
    final gradientAlignment = Alignment(-0.65, -0.6);
    double iconSize = 35;

    // Convert gradientAlignment into pixel coordinates
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double gradientCenterX = screenWidth * (0.5 + gradientAlignment.x * 0.5); // Convert alignment to pixel coordinates
    double gradientCenterY = screenHeight * (0.5 + gradientAlignment.y * 0.5); // Convert alignment to pixel coordinates



    return Scaffold(
      backgroundColor: backgroundColorBM,
      body: Stack(
        children: [

          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: SweepGradient(
                colors: mainGradient.colors,
                stops: mainGradient.stops,
                center: gradientAlignment,
              ),
            ),
          ),


          // Absolute Positioning of Icon (Perfectly Matches Gradient Center)
          Positioned(
            left: gradientCenterX - (iconSize/2), // Offset by half the icon size (50/2)
            top: gradientCenterY - (iconSize/2),  // Offset by half the icon size (50/2)
            child: Icon(
              FaIcon(FontAwesomeIcons.solidHeart).icon, 
              size: iconSize,
              color: Colors.white
            ),
          ),


          // Text Positioned Next to Icon (Without Affecting Its Position)
          Positioned(
            left: gradientCenterX + 25, // Space text right of the icon
            top: gradientCenterY - (iconSize),  // Align with the icon
            child: Text(
              "Korazon",
              style: whiteLogo,
            ),
          ),



          // Fixed Modal Bottom Sheet with Rounded Top Borders
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: screenHeight * 0.65, // Adjust modal height as needed
              decoration: BoxDecoration(
                color: backgroundColorBM, // Solid background color
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60),  // Adjust the radius as needed
                  topRight: Radius.circular(60),
                ),
              ),
              child: Center(
                child: Text(
                  "Fixed Modal Content",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
        ]
      ),
    );
  }
}
 