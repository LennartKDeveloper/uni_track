import 'package:flutter/material.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';
import 'package:uni_track/features/home/homepage.dart';

import 'package:uni_track/features/settings/settings_page.dart';

class HiddenDrawer extends StatefulWidget {
  const HiddenDrawer({super.key});

  @override
  State<HiddenDrawer> createState() => _HiddenDrawerState();
}

class _HiddenDrawerState extends State<HiddenDrawer> {
  List<ScreenHiddenDrawer> _pages = [];
  int _selectedIndex = 0; // Index der ausgewählten Seite

  final myTextStyle = TextStyle(
    // Text Style vom Hidden Drawer menu
    fontWeight: FontWeight.bold,
    fontSize: 18,
    color: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    _loadPages();
  }

  void _loadPages() {
    _pages = [
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: "Übungen",
          baseStyle: myTextStyle,
          selectedStyle: myTextStyle,
          colorLineSelected: Colors.transparent,
          onTap: () {
            _updateIndex(0);
          },
        ),
        HomePage(),
      ),

      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: "Settings",
          baseStyle: myTextStyle,
          selectedStyle: myTextStyle,
          colorLineSelected: Colors.transparent,
          onTap: () {
            _updateIndex(3);
          },
        ),
        SettingsPage(),
      ),
    ];
  }

  void _updateIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Diese Methode aktualisiert den Zustand aller Seiten
  void refreshAllPages() {
    setState(() {
      // Du kannst hier andere Logiken hinzufügen, um alle Seiten zu aktualisieren
      _loadPages(); // Wenn du die Seiten neu laden möchtest
    });
  }

  @override
  Widget build(BuildContext context) {
    return HiddenDrawerMenu(
      elevationAppBar: 0,
      backgroundColorAppBar: Theme.of(context).scaffoldBackgroundColor,
      backgroundColorMenu: Theme.of(
        context,
      ).colorScheme.primary, //Hidden drawer Farbe
      screens: _pages,
      initPositionSelected: 0,
      slidePercent: 40,
      isTitleCentered: true,
      leadingAppBar: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Icon(Icons.menu_rounded),
      ),
    );
  }
}
