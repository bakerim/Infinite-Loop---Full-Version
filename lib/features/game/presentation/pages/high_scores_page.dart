import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/neo_button.dart';

class HighScoresPage extends StatefulWidget {
  const HighScoresPage({super.key});

  @override
  State<HighScoresPage> createState() => _HighScoresPageState();
}

class _HighScoresPageState extends State<HighScoresPage> {
  int bestScore = 0;

  @override
  void initState() {
    super.initState();
    _loadScore();
  }

  Future<void> _loadScore() async {
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
          // Arka Plan
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, 0),
                radius: 1.2,
                colors: [Color(0xFF1E1035), Color(0xFF0A0E21)],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // HEADER
                  Row(
                    children: [
                      NeoButton(
                        icon: Icons.arrow_back,
                        color: Colors.cyanAccent,
                        width: 50,
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 20),
                      Text("LEADERBOARD", style: GoogleFonts.orbitron(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  
                  const Spacer(),

                  // KUPA SİMGESİ
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber.withOpacity(0.1),
                      boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.2), blurRadius: 50, spreadRadius: 10)],
                      border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2),
                    ),
                    child: const Icon(Icons.emoji_events_rounded, size: 80, color: Colors.amber),
                  ),

                  const SizedBox(height: 40),

                  // SKOR KUTUSU
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2032),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                      boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.1), blurRadius: 20)],
                    ),
                    child: Column(
                      children: [
                        Text("ALL TIME BEST", style: GoogleFonts.orbitron(color: Colors.grey, fontSize: 14, letterSpacing: 2)),
                        const SizedBox(height: 10),
                        Text("$bestScore", style: GoogleFonts.orbitron(color: Colors.white, fontSize: 60, fontWeight: FontWeight.w900, shadows: [const Shadow(color: Colors.cyan, blurRadius: 20)])),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}