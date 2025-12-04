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
        centerTitle: false,
        title: GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
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
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(Icons.arrow_drop_down_outlined, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        itemCount: modules.length + 1,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex -= 1;
            final item = modules.removeAt(oldIndex);
            modules.insert(newIndex, item);
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
                  color: Colors.white,
                  //boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black12)],
                  border: Border.all(color: Colors.black, width: 1.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.add),
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
