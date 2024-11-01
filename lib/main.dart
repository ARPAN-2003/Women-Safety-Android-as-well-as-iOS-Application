import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:women_safety_app/child/bottom_page.dart';
import 'package:women_safety_app/db/share_pref.dart';
import 'package:women_safety_app/child/child_login_screen.dart';
import 'package:women_safety_app/parent/parent_home_screen.dart';
import 'package:women_safety_app/utils/constants.dart';
import 'package:women_safety_app/utils/flutter_background_services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sensors_plus/sensors_plus.dart';

final navigatorkey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // print("Initializing Firebase...");
  await Firebase.initializeApp();
  // print("Firebase initialized");
  await MySharedPreference.init();
  await initializeService();
  // await Sensors.platformSensors.requestPermission('accelerometer');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Demo",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.firaSansTextTheme(
          Theme.of(context).textTheme,
        ),
        primarySwatch: Colors.blue,
      ),
      // home: LoginScreen()
      home: FutureBuilder(future: MySharedPreference.getUserType(), builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.data == "") {
          return LoginScreen();
        }
        if (snapshot.data == "child"){
          return BottomPage();
        }
        if (snapshot.data == "parent"){
          return ParentHomeScreen();
        }
        return progressIndicator(context);
      }
    ));
  }
}

//*** class CheckAuth extends StatelessWidget {
//   // const CheckAuth({super.key});
//
//   checkData() {
//     if (MySharedPreference.getUserType() == 'parent') {
//
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold();
//   }
// }

