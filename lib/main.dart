import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// HATALI SATIR buydu, sonuna ; ekledik:
import 'package:google_mobile_ads/google_mobile_ads.dart'; 
import 'features/game/presentation/pages/splash_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Infinite Loop',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F101E),
        textTheme: GoogleFonts.orbitronTextTheme(
          Theme.of(context).textTheme.apply(bodyColor: Colors.white),
        ),
      ),
      home: const SplashPage(),
    );
  }
}