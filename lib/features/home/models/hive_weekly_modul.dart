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

  // Ändere Typ von Importance -> int (1 = rot, 2 = gelb, 3 = grün)
  @HiveField(3)
  int importance;

  WeeklyModule({
    required this.weekStart,
    required this.module,
    this.isCompleted = false,
    this.importance = 3, // default: 1 (rot)
  });
}
