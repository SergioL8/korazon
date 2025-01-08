import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:korazon/src/utilities/design_variables.dart';



class HostSignUp extends StatelessWidget {
  const HostSignUp({super.key});


  Future<void> _launchForm() async {
    const String urlString = 'https://docs.google.com/forms/d/e/1FAIpQLScKxLuxvlnkqgHgd-irr64m5RBmkg7Y15oYjviYD-JTFL5h8A/viewform?usp=sharing';
    Uri url = Uri.parse(urlString);

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white,),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                // SizedBox(height: MediaQuery.of(context).size.height * 0.12), // set the height of the column to 10% of the screen height to avoid elements under the camera
          
                Icon(
                  Icons.account_balance, // Greek temple-like icon
                  size: 100,
                  color: secondaryColor,
                ),
                Text(
                  'Greek Life',
                  style: TextStyle(
                    color: secondaryColor,
                  ),
                ),
          
                const SizedBox(height: 30,),
          
                Text(
                  'Welcome to',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40, 
                    fontWeight: FontWeight.w400,
                    color: secondaryColor
                  ),
                ),
                
                Text(
                  'Korazon',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40, 
                    fontWeight: primaryFontWeight,
                    color: secondaryColor
                  ),
                ),
          
                const SizedBox(height: 10,),
          
                Text(
                  'different beats, one rhythm',
                  style: TextStyle(
                    color: secondaryColor,
                  ),
                ),
          
                SizedBox(height: MediaQuery.of(context).size.height * 0.05), // set the height of the column to 10% of the screen height to avoid elements under the camera
                
                Text(
                  ' • If you are a frat and want to throw parties with Korazon you are in the right place.',
                  style: TextStyle(
                    color: secondaryColor,
                  ),
                ),
                const SizedBox(height: 20,),
                Text(
                  ' • Right now we don\'t offer automatic sign up for hosts, but fill the form bellow and we will get back to you within 24 hours.',
                  style: TextStyle(
                    color: secondaryColor,
                  ),
                ),
          
                const SizedBox(height: 50,),
          
                InkWell(
                  onTap: _launchForm,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: MediaQuery.of(context).size.height * 0.1,
                    decoration: BoxDecoration(
                      color: korazonColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Host sign up form',
                        style: TextStyle(
                          color: secondaryColor,
                          fontSize: 20,
                          fontWeight: primaryFontWeight,
                        ),
                      )
                    ),
                  ),
                ),
                const SizedBox(height: 40,),
                
              ],
            ),
          ),
        ),
      ),
    );
  }

}