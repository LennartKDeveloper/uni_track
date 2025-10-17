import 'package:hive/hive.dart';
import 'package:uni_track/features/home/models/hive_modul.dart';
part 'hive_weekly_modul.g.dart';

@HiveType(typeId: 2)
class WeeklyModule extends HiveObject {
  @HiveField(0)
  DateTime weekStart; // Montag der Woche

  @HiveField(1)
  Module module; // Referenz auf das Modul

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  Importance importance;

  WeeklyModule({
    required this.weekStart,
    required this.module,
    this.isCompleted = false,
    this.importance = Importance.red,
  });
}
