import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:korazon/src/screens/singUpLogin/loginSignupPage.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/widgets/gradient_border_button.dart';


class InitialMessagePage extends StatefulWidget {
  const InitialMessagePage({super.key});

  @override
  State<InitialMessagePage> createState() => _InitialMessagePageState();
}

class _InitialMessagePageState extends State<InitialMessagePage> {
  @override
  Widget build(BuildContext context) {

    final gradientAlignment = const Alignment(-0.65, -0.715);
    double iconSize = MediaQuery.of(context).size.width * 0.11;

    // Convert gradientAlignment into pixel coordinates
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double gradientCenterX = screenWidth * (0.5 + gradientAlignment.x * 0.5);
    double gradientCenterY = screenHeight * (0.5 + gradientAlignment.y * 0.5);


    return Scaffold(
      backgroundColor: backgroundColorBM,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
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

          // Heart icon
          Positioned(
            left: gradientCenterX - (iconSize / 2),
            top: gradientCenterY - (iconSize / 2),
            child: Hero(
              tag: 'korazonIconTag',
              child: Icon(
                FaIcon(FontAwesomeIcons.solidHeart).icon,
                size: iconSize,
                color: Colors.white,
              ),
            ),
          ),

          // "Korazon" text next to icon
          Positioned(
            left: gradientCenterX + MediaQuery.of(context).size.width * 0.077,
            top: gradientCenterY - iconSize,
            child: Hero(
              tag: 'korazonLogoTag',
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  "Korazon",
                  style: GoogleFonts.josefinSans(
                    fontSize: MediaQuery.of(context).size.width * 0.155,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // Fixed modal bottom sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Hero(
              tag: 'modalBottomSheet',
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  width: double.infinity,
                  height: screenHeight * 0.78,
                  decoration: const BoxDecoration(
                    color: backgroundColorBM,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: screenWidth * 0.07,
                      right: screenWidth * 0.07,
                      top: screenHeight * 0.025,
                      bottom: screenHeight * 0.055,
                    ),
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: screenHeight * 0.70),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    icon: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Create Host Acc',
                                    style: whiteSubtitle,
                                  ),
                                  const Spacer(),
                                  const SizedBox(width: 48),
                                ],
                              ),
                              const SizedBox(height: 30),
                              Text(
                                'Welcome to Korazon!',
                                style: whiteBody.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Note that to continue you must be a frat or organization. ',
                                style: whiteBody,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'If you are a host and want to throw parties with Korazon you are in the right place.',
                                style: whiteBody,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'If you are trying to login, all logins are managed through the same login page as users login.',
                                style: whiteBody,
                                textAlign: TextAlign.center,
                              ),
                              Spacer(),
                              GradientBorderButton(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => LoginSignupPage(parentPage: ParentPage.createHostAcc,)), // Replace with your destination page
                                  );
                                },
                                text: 'Continue',
                              ),
                              SizedBox(height: 25),
                              Text(
                                "Boulder, CO",
                                style: whiteBody,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}