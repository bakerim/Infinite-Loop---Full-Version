import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_menu_page.dart'; // Birazdan oluşturacağız

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animasyon Ayarları (Fade In + Scale)
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);

    // 3 Saniye Sonra Menüye Git
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainMenuPage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F101E), // Ana tema rengimiz
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // SPLASH PNG BURADA
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                  BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.3),
                      blurRadius: 50,
                      spreadRadius: 10)
                ]),
                child: Image.asset('assets/images/splash.png',
                    fit: BoxFit.contain),
              ),

              const SizedBox(height: 30),

              // YÜKLENİYOR YAZISI (Opsiyonel)
              Text("INFINITE LOOP",
                  style: GoogleFonts.orbitron(
                      fontSize: 24,
                      color: Colors.white,
                      letterSpacing: 4,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
