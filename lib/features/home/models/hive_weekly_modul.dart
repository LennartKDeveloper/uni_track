import 'package:hive/hive.dart';
import 'package:uni_track/features/home/models/hive_modul.dart';
part 'hive_weekly_modul.g.dart';

@HiveType(typeId: 2)
class WeeklyModule extends HiveObject {
  @HiveField(0)
  DateTime weekStart; 

  @HiveField(1)
  Module module; 

  @HiveField(2)
  bool isLectureCompleted;

  
  @HiveField(3)
  int importance;

  @HiveField(4)
  bool isTaskCompleted;

  @HiveField(5)
  int sortOrder;

  WeeklyModule({
    required this.weekStart,
    required this.module,
    this.isLectureCompleted = false,
    this.isTaskCompleted = false,
    this.importance = 3, 
    this.sortOrder = 0,
  });
}
