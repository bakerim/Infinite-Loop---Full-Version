import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:infinite_loop/core/ad_helper.dart';
import 'package:infinite_loop/features/game/domain/block_model.dart';
import 'package:infinite_loop/features/game/presentation/widgets/draggable_block.dart';
import '../widgets/neo_button.dart';
import 'settings_page.dart';

// --- UÇAN YAZI MODELİ ---
class FloatingText {
  final String text;
  final Offset position;
  final Color color;
  final double fontSize;
  final Key key;
  FloatingText(
      {required this.text,
      required this.position,
      required this.color,
      required this.fontSize})
      : key = UniqueKey();
}

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  final int rows = 10;
  final int cols = 10;
  List<List<Color?>> grid =
      List.generate(10, (_) => List.generate(10, (_) => null));
  List<BlockModel> availableBlocks = [];
  List<Point> previewPoints = [];
  bool isValidMove = false;
  int score = 0;
  int bestScore = 0;
  bool isPaused = false;
  bool isGameOver = false;
  bool hasRevived = false;
  Set<int> clearingRows = {};
  Set<int> clearingCols = {};
  List<FloatingText> floatingTexts = [];

  // ADMOB
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  RewardedAd? _rewardedAd;

  // SES
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadBestScore();
    _startNewGame();

    // Web değilse reklamları yükle
    if (!kIsWeb) {
      _loadBannerAd();
      _loadRewardedAd();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _rewardedAd?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // --- YARDIMCI: GRID POZİSYON HESAPLAYICI ---
  Offset _getGridPixelPosition(double row, double col) {
    // Ekranın ortasını ve gridin başlangıcını hesapla
    // Not: Bu değerler UI'daki header yüksekliğine göre yaklaşık olarak ayarlanmıştır.
    double screenCenterX = MediaQuery.of(context).size.width / 2;
    double screenCenterY = MediaQuery.of(context).size.height * 0.42;
    double cellSize = 36.0; // Tahmini hücre boyutu

    double xOffset = (col - 4.5) * cellSize;
    double yOffset = (row - 4.5) * cellSize;

    return Offset(screenCenterX + xOffset, screenCenterY + yOffset);
  }

  void _playSound(String fileName) {
    // Ses dosyasını çal (assets/audio/ içinde olmalı)
    AudioPlayer().play(AssetSource('audio/$fileName'));
  }

  // --- ADMOB YÖNETİMİ ---
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          print("Banner Reklam Yüklendi");
          setState(() => _isBannerAdReady = true);
        },
        onAdFailedToLoad: (ad, err) {
          print('Banner Hatası: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );
    _bannerAd?.load();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          print("Ödüllü Reklam Hazır");
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (err) =>
            print('Ödüllü Reklam Hatası: ${err.message}'),
      ),
    );
  }

  void _showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadRewardedAd(); // Bir sonraki için yenisini yükle
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          _loadRewardedAd();
        },
      );
      _rewardedAd!.show(onUserEarnedReward: (_, __) => _performRevive());
    } else {
      // REKLAM HAZIR DEĞİLSE DİREKT GEÇİRME!
      print("Reklam henüz yüklenmedi");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Ad is loading... Please wait."),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.orange,
      ));
      _loadRewardedAd(); // Tekrar yüklemeyi dene
    }
  }

  void _performRevive() {
    setState(() {
      isGameOver = false;
      hasRevived = true;
      // Ortayı temizle
      for (int r = 3; r < 7; r++) {
        for (int c = 3; c < 7; c++) {
          grid[r][c] = null;
        }
      }
    });
    HapticFeedback.heavyImpact();
    // Tam ortada "REVIVED" yazısı
    _spawnFloatingText(
        "REVIVED!", _getGridPixelPosition(4.5, 4.5), Colors.greenAccent, 30);
  }

  // --- OYUN MANTIĞI ---

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bestScore = prefs.getInt('best_score') ?? 0;
    });
  }

  Future<void> _saveBestScore() async {
    if (score > bestScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('best_score', score);
      setState(() {
        bestScore = score;
      });
    }
  }

  void _startNewGame() {
    setState(() {
      grid = List.generate(10, (_) => List.generate(10, (_) => null));
      score = 0;
      isGameOver = false;
      isPaused = false;
      hasRevived = false;
      _generateNewBlocks();
    });
  }

  void _generateNewBlocks() {
    List<BlockModel> allShapes = BlockModel.getAllShapes();
    setState(() {
      availableBlocks = [
        _cloneBlock(allShapes[Random().nextInt(allShapes.length)]),
        _cloneBlock(allShapes[Random().nextInt(allShapes.length)]),
        _cloneBlock(allShapes[Random().nextInt(allShapes.length)]),
      ];
    });
    _checkGameOverCondition();
  }

  BlockModel _cloneBlock(BlockModel template) {
    return BlockModel(
      positions: template.positions,
      color: template.color,
      id: Random().nextInt(9999999),
    );
  }

  void placeShape(BlockModel shape, int startRow, int startCol) {
    _playSound('place.mp3');
    HapticFeedback.lightImpact();

    int maxX = shape.positions.map((p) => p.x).reduce(max);
    int maxY = shape.positions.map((p) => p.y).reduce(max);
    int rowOffset = (maxX / 2).floor();
    int colOffset = (maxY / 2).floor();

    setState(() {
      for (var p in shape.positions) {
        int r = startRow + p.x - rowOffset;
        int c = startCol + p.y - colOffset;
        if (r >= 0 && r < rows && c >= 0 && c < cols) {
          grid[r][c] = shape.color;
        }
      }
      previewPoints.clear();
      availableBlocks.removeWhere((b) => b.id == shape.id);

      int points = shape.positions.length;
      score += points;

      // Dinamik konumda puan yazısı
      double centerR = startRow + (maxX / 2.0);
      double centerC = startCol + (maxY / 2.0);
      _spawnFloatingText("+$points", _getGridPixelPosition(centerR, centerC),
          Colors.white54, 16);

      if (score > bestScore) bestScore = score;
      _saveBestScore();

      if (availableBlocks.isEmpty) {
        _generateNewBlocks();
      } else {
        _checkGameOverCondition();
      }
      _checkLines();
    });
  }

  Future<void> _checkLines() async {
    Set<int> rowsToClear = {};
    Set<int> colsToClear = {};

    for (int r = 0; r < rows; r++) {
      if (grid[r].every((cell) => cell != null)) rowsToClear.add(r);
    }
    for (int c = 0; c < cols; c++) {
      bool isColFull = true;
      for (int r = 0; r < rows; r++) {
        if (grid[r][c] == null) {
          isColFull = false;
          break;
        }
      }
      if (isColFull) colsToClear.add(c);
    }

    if (rowsToClear.isNotEmpty || colsToClear.isNotEmpty) {
      _playSound('clear.mp3');
      HapticFeedback.mediumImpact();

      setState(() {
        clearingRows = rowsToClear;
        clearingCols = colsToClear;
      });

      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        for (var r in rowsToClear) {
          for (int c = 0; c < cols; c++) grid[r][c] = null;
        }
        for (var c in colsToClear) {
          for (int r = 0; r < rows; r++) grid[r][c] = null;
        }

        int totalCleared = rowsToClear.length + colsToClear.length;
        int gainedScore = totalCleared * 20;

        // Patlama efekti konumu hesapla
        Offset explosionPos;
        if (rowsToClear.isNotEmpty && colsToClear.isNotEmpty) {
          explosionPos = _getGridPixelPosition(
              rowsToClear.first.toDouble(), colsToClear.first.toDouble());
        } else if (rowsToClear.isNotEmpty) {
          double avgRow =
              rowsToClear.reduce((a, b) => a + b) / rowsToClear.length;
          explosionPos = _getGridPixelPosition(avgRow, 4.5);
        } else {
          double avgCol =
              colsToClear.reduce((a, b) => a + b) / colsToClear.length;
          explosionPos = _getGridPixelPosition(4.5, avgCol);
        }

        if (totalCleared >= 2) {
          gainedScore *= totalCleared;
          _spawnFloatingText(
              "COMBO x$totalCleared!", explosionPos, Colors.purpleAccent, 32);
          HapticFeedback.heavyImpact();
        } else {
          _spawnFloatingText(
              "+$gainedScore", explosionPos, Colors.cyanAccent, 24);
        }

        score += gainedScore;
        if (score > bestScore) bestScore = score;
        _saveBestScore();

        clearingRows.clear();
        clearingCols.clear();
      });
    }
  }

  void _spawnFloatingText(
      String text, Offset startPos, Color color, double fontSize) {
    double randomX = Random().nextDouble() * 40 - 20;
    final floatingText = FloatingText(
        text: text,
        position: Offset(startPos.dx + randomX, startPos.dy),
        color: color,
        fontSize: fontSize);
    setState(() {
      floatingTexts.add(floatingText);
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted)
        setState(() {
          floatingTexts.removeWhere((ft) => ft.key == floatingText.key);
        });
    });
  }

  void _checkGameOverCondition() {
    if (availableBlocks.isEmpty) return;
    bool canPlaceAny = false;
    for (var block in availableBlocks) {
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          if (_canPlaceAt(block, r, c)) {
            canPlaceAny = true;
            break;
          }
        }
        if (canPlaceAny) break;
      }
      if (canPlaceAny) break;
    }
    if (!canPlaceAny) {
      setState(() => isGameOver = true);
    }
  }

  bool _canPlaceAt(BlockModel shape, int hoverRow, int hoverCol) {
    int maxX = shape.positions.map((p) => p.x).reduce(max);
    int maxY = shape.positions.map((p) => p.y).reduce(max);
    int rowOffset = (maxX / 2).floor();
    int colOffset = (maxY / 2).floor();
    for (var p in shape.positions) {
      int r = hoverRow + p.x - rowOffset;
      int c = hoverCol + p.y - colOffset;
      if (r < 0 || r >= rows || c < 0 || c >= cols) return false;
      if (grid[r][c] != null) return false;
    }
    return true;
  }

  void onHoverShape(BlockModel shape, int hoverRow, int hoverCol) {
    if (isPaused || isGameOver) return;
    List<Point> currentShadow = [];
    bool possible = true;
    int maxX = shape.positions.map((p) => p.x).reduce(max);
    int maxY = shape.positions.map((p) => p.y).reduce(max);
    int rowOffset = (maxX / 2).floor();
    int colOffset = (maxY / 2).floor();

    for (var p in shape.positions) {
      int r = hoverRow + p.x - rowOffset;
      int c = hoverCol + p.y - colOffset;
      if (r < 0 || r >= rows || c < 0 || c >= cols) {
        possible = false;
      } else if (grid[r][c] != null) {
        possible = false;
      }
      currentShadow.add(Point(r, c));
    }
    setState(() {
      isValidMove = possible;
      bool isOutOfBounds = currentShadow
          .any((p) => p.x < 0 || p.x >= rows || p.y < 0 || p.y >= cols);
      previewPoints = isOutOfBounds ? [] : currentShadow;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F101E),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.5, -0.5),
                radius: 1.5,
                colors: [Color(0xFF2A1C40), Color(0xFF0F101E)],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // HEADER
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("INFINITE",
                              style: GoogleFonts.orbitron(
                                  color: Colors.cyanAccent,
                                  fontSize: 14,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold)),
                          Text("LOOP",
                              style: GoogleFonts.orbitron(
                                  color: Colors.white,
                                  fontSize: 24,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w900,
                                  shadows: [
                                    const Shadow(
                                        color: Colors.purpleAccent,
                                        blurRadius: 15)
                                  ])),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("$score",
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            Row(children: [
                              const Icon(Icons.emoji_events,
                                  color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text("BEST: $bestScore",
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white.withOpacity(0.6)))
                            ])
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // GRID (FittedBox)
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: const Color(0xFF16182B).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.08)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 30,
                                  spreadRadius: 0)
                            ]),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(rows, (r) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                  cols, (c) => _buildGridCell(r, c)),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),

                // KONTROLLER
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      NeoButton(
                          icon: Icons.pause,
                          color: Colors.cyan,
                          width: 50,
                          onTap: () => setState(() => isPaused = true)),
                      const SizedBox(width: 10),
                      NeoButton(
                          icon: Icons.settings,
                          color: Colors.purple,
                          width: 50,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SettingsPage()))),
                    ],
                  ),
                ),

                // BLOKLAR
                SizedBox(
                  height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: availableBlocks.map((block) {
                      return DraggableBlock(
                          key: ValueKey(block.id),
                          shape: block,
                          onDragEnd: () =>
                              setState(() => previewPoints.clear()));
                    }).toList(),
                  ),
                ),

                // BANNER REKLAM
                if (_isBannerAdReady)
                  Container(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    alignment: Alignment.center,
                    child: AdWidget(ad: _bannerAd!),
                  )
                else
                  const SizedBox(height: 50),
              ],
            ),
          ),

          // UÇAN YAZILAR
          IgnorePointer(
              child: Stack(
                  children: floatingTexts
                      .map((ft) => _buildFloatingText(ft))
                      .toList())),

          if (isPaused)
            _buildOverlay(title: "PAUSED", buttons: [
              NeoButton(
                  text: "RESUME",
                  color: Colors.cyanAccent,
                  onTap: () => setState(() => isPaused = false)),
              const SizedBox(height: 15),
              NeoButton(
                  text: "RESTART",
                  color: Colors.purpleAccent,
                  onTap: _startNewGame),
            ]),

          if (isGameOver) _buildGameOverOverlay(),
        ],
      ),
    );
  }

  // UI YARDIMCILARI
  Widget _buildFloatingText(FloatingText ft) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Positioned(
          left: ft.position.dx,
          top: ft.position.dy - (value * 80),
          child: Opacity(
            opacity: 1.0 - value,
            child: Text(ft.text,
                style: GoogleFonts.orbitron(
                    fontSize: ft.fontSize,
                    color: ft.color,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: ft.color, blurRadius: 10)])),
          ),
        );
      },
    );
  }

  Widget _buildGridCell(int r, int c) {
    bool isPreview = previewPoints.any((p) => p.x == r && p.y == c);
    bool isClearing = clearingRows.contains(r) || clearingCols.contains(c);
    Color? cellColor = grid[r][c];
    Color color = const Color(0xFF202235);
    List<BoxShadow> shadows = [];
    Border? border = Border.all(color: Colors.white.withOpacity(0.04));

    if (isPreview) {
      color = isValidMove
          ? Colors.white.withOpacity(0.2)
          : Colors.red.withOpacity(0.2);
      border = Border.all(color: Colors.white.withOpacity(0.5));
    } else if (cellColor != null) {
      color = isClearing ? Colors.white : cellColor;
      shadows = [
        BoxShadow(
            color: isClearing ? Colors.white : cellColor.withOpacity(0.6),
            blurRadius: isClearing ? 20 : 8,
            spreadRadius: isClearing ? 5 : 0)
      ];
      border = null;
    }

    return DragTarget<BlockModel>(
      onMove: (details) => onHoverShape(details.data, r, c),
      onLeave: (_) {},
      onAccept: (shape) {
        if (isValidMove)
          placeShape(shape, r, c);
        else
          setState(() => previewPoints.clear());
      },
      builder: (context, _, __) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isClearing ? 0 : 32,
          height: isClearing ? 0 : 32,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: border,
              boxShadow: shadows)),
    );
  }

  Widget _buildGameOverOverlay() {
    return Stack(
      children: [
        BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: const Color(0xFF0F101E).withOpacity(0.9))),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    padding: const EdgeInsets.all(20),
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, boxShadow: [
                      BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.2),
                          blurRadius: 40,
                          spreadRadius: 10)
                    ]),
                    child: const Icon(Icons.videogame_asset_outlined,
                        size: 60, color: Colors.cyanAccent)),
                const SizedBox(height: 20),
                Text("GAME",
                    style: GoogleFonts.orbitron(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.0)),
                Text("OVER",
                    style: GoogleFonts.orbitron(
                        fontSize: 40,
                        color: Colors.pinkAccent,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                        shadows: [
                          const Shadow(color: Colors.pink, blurRadius: 20)
                        ])),
                const SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  decoration: BoxDecoration(
                      color: const Color(0xFF16182B),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.cyanAccent.withOpacity(0.1),
                            blurRadius: 20)
                      ]),
                  child: Column(children: [
                    const Text("FINAL SCORE",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            letterSpacing: 2)),
                    const SizedBox(height: 5),
                    Text("$score",
                        style: GoogleFonts.orbitron(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    const Divider(color: Colors.white10, height: 30),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.emoji_events,
                          color: Colors.amber, size: 18),
                      const SizedBox(width: 8),
                      Text("BEST: $bestScore",
                          style: const TextStyle(
                              color: Colors.amber, fontSize: 16))
                    ])
                  ]),
                ),
                const SizedBox(height: 30),
                if (!hasRevived) ...[
                  NeoButton(
                      text: "WATCH AD & REVIVE",
                      icon: Icons.play_circle_fill,
                      color: Colors.greenAccent,
                      onTap: _showRewardedAd),
                  const SizedBox(height: 15),
                ],
                NeoButton(
                    text: "PLAY AGAIN",
                    color: Colors.cyanAccent,
                    onTap: _startNewGame),
                const SizedBox(height: 15),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Row(mainAxisSize: MainAxisSize.min, children: const [
                      Icon(Icons.home, color: Colors.white54, size: 18),
                      SizedBox(width: 8),
                      Text("MAIN MENU",
                          style: TextStyle(
                              color: Colors.white54, letterSpacing: 1))
                    ]))
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverlay({required String title, required List<Widget> buttons}) {
    return Stack(children: [
      BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.black.withOpacity(0.7))),
      Center(
          child: Container(
              width: 300,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                  color: const Color(0xFF1E2032),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.purpleAccent.withOpacity(0.2),
                        blurRadius: 40,
                        spreadRadius: 5)
                  ]),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(title,
                    style: GoogleFonts.orbitron(
                        color: Colors.cyanAccent,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        shadows: [
                          const Shadow(color: Colors.cyan, blurRadius: 15)
                        ])),
                const SizedBox(height: 30),
                ...buttons
              ])))
    ]);
  }
}
