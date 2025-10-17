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
    return date.subtract(Duration(days: date.weekday - 1));
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

    // Füge Modul zu allen existierenden Wochen hinzu.
    // Stelle außerdem sicher, dass das Modul in der aktuellen Woche vorhanden ist.
    final currentWeek = getWeekStart(DateTime.now());
    final weeks = weeklyBox.values
        .map((w) => getWeekStart(w.weekStart))
        .toSet();

    if (weeks.isEmpty) {
      // Keine Wochen vorhanden -> füge das Modul für die aktuelle Woche hinzu
      weeklyBox.add(WeeklyModule(weekStart: currentWeek, module: module));
    } else {
      // Für alle bekannten Wochen hinzufügen
      for (var week in weeks) {
        weeklyBox.add(WeeklyModule(weekStart: week, module: module));
      }
      // Wenn die aktuelle Woche noch nicht vorhanden ist, auch dort hinzufügen
      if (!weeks.contains(currentWeek)) {
        weeklyBox.add(WeeklyModule(weekStart: currentWeek, module: module));
      }
    }
  }

  Future<void> deleteWeeklyModule(WeeklyModule wm) async {
    await wm.delete();
  }

  Future<void> updateWeeklyModule(WeeklyModule wm) async {
    await wm.save();
  }
}
