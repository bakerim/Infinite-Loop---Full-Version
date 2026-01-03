import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/neo_button.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _particlesEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F101E),
      body: Stack(
        children: [
          // Arka Plan
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.8, -0.8),
                radius: 1.3,
                colors: [Color(0xFF006064), Color(0xFF0F101E)], // Cyan ağırlıklı
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // BAŞLIK
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    children: [
                      const Icon(Icons.settings, color: Colors.cyanAccent, size: 50),
                      const SizedBox(height: 10),
                      Text("SETTINGS", style: GoogleFonts.orbitron(
                        color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 3,
                        shadows: [const Shadow(color: Colors.cyan, blurRadius: 20)]
                      )),
                    ],
                  ),
                ),

                // AYARLAR LİSTESİ
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _buildSwitchTile("SOUND", Icons.volume_up, _soundEnabled, (v) => setState(() => _soundEnabled = v)),
                      _buildSwitchTile("VIBRATION", Icons.vibration, _vibrationEnabled, (v) => setState(() => _vibrationEnabled = v)),
                      _buildSwitchTile("PARTICLES", Icons.auto_awesome, _particlesEnabled, (v) => setState(() => _particlesEnabled = v)),
                      
                      const SizedBox(height: 40),
                      
                      // HAKKINDA KUTUSU
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          children: [
                            Text("INFINITE LOOP", style: GoogleFonts.orbitron(color: Colors.white70, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            const Text("Version 1.0.0", style: TextStyle(color: Colors.white38, fontSize: 12)),
                            const SizedBox(height: 10),
                            const Text("Created with Flutter", style: TextStyle(color: Colors.white30, fontSize: 10)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                // GERİ BUTONU
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: NeoButton(
                    text: "SAVE & BACK",
                    color: Colors.cyanAccent,
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

  Widget _buildSwitchTile(String title, IconData icon, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2032),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: value ? Colors.cyanAccent.withOpacity(0.5) : Colors.white10),
        boxShadow: [
          if (value) BoxShadow(color: Colors.cyanAccent.withOpacity(0.1), blurRadius: 10)
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: value ? Colors.cyanAccent : Colors.grey),
              const SizedBox(width: 15),
              Text(title, style: GoogleFonts.orbitron(
                color: value ? Colors.white : Colors.grey, 
                fontSize: 16, 
                fontWeight: FontWeight.bold
              )),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.cyanAccent,
            activeTrackColor: Colors.cyan.withOpacity(0.3),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
          )
        ],
      ),
    );
  }
}