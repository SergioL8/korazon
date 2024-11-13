import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:korazon/src/data/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'src/cloudresources/signedin_logic.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    name: 'db2',

    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    //webRecaptchaSiteKey: 'YOUR_RECAPTCHA_SITE_KEY',
    
    // Use AndroidProvider.debug for development
    androidProvider: AndroidProvider.debug, 
    //use AndroidProvider.playIntegrity for production
    appleProvider: AppleProvider.appAttest,
  );

    
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context)=> UserProvider(),),
      ],
      child: MaterialApp(
      title: 'FlutterChat',
      home: const isSignedLogic(),
    ),
    );
  }
}