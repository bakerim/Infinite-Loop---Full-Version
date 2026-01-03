import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_page.dart';
import 'high_scores_page.dart';
import 'settings_page.dart';
import '../widgets/neo_button.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F101E),
      body: Stack(
        children: [
          // Arka Plan Efekti
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.4),
                radius: 1.2,
                colors: [Color(0xFF2A1C40), Color(0xFF0F101E)],
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LOGO
                    Text("INFINITE", style: GoogleFonts.orbitron(
                      color: Colors.cyanAccent, fontSize: 20, letterSpacing: 5
                    )),
                    Text("LOOP", style: GoogleFonts.orbitron(
                      color: Colors.white, fontSize: 60, fontWeight: FontWeight.w900,
                      shadows: [const Shadow(color: Colors.purpleAccent, blurRadius: 30)]
                    )),
                    
                    const SizedBox(height: 80),

                    // --- BUTONLAR (Sadece 3 adet ve hepsi NeoButton) ---

                    // 1. START GAME
                    NeoButton(
                      text: "START GAME",
                      color: Colors.cyanAccent,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const GamePage()));
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 2. HIGH SCORES (Tek ve çalışan buton)
                    NeoButton(
                      text: "HIGH SCORES",
                      color: Colors.purpleAccent,
                      onTap: () {
                         Navigator.push(context, MaterialPageRoute(builder: (context) => const HighScoresPage()));
                      },
                    ),

                    const SizedBox(height: 20),

                    // 3. SETTINGS
                    NeoButton(
                      text: "SETTINGS",
                      color: Colors.blueGrey,
                      onTap: () {
                         Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Versiyon
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text("v1.0.0", style: TextStyle(color: Colors.white.withOpacity(0.3))),
            ),
          )
        ],
      ),
    );
  }
}