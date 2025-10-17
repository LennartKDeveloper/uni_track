import 'package:hive/hive.dart';
import 'package:uni_track/features/home/models/hive_modul.dart';
import 'package:uni_track/features/home/models/hive_weekly_modul.dart';

class HiveManager {
  static final HiveManager _instance = HiveManager._internal();
  factory HiveManager() => _instance;
  HiveManager._internal();

  // Use lazy getters that access the boxes opened in main.dart.
  // main.dart opens: 'hive_modul' and 'hive_weekly_modul'
  Box<Module> get moduleBox => Hive.box<Module>('hive_modul');
  Box<WeeklyModule> get weeklyBox =>
      Hive.box<WeeklyModule>('hive_weekly_modul');

  Future<void> init() async {
    // Open boxes with the same names used in main.dart (safe to call multiple times).
    await Hive.openBox<Module>('hive_modul');
    await Hive.openBox<WeeklyModule>('hive_weekly_modul');
    await ensureCurrentWeekData();
  }

  DateTime getWeekStart(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return DateTime(
      monday.year,
      monday.month,
      monday.day,
    ); // Zeitanteil nullen!
  }

  Future<void> ensureCurrentWeekData() async {
    final now = DateTime.now();
    final monday = getWeekStart(now);

    final existingWeeks = weeklyBox.values
        .map((w) => getWeekStart(w.weekStart))
        .toSet();

    if (!existingWeeks.contains(monday)) {
      // finde letzte Woche
      final lastWeek = existingWeeks.isNotEmpty
          ? existingWeeks.reduce((a, b) => a.isAfter(b) ? a : b)
          : monday.subtract(Duration(days: 7));

      // Module der letzten Woche kopieren
      final lastWeekModules = weeklyBox.values
          .where((w) => getWeekStart(w.weekStart) == lastWeek)
          .toList();

      if (lastWeekModules.isEmpty) {
        // falls es noch keine Module gibt -> erstmal nur leere Module
        for (var module in moduleBox.values) {
          weeklyBox.add(WeeklyModule(weekStart: monday, module: module));
        }
      } else {
        for (var old in lastWeekModules) {
          weeklyBox.add(
            WeeklyModule(
              weekStart: monday,
              module: old.module,
              importance: old.importance,
            ),
          );
        }
      }
    }
  }

  List<WeeklyModule> getWeeklyModules(DateTime weekStart) {
    final monday = getWeekStart(weekStart);
    return weeklyBox.values
        .where((w) => getWeekStart(w.weekStart) == monday)
        .toList();
  }

  Future<void> addModule(String name, String link) async {
    final module = Module(name: name, link: link);
    await moduleBox.add(module);

    // Alle Wochen, in denen schon Module existieren
    final weeks = weeklyBox.values
        .map((w) => getWeekStart(w.weekStart))
        .toSet();
    print(weeks);
    // Falls keine Wochen existieren, aktuelle Woche anlegen
    if (weeks.isEmpty) {
      final currentMonday = getWeekStart(DateTime.now());
      weeks.add(currentMonday);
    }

    // Modul zu allen Wochen hinzufügen
    for (var week in weeks) {
      weeklyBox.add(WeeklyModule(weekStart: week, module: module));
    }
  }

  Future<void> deleteWeeklyModule(WeeklyModule wm) async {
    await wm.delete();
  }

  Future<void> updateWeeklyModule(WeeklyModule wm) async {
    await wm.save();
  }
}
