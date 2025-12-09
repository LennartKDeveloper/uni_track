import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:uni_track/features/home/data/hive_handler.dart';
import 'package:uni_track/features/home/models/hive_weekly_modul.dart';

import 'package:uni_track/features/home/utils/send_snackbar.dart';
import 'package:uni_track/features/home/utils/weekly_modul_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedWeek = DateTime.now();
  final hiveManager = HiveManager();
  late List<WeeklyModule> modules;

  // Keys einmalig definieren
  final GlobalKey linkKey = GlobalKey();
  final GlobalKey linkButtonKey = GlobalKey();
  final GlobalKey lectureButtonKey = GlobalKey();
  final GlobalKey taskButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    hiveManager.ensureCurrentWeekData().then((_) => setState(() {}));
    // HIER KEIN TUTORIAL AUFRUF MEHR!
  }

  // Diese Funktion wird vom Add-Button aufgerufen
  Future<void> _checkAndShowTutorialAfterAdd() async {
    WidgetsFlutterBinding.ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    final alreadyShown = prefs.getBool('navigationTutorialShown') ?? false;

    if (!alreadyShown) {
      // WICHTIG: Warten, damit das neue Widget gerendert ist
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return; // Check ob Screen noch da ist

      showTutorial();
      await prefs.setBool('navigationTutorialShown', true);
    }
  }

  void showTutorial() {
    TextStyle txtstyle = Theme.of(
      context,
    ).textTheme.displayLarge!.copyWith(fontSize: 18, color: Colors.white);
    List<TargetFocus> targets = [];
    targets.addAll([
      TargetFocus(
        identify: "Text",
        keyTarget: linkKey,
        shape: ShapeLightFocus.RRect,
        radius: 15,
        paddingFocus: 5,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Text(
              "Füge hier den Link zu deinen Unterlagen hinzu",
              style: txtstyle,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "IconButton",
        keyTarget: linkButtonKey,
        contents: [
          TargetContent(
            align: ContentAlign.right,
            child: Text(
              "um ihn über diesen Button zu öffnen !",
              style: txtstyle,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "FancyCheckBox",
        keyTarget: lectureButtonKey,
        contents: [
          TargetContent(
            align: ContentAlign.left,
            child: Text(
              "Markiere hier deine bearbeitete Vorlesung",
              style: txtstyle,
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "FancyCheckBox",
        keyTarget: taskButtonKey,
        contents: [
          TargetContent(
            align: ContentAlign.left,
            child: Text("und hier deine fertige Übung !", style: txtstyle),
          ),
        ],
      ),
    ]);

    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black.withOpacity(0.8),
      textSkip: "Überspringen",
      textStyleSkip: Theme.of(
        context,
      ).textTheme.displayLarge!.copyWith(fontSize: 16, color: Colors.white),
      onSkip: () {
        sendSnackbar(
          context,
          Theme.of(context).textTheme.displayMedium?.color ?? Colors.black,
          "Los gehts !",
        );
        return true;
      },
      onFinish: () => sendSnackbar(
        context,
        Theme.of(context).textTheme.displayMedium?.color ?? Colors.black,
        "Los gehts !",
      ),
    ).show(context: context);
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
          if (oldIndex >= modules.length) return;

          setState(() {
            if (newIndex > oldIndex) newIndex -= 1;
            if (newIndex >= modules.length) newIndex = modules.length - 1;

            final item = modules.removeAt(oldIndex);
            modules.insert(newIndex, item);

            for (int i = 0; i < modules.length; i++) {
              final wm = modules[i];
              if (wm.sortOrder != i) {
                wm.sortOrder = i;
                hiveManager.updateWeeklyModule(wm);
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
                _checkAndShowTutorialAfterAdd();
              },
              child: Container(
                padding: EdgeInsets.all(3),
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
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

          // NUR DAS ERSTE ELEMENT BEKOMMT DIE KEYS
          final bool isFirstItem = index == 0;

          return WeeklyModuleCard(
            linkKey: isFirstItem ? linkKey : null,
            linkButtonKey: isFirstItem ? linkButtonKey : null,
            lectureButtonKey: isFirstItem ? lectureButtonKey : null,
            taskButtonKey: isFirstItem ? taskButtonKey : null,

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
