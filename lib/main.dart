import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'src/screens/singUpLogin/signedin_logic.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb){
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCD6POJAG4zMcxWK83vw1hRK94hm46cIxQ",
      appId:  "1:368181595286:web:160fffede7a286998046b7",
      messagingSenderId:  "368181595286",
      projectId: "korazon-dc77a",
      storageBucket: "korazon-dc77a.firebasestorage.app",
    ),
  );
  } else { await Firebase.initializeApp(
    name: 'korazon_app', // String.fromCharCode(charCode),
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    //providerFactory: AppCheckProviderFactory.debugProviderFactory,
    //webRecaptchaSiteKey: 'YOUR_RECAPTCHA_SITE_KEY',
    // Use AndroidProvider.debug for development
    androidProvider: AndroidProvider.debug, 
    // AndroidProvider.playIntegrity, for production
    //appleProvider: AppleProvider.appAttest,
  );
  }
  await dotenv.load(fileName: ".env");
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'korazon',
      home: const isSignedLogic(),
    );
  }
}