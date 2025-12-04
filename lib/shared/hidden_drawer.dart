import 'package:flutter/material.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';
import 'package:uni_track/features/calendar/calendar_page.dart';
import 'package:uni_track/features/documents/ducuments_page.dart';
import 'package:uni_track/features/home/homepage.dart';

import 'package:uni_track/features/settings/settings_page.dart';

class HiddenDrawer extends StatefulWidget {
  const HiddenDrawer({super.key});

  @override
  State<HiddenDrawer> createState() => _HiddenDrawerState();
}

class _HiddenDrawerState extends State<HiddenDrawer> {
  int _selectedIndex = 0; // Index der ausgewählten Seite

  void _updateIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Diese Methode aktualisiert den Zustand aller Seiten
  void refreshAllPages() {
    setState(() {
      // Du kannst hier andere Logiken hinzufügen, um alle Seiten zu aktualisieren
      // Seiten neu bauen (werden im build() generiert)
    });
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.displayLarge!.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.white,
    );

    final pages = [
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: "Module",
          baseStyle: textStyle,
          selectedStyle: textStyle,
          colorLineSelected: Colors.transparent,
          onTap: () {
            _updateIndex(0);
          },
        ),
        HomePage(),
      ),
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: "Stundenplan",
          baseStyle: textStyle,
          selectedStyle: textStyle,
          colorLineSelected: Colors.transparent,
          onTap: () {
            _updateIndex(1);
          },
        ),
        CalendarPage(),
      ),
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: "Dokumente",
          baseStyle: textStyle,
          selectedStyle: textStyle,
          colorLineSelected: Colors.transparent,
          onTap: () {
            _updateIndex(2);
          },
        ),
        DocumentsPage(),
      ),
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: "Einstellungen",
          baseStyle: textStyle,
          selectedStyle: textStyle,
          colorLineSelected: Colors.transparent,
          onTap: () {
            _updateIndex(3);
          },
        ),
        SettingsPage(),
      ),
    ];
    return HiddenDrawerMenu(
      elevationAppBar: 0,
      backgroundColorAppBar: Theme.of(context).scaffoldBackgroundColor,
      backgroundColorMenu: Theme.of(context).canvasColor, //Hidden drawer Farbe
      screens: pages,
      initPositionSelected: 0,
      slidePercent: 40,
      styleAutoTittleName: Theme.of(context).textTheme.displayLarge,
      isTitleCentered: true,
      leadingAppBar: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Icon(Icons.menu_rounded),
      ),
    );
  }
}
