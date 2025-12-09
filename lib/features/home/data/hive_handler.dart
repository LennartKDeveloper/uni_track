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
      // Finde letzte Woche
      final lastWeek = existingWeeks.isNotEmpty
          ? existingWeeks.reduce((a, b) => a.isAfter(b) ? a : b)
          : monday.subtract(Duration(days: 7));

      // Module der letzten Woche kopieren
      final lastWeekModules = weeklyBox.values
          .where((w) => getWeekStart(w.weekStart) == lastWeek)
          .toList();

      if (lastWeekModules.isEmpty) {
        // Fall A: Ganz frischer Start (noch gar keine Wochen-Daten)
        // Wir vergeben hier initial 0, 1, 2... als Reihenfolge
        int index = 0;
        for (var module in moduleBox.values) {
          weeklyBox.add(
            WeeklyModule(
              weekStart: monday,
              module: module,
              sortOrder: index++, // <--- NEU: Initial durchnummerieren
            ),
          );
        }
      } else {
        // Fall B: Kopie der letzten Woche
        for (var old in lastWeekModules) {
          weeklyBox.add(
            WeeklyModule(
              weekStart: monday,
              module: old.module,
              // WICHTIG: Die Sortierung der alten Woche übernehmen!
              sortOrder: old.sortOrder,
              // Status (Tasks) zurücksetzen, Wichtigkeit behalten
              importance: old.importance,
              isLectureCompleted: false,
              isTaskCompleted: false,
            ),
          );
        }
      }
    }
  }

  List<WeeklyModule> getWeeklyModules(DateTime weekStart) {
    final monday = getWeekStart(weekStart);
    final list = weeklyBox.values
        .where((w) => getWeekStart(w.weekStart) == monday)
        .toList();

    // NEU: Sortierung anwenden
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return list;
  }

  Future<void> addModule(String name, String link) async {
    final module = Module(name: name, link: link);
    await moduleBox.add(module);

    final weeks = weeklyBox.values
        .map((w) => getWeekStart(w.weekStart))
        .toSet();

    if (weeks.isEmpty) {
      weeks.add(getWeekStart(DateTime.now()));
    }

    for (var week in weeks) {
      // Hole alle Module dieser Woche, um den höchsten sortOrder zu finden
      final modulesInWeek = weeklyBox.values.where(
        (w) => getWeekStart(w.weekStart) == week,
      );

      // Bestimme den höchsten vorhandenen Index (oder -1 wenn leer)
      int maxSortOrder = -1;
      if (modulesInWeek.isNotEmpty) {
        // Wir mappen auf sortOrder und nehmen das Maximum
        maxSortOrder = modulesInWeek
            .map((m) => m.sortOrder)
            .reduce((curr, next) => curr > next ? curr : next);
      }

      // Neues Modul bekommt (max + 1), also landet es ganz unten
      weeklyBox.add(
        WeeklyModule(
          weekStart: week,
          module: module,
          sortOrder: maxSortOrder + 1, // <--- NEU
        ),
      );
    }
  }

  Future<void> deleteWeeklyModule(WeeklyModule wm) async {
    await wm.delete();
  }

  Future<void> updateWeeklyModule(WeeklyModule wm) async {
    await wm.save();
  }
}
