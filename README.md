# myapp

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


lib/
├── core/
│   ├── constants/       # Sabitler (Strings, Assets yolları)
│   ├── storage/         # Hive (Local Database)
│   └── theme/           # Renkler ve Font ayarları
│
├── features/
│   ├── game/            # OYUN MODÜLÜ
│   │   ├── data/
│   │   ├── domain/      # Modeller (Block, Grid vb.)
│   │   └── presentation/
│   │       ├── pages/
│   │       ├── providers/
│   │       └── widgets/
│   │
│   └── leaderboard/     # SKOR TABLOSU MODÜLÜ
│       ├── data/
│       └── presentation/
│
└── main.dart