import 'dart:io';
import 'package:flutter/foundation.dart';

class AdHelper {
  // Banner Reklam ID (Test ID)
  static String get bannerAdUnitId {
    if (kIsWeb) return ''; 
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    } else {
      return '';
    }
  }

  // Ödüllü Reklam ID (Test ID)
  static String get rewardedAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    } else {
      return '';
    }
  }
}