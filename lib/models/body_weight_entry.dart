import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'body_weight_entry.g.dart';

/// A single body-weight measurement.
@HiveType(typeId: 26)
class BodyWeightEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double weight; // in kg

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String? note;

  BodyWeightEntry({
    String? id,
    required this.weight,
    DateTime? date,
    this.note,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();

  /// Day-bucketed key (yyyy-mm-dd) for grouping.
  String get dayKey =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
