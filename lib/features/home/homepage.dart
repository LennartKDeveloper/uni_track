import 'package:flutter/material.dart';
import 'package:uni_track/features/home/data/hive_handler.dart';
import 'package:uni_track/features/home/models/hive_weekly_modul.dart';
import 'package:uni_track/features/home/utils/modul_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedWeek = DateTime.now();
  final hiveManager = HiveManager();
  late List<WeeklyModule> modules;

  @override
  void initState() {
    super.initState();
    hiveManager.ensureCurrentWeekData().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final monday = hiveManager.getWeekStart(selectedWeek);
    final sunday = monday.add(const Duration(days: 6));
    modules = hiveManager.getWeeklyModules(selectedWeek);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: false,
        title: GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              locale: const Locale("de", "DE"),
              initialDate: selectedWeek,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() => selectedWeek = picked);
            }
          },
          child: Container(
            margin: EdgeInsets.only(left: 12, top: 20),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Woche: ${monday.day}.${monday.month} - ${sunday.day}.${sunday.month}',
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_outlined,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        itemCount: modules.length + 1,
        onReorder: (oldIndex, newIndex) {
          // Verhindern, dass der Add-Button (Index = length) verschoben wird
          if (oldIndex >= modules.length) return;

          setState(() {
            // Flutter Reorder Logic Fix
            if (newIndex > oldIndex) newIndex -= 1;

            // Verhindern, dass Items HINTER den Add-Button geschoben werden
            if (newIndex >= modules.length) newIndex = modules.length - 1;

            // Liste lokal aktualisieren
            final item = modules.removeAt(oldIndex);
            modules.insert(newIndex, item);

            // NEU: Die neue Position in Hive speichern
            for (int i = 0; i < modules.length; i++) {
              final wm = modules[i];
              if (wm.sortOrder != i) {
                wm.sortOrder = i;
                hiveManager.updateWeeklyModule(wm); // Speichert in DB
              }
            }
          });
        },
        itemBuilder: (context, index) {
          if (index == modules.length) {
            return GestureDetector(
              key: const ValueKey('add_button'),
              onTap: () async {
                await hiveManager.addModule('Neues Modul', '');
                await hiveManager.ensureCurrentWeekData();
                setState(() {});
              },
              child: Container(
                padding: EdgeInsets.all(3),
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  //boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black12)],
                  border: Border.all(
                    color: Theme.of(context).colorScheme.onSurface,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            );
          }

          final wm = modules[index];

          return WeeklyModuleCard(
            key: ValueKey(wm.key ?? wm.hashCode),
            wm: wm,
            onLectureCompletedChanged: (value) {
              setState(() {
                wm.isLectureCompleted = value ?? false;
                hiveManager.updateWeeklyModule(wm);
              });
            },
            onTaskCompletedChanged: (value) {
              setState(() {
                wm.isTaskCompleted = value ?? false;
                hiveManager.updateWeeklyModule(wm);
              });
            },
            onNameChanged: (newName) {
              wm.module.name = newName;
              hiveManager.updateWeeklyModule(wm);
            },
            onLinkChanged: (newLink) {
              wm.module.link = newLink;
              hiveManager.updateWeeklyModule(wm);
            },
            onCycleImportance: () {
              setState(() {
                // cycle: 1 -> 2 -> 3 -> 1
                if (wm.importance == 1) {
                  wm.importance = 2;
                } else if (wm.importance == 2) {
                  wm.importance = 3;
                } else {
                  wm.importance = 1;
                }
                hiveManager.updateWeeklyModule(wm);
              });
            },
            onDelete: () async {
              await hiveManager.deleteWeeklyModule(wm);
              setState(() {});
            },
          );
        },
      ),
    );
  }
}
