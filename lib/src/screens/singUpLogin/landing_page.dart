import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:korazon/src/screens/singUpLogin/hostSignUpExperience/initialMessagePage.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:korazon/src/widgets/gradient_border_button.dart';
import 'package:korazon/src/screens/singUpLogin/loginSignupPage.dart';
import 'package:korazon/src/utilities/utils.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gradientAlignment = Alignment(-0.65, -0.6);
    double iconSize = MediaQuery.of(context).size.width * 0.11;

    // Convert gradientAlignment into pixel coordinates
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double gradientCenterX = screenWidth *
        (0.5 +
            gradientAlignment.x *
                0.5); // Convert alignment to pixel coordinates
    double gradientCenterY = screenHeight *
        (0.5 +
            gradientAlignment.y *
                0.5); // Convert alignment to pixel coordinates

    return Scaffold(
      backgroundColor: backgroundColorBM,
      body: Stack(children: [
        // Background gradient
        Hero(
          tag: 'gradientTag',
          child: Container(
            decoration: BoxDecoration(
              gradient: SweepGradient(
                colors: mainGradient.colors,
                stops: mainGradient.stops,
                center: gradientAlignment,
              ),
            ),
          ),
        ),

        // Absolute Positioning of Icon (Perfectly Matches Gradient Center)
        Positioned(
          left: gradientCenterX -
              (iconSize / 2), // Offset by half the icon size (50/2)
          top: gradientCenterY -
              (iconSize / 2), // Offset by half the icon size (50/2)
          child: Hero(
            tag: 'korazonIconTag',
            child: Icon(FaIcon(FontAwesomeIcons.solidHeart).icon,
                size: iconSize, color: Colors.white),
          ),
        ),

        // Text Positioned Next to Icon (Without Affecting Its Position)
        Positioned(
          left: gradientCenterX +
              MediaQuery.of(context).size.width *
                  0.077, // Space text right of the icon
          top: gradientCenterY - (iconSize), // Align with the icon
          child: Hero(
            tag: 'korazonLogoTag',
            child: Material(
              type: MaterialType.transparency,
              child: Text("Korazon",
                  style: GoogleFonts.josefinSans(
                      fontSize: MediaQuery.of(context).size.width * 0.155,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ),
          ),
        ),

        // Fixed Modal Bottom Sheet with Rounded Top Borders
        Align(
          alignment: Alignment.bottomCenter,
          child: Hero(
            tag: 'modalBottomSheet',
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                width: double.infinity,
                height: screenHeight * 0.65, // Adjust modal height as needed
                decoration: BoxDecoration(
                  color: backgroundColorBM, // Solid background color
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60), // Adjust the radius as needed
                    topRight: Radius.circular(60),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.11,
                    right: MediaQuery.of(context).size.width * 0.11,
                    top: MediaQuery.of(context).size.height * 0.075,
                    bottom: MediaQuery.of(context).size.height * 0.055,
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GradientBorderButton(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginSignupPage(
                                        parentPage: ParentPage.login,
                                      )), // Replace with your destination page
                            );
                          },
                          text: "Login",
                        ),
                        SizedBox(height: 25),
                        GradientBorderButton(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginSignupPage(
                                        parentPage: ParentPage.signup,
                                      )), // Replace with your destination page
                            );
                          },
                          text: "Sign Up",
                        ),
                        Spacer(),
                        SizedBox(height: 25),
                        GradientBorderButton(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => InitialMessagePage()),
                            );
                          },
                          text: "Create Host Acc.",
                        ),
                        SizedBox(height: 25),
                        Text(
                          "Boulder, CO",
                          style: whiteBody,
                        )
                      ]),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
