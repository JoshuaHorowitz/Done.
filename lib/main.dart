import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pages/home_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

void main() async {
  // init the hive
  await Hive.initFlutter();

  // open a box
  var box = await Hive.openBox('mybox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimatedSplashScreen(
          backgroundColor: Colors.white,
          splash: Center(
              child: Row(
            children: [
              Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    'Got stuff to do?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36),
                  )),
              Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Lottie.network(
                      'https://assets3.lottiefiles.com/packages/lf20_z9gxmvaq.json'))
            ],
          )),
          duration: 1800,
          splashTransition: SplashTransition.fadeTransition,
          nextScreen: AnimatedSplashScreen(
              backgroundColor: Colors.grey,
              splash: Center(
                  child: Row(
                children: [
                  Padding(
                      padding: EdgeInsets.only(left: 50),
                      child: Text(
                        'Get it Done.',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 36),
                      )),
                  Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Lottie.network(
                          'https://assets6.lottiefiles.com/packages/lf20_txJcSM.json'))
                ],
              )),
              duration: 1600,
              splashTransition: SplashTransition.fadeTransition,
              nextScreen: const HomePage())),
      theme: ThemeData(
          primarySwatch: Colors.grey,
          textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme)),
    );
  }
}
