// ignore_for_file: unused_import

import 'package:finlit/pages/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:finlit/firebase_options.dart';
import 'package:finlit/pages/homepage.dart';
import 'package:finlit/pages/homepage_desktop.dart';
import 'package:finlit\/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finlit\/pages/migrate_data.dart';
import 'package:finlit\/pages/onboarding.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinLit',
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;
            if (user == null) {
              return OnBoarding(); // User is not signed in so show onboarding instead
            } else {
              return LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > constraints.maxHeight) {
                    return const HomeScreen1(); // Landscape
                  } else {
                    return const HomeScreen(); // Portrait
                  }
                },
              );
            }
          } else {
            // While checking the user's authentication state
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}