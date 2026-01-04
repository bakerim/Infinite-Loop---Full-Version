import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'features/game/presentation/pages/splash_page.dart'; // Sadece bunu import ediyoruz

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!kIsWeb) {
    try {
      await MobileAds.instance.initialize();
      // Test cihazı eklemek istersen buraya ekleyebilirsin
      // await MobileAds.instance.updateRequestConfiguration(...);
    } catch (e) {
      print("Ads init error: $e");
    }
    
    // Tam ekran ve dikey mod kilidi
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Infinite Loop',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.cyan,
        scaffoldBackgroundColor: const Color(0xFF0A0E21), // Ana tema rengimiz
        fontFamily: 'Orbitron', // Eğer font yüklüyse
      ),
      home: const SplashPage(), // ARTIK BURADAN BAŞLIYOR
    );
  }
}