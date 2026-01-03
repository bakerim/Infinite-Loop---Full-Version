import 'package:flutter/material.dart';

class Point {
  final int x;
  final int y;
  Point(this.x, this.y);
}

class BlockModel {
  final List<Point> positions; 
  final Color color;
  final int id; 

  BlockModel({required this.positions, required this.color, required this.id});

  // --- NEON RENK PALETİ ---
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonPurple = Color(0xFFD500F9);
  static const Color neonGreen = Color(0xFF00E676);
  static const Color neonOrange = Color(0xFFFF9100);
  static const Color neonRed = Color(0xFFFF1744);
  static const Color neonBlue = Color(0xFF2979FF);
  static const Color neonYellow = Color(0xFFFFEA00);

  // --- ŞEKİL HAVUZU (Tüm varyasyonlar) ---
  static List<BlockModel> getAllShapes() {
    int id = 0;
    int nextId() => id++; // Geçici ID üretici

    return [
      // 1. TEKLİ NOKTA (1x1)
      BlockModel(id: nextId(), color: neonYellow, positions: [Point(0,0)]),

      // 2. KARE (2x2)
      BlockModel(id: nextId(), color: neonCyan, positions: [Point(0,0), Point(0,1), Point(1,0), Point(1,1)]),
      // BÜYÜK KARE (3x3)
      BlockModel(id: nextId(), color: neonPurple, positions: [
        Point(0,0), Point(0,1), Point(0,2),
        Point(1,0), Point(1,1), Point(1,2),
        Point(2,0), Point(2,1), Point(2,2)
      ]),

      // 3. ÇİZGİLER (I SHAPES)
      // 1x2 ve 2x1
      BlockModel(id: nextId(), color: neonBlue, positions: [Point(0,0), Point(0,1)]), // Yatay 2
      BlockModel(id: nextId(), color: neonBlue, positions: [Point(0,0), Point(1,0)]), // Dikey 2
      // 1x3 ve 3x1
      BlockModel(id: nextId(), color: neonGreen, positions: [Point(0,0), Point(0,1), Point(0,2)]), // Yatay 3
      BlockModel(id: nextId(), color: neonGreen, positions: [Point(0,0), Point(1,0), Point(2,0)]), // Dikey 3
      // 1x4 ve 4x1
      BlockModel(id: nextId(), color: neonRed, positions: [Point(0,0), Point(0,1), Point(0,2), Point(0,3)]), 
      BlockModel(id: nextId(), color: neonRed, positions: [Point(0,0), Point(1,0), Point(2,0), Point(3,0)]),
      // 1x5 ve 5x1 (Riskli ama ekledik)
      BlockModel(id: nextId(), color: neonOrange, positions: [Point(0,0), Point(0,1), Point(0,2), Point(0,3), Point(0,4)]),
      BlockModel(id: nextId(), color: neonOrange, positions: [Point(0,0), Point(1,0), Point(2,0), Point(3,0), Point(4,0)]),

      // 4. L ŞEKLİ VARYASYONLARI (L Shape)
      // Normal L
      BlockModel(id: nextId(), color: neonOrange, positions: [Point(0,0), Point(1,0), Point(2,0), Point(2,1)]),
      // Ters L (Yatay)
      BlockModel(id: nextId(), color: neonOrange, positions: [Point(0,0), Point(0,1), Point(0,2), Point(1,0)]),
      // L 90 derece
      BlockModel(id: nextId(), color: neonOrange, positions: [Point(0,0), Point(0,1), Point(1,1), Point(2,1)]),
      // L 180 derece
      BlockModel(id: nextId(), color: neonOrange, positions: [Point(0,2), Point(1,0), Point(1,1), Point(1,2)]),

      // 5. KÜÇÜK L (2x2 alan kaplayan)
      BlockModel(id: nextId(), color: neonPurple, positions: [Point(0,0), Point(1,0), Point(1,1)]), // Sol Alt Köşe
      BlockModel(id: nextId(), color: neonPurple, positions: [Point(0,0), Point(0,1), Point(1,0)]), // Sol Üst Köşe
      BlockModel(id: nextId(), color: neonPurple, positions: [Point(0,1), Point(1,0), Point(1,1)]), // Sağ Alt Köşe
      BlockModel(id: nextId(), color: neonPurple, positions: [Point(0,0), Point(0,1), Point(1,1)]), // Sağ Üst Köşe
    ];
  }
}