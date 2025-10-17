import 'package:flutter/material.dart';
import 'package:uni_track/features/home/data/hive_handler.dart';
import 'package:uni_track/features/home/models/hive_modul.dart';
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
          child: Text(
            'Woche: ${monday.day}.${monday.month} - ${sunday.day}.${sunday.month}',
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
            onCompletedChanged: (value) {
              setState(() {
                wm.isCompleted = value ?? false;
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
                if (wm.importance == Importance.red) {
                  wm.importance = Importance.yellow;
                } else if (wm.importance == Importance.yellow) {
                  wm.importance = Importance.green;
                } else {
                  wm.importance = Importance.red;
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
