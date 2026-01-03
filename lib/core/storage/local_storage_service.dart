import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/leaderboard/data/models/score_model.dart';

// Provider ile servise erişim
final localStorageProvider = Provider((ref) => LocalStorageService());

class LocalStorageService {
  static const String _boxName = 'infinite_loop_scores';

  // Başlangıç ayarları (Main.dart içinde çağrılacak)
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ScoreModelAdapter());
    await Hive.openBox<ScoreModel>(_boxName);
  }

  // Yeni skor kaydetme (Sadece ilk 10'a girerse veya liste boşsa)
  Future<void> saveScore(int score) async {
    final box = Hive.box<ScoreModel>(_boxName);
    
    // Yeni skoru ekle
    await box.add(ScoreModel(score: score, date: DateTime.now()));

    // Sıralama yap ve fazla olanları sil (Sadece en iyi 10 kalsın)
    var allScores = box.values.toList();
    allScores.sort((a, b) => b.score.compareTo(a.score)); // Büyükten küçüğe

    if (allScores.length > 10) {
      // 10. sıradan sonrakileri veritabanından sil
      for (var i = 10; i < allScores.length; i++) {
        await allScores[i].delete(); 
      }
    }
  }

  // En yüksek skoru getir (Ana ekranda göstermek için)
  int getHighScore() {
    final box = Hive.box<ScoreModel>(_boxName);
    if (box.isEmpty) return 0;
    
    final maxScore = box.values.reduce((curr, next) => curr.score > next.score ? curr : next);
    return maxScore.score;
  }

  // Tüm listeyi getir (Leaderboard sayfası için)
  List<ScoreModel> getTopScores() {
    final box = Hive.box<ScoreModel>(_boxName);
    final list = box.values.toList();
    list.sort((a, b) => b.score.compareTo(a.score));
    return list;
  }
}