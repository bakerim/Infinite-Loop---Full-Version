import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Kayıt okumak için
import '../widgets/neo_button.dart';

class HighScoresPage extends StatefulWidget {
  const HighScoresPage({Key? key}) : super(key: key);

  @override
  _HighScoresPageState createState() => _HighScoresPageState();
}

class _HighScoresPageState extends State<HighScoresPage> {
  int bestScore = 0;

  @override
  void initState() {
    super.initState();
    _loadBestScore();
  }

  // Kaydedilen skoru çek
  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bestScore = prefs.getInt('best_score') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F101E),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.8),
                radius: 1.5,
                colors: [Color(0xFF4A148C), Color(0xFF0F101E)],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.amber, size: 60),
                      const SizedBox(height: 10),
                      Text("LEADERBOARD", style: GoogleFonts.orbitron(
                        color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 3,
                        shadows: [const Shadow(color: Colors.purple, blurRadius: 20)]
                      )),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // TEK VE DEVASA SKOR KARTI
                Transform.scale(
                  scale: 1.1,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2032).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2),
                      boxShadow: [
                        BoxShadow(color: Colors.amber.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10))
                      ]
                    ),
                    child: Column(
                      children: [
                        const Text("ALL TIME BEST", style: TextStyle(color: Colors.amber, letterSpacing: 2, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text("$bestScore", style: GoogleFonts.orbitron(
                          color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900
                        )),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.all(30),
                  child: NeoButton(
                    text: "BACK TO MENU",
                    color: Colors.blueGrey,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}