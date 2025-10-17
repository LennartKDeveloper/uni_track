import 'package:flutter/material.dart';
import 'package:uni_track/features/home/data/hive_handler.dart';
import 'package:uni_track/features/home/models/hive_modul.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedWeek = DateTime.now();
  final hiveManager = HiveManager();

  @override
  void initState() {
    super.initState();
    hiveManager.ensureCurrentWeekData().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final monday = hiveManager.getWeekStart(selectedWeek);
    final sunday = monday.add(Duration(days: 6));
    final modules = hiveManager.getWeeklyModules(selectedWeek);

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
      body: ListView.builder(
        itemCount: modules.length + 1,
        itemBuilder: (context, index) {
          if (index == modules.length) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  await hiveManager.addModule('Neues Modul', '');
                  setState(() {});
                },
                icon: const Icon(Icons.add),
                label: const Text('Modul hinzufügen'),
              ),
            );
          }

          final wm = modules[index];
          return Card(
            child: ListTile(
              leading: Checkbox(
                value: wm.isCompleted,
                onChanged: (value) {
                  setState(() {
                    wm.isCompleted = value!;
                    hiveManager.updateWeeklyModule(wm);
                  });
                },
              ),
              title: GestureDetector(
                onTap: () async {
                  final controller = TextEditingController(
                    text: wm.module.name,
                  );
                  final result = await showDialog<String>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Modulname bearbeiten'),
                      content: TextField(controller: controller),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, null),
                          child: const Text('Abbrechen'),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, controller.text),
                          child: const Text('Speichern'),
                        ),
                      ],
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      wm.module.name = result;
                      hiveManager.updateWeeklyModule(wm);
                    });
                  }
                },
                child: Text(wm.module.name),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Hier Link bearbeiten ähnlich wie oben
                    },
                    child: const Icon(Icons.link),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        // cycle importance
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
                    child: Container(
                      width: 20,
                      height: 20,
                      color: wm.importance == Importance.red
                          ? Colors.red
                          : wm.importance == Importance.yellow
                          ? Colors.yellow
                          : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
