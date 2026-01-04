import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/neo_button.dart';
import 'game_page.dart';
import 'settings_page.dart';
import 'high_scores_page.dart'; // Artık kullanılacak, hata gidecek!

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  int bestScore = 0;

  @override
  void initState() {
    super.initState();
    _loadBestScore();
  }

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bestScore = prefs.getInt('best_score') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
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
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  
                  // LOGO
                  Text("INFINITE", style: GoogleFonts.orbitron(fontSize: 28, color: Colors.cyanAccent, letterSpacing: 8, fontWeight: FontWeight.bold, shadows: [const Shadow(color: Colors.cyan, blurRadius: 20)])),
                  Text("LOOP", style: GoogleFonts.orbitron(fontSize: 64, color: Colors.white, fontWeight: FontWeight.w900, shadows: [const Shadow(color: Colors.purpleAccent, blurRadius: 30)])),
                  
                  const SizedBox(height: 20),
                  
                  // BEST SCORE KUTUSU
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.emoji_events, color: Colors.amber, size: 16),
                        const SizedBox(width: 8),
                        Text("BEST: $bestScore", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                  const Spacer(flex: 3),

                  // START GAME BUTONU
                  NeoButton(
                    text: "START GAME",
                    icon: Icons.play_arrow_rounded,
                    color: Colors.cyanAccent,
                    width: double.infinity,
                    height: 70,
                    isPrimary: true,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const GamePage())).then((_) {
                        _loadBestScore(); // Oyun bitince skoru güncelle
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // ALT BUTONLAR (RANK & SETTINGS)
                  Row(
                    children: [
                      Expanded(
                        child: NeoButton(
                          text: "Rank",
                          icon: Icons.bar_chart,
                          color: Colors.purpleAccent,
                          height: 55,
                          isPrimary: false,
                          // İŞTE BURASI DÜZELDİ: Artık HighScoresPage'e gidiyor
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const HighScoresPage()));
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: NeoButton(
                          text: "Settings",
                          icon: Icons.settings,
                          color: Colors.purpleAccent,
                          height: 55,
                          isPrimary: false,
                          onTap: () {
                             Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                          },
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}