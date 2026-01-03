import 'package:hive/hive.dart';

part 'score_model.g.dart'; // build_runner ile oluşturulacak

@HiveType(typeId: 0)
class ScoreModel extends HiveObject {
  @HiveField(0)
  final int score;

  @HiveField(1)
  final DateTime date;

  ScoreModel({required this.score, required this.date});
}