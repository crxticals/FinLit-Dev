// ignore_for_file: unused_import

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:project_name/firebase_options.dart';
import 'package:project_name/pages/homepage.dart';
import 'package:project_name/pages/homepage_desktop.dart';
import 'package:project_name/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_name/pages/migrate_data.dart';

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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('vi', ''), // Vietnamese
      ],
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;
            if (user == null) {
              return LoginPage(); // User is not signed in
            } else {
              return LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > constraints.maxHeight) {
                    return const HomeScreen1(); // Landscape
                  } else {
                    return const MigrateData(); // Portrait
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