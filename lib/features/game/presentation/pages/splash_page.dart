import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'main_menu_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Tam ekran modu
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Animasyon Kurulumu
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // 3 Saniye sonra Menüye git
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
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
      backgroundColor: const Color(0xFF0A0E21), // Ana Tema Rengi
      body: Stack(
        children: [
          // Arka Plan Deseni
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.network(
                "https://img.freepik.com/free-vector/dark-hexagonal-background-with-gradient-color_79603-1409.jpg",
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(color: Colors.transparent),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // LOGO EFEKTİ
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.cyanAccent.withOpacity(0.2), blurRadius: 60, spreadRadius: 10),
                          BoxShadow(color: Colors.purpleAccent.withOpacity(0.1), blurRadius: 100, spreadRadius: 20),
                        ],
                      ),
                      child: const Icon(Icons.all_inclusive, size: 100, color: Colors.cyanAccent),
                    ),
                    const SizedBox(height: 30),
                    
                    // İSİM
                    Text("INFINITE", style: GoogleFonts.orbitron(fontSize: 24, color: Colors.cyanAccent, letterSpacing: 8)),
                    Text("LOOP", style: GoogleFonts.orbitron(fontSize: 50, color: Colors.white, fontWeight: FontWeight.w900, shadows: [const Shadow(color: Colors.purpleAccent, blurRadius: 20)])),
                    
                    const SizedBox(height: 50),
                    
                    // YÜKLENİYOR
                    const SizedBox(
                      width: 40, height: 40,
                      child: CircularProgressIndicator(color: Colors.purpleAccent, strokeWidth: 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Alt İsim
          Positioned(
            bottom: 30, left: 0, right: 0,
            child: Center(child: Text("Designed by You", style: GoogleFonts.orbitron(color: Colors.white24, fontSize: 12))),
          )
        ],
      ),
    );
  }
}