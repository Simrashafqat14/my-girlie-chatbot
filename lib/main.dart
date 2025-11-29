import 'package:demoprojecttwo/my_home_page.dart';
import 'package:demoprojecttwo/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
      routes: {"/home": (_) => const GirlieChatScreen()},
    );
  }
}
