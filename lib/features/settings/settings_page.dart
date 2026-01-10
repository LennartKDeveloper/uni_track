import 'package:flutter/material.dart';

import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:uni_track/features/settings/utils/data_download_alert.dart';
import 'package:uni_track/features/settings/utils/icon_widget.dart';
import 'package:uni_track/features/settings/utils/settings_group.dart';
import 'package:uni_track/features/settings/utils/simple_settings_tile.dart';
import 'package:uni_track/features/settings/utils/switch_settings_tile.dart';
import 'package:uni_track/features/settings/utils/switchable_icon_widget.dart';
import 'package:uni_track/themes/theme_notifier.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isTopOrder = false;
  bool isReward = false;
  bool isNotification = false;
  bool isMessage = false;
  bool isguest = false;

  void act() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(24),
          children: [
            SettingsGroup(
              title: "ALLGEMEIN",
              children: <Widget>[buildDarkMode(), buildNotificationSwitch()],
            ),

            Gap(20),
            SettingsGroup(
              title: "HILFE",
              children: <Widget>[Gap(10), buildMassageTile()],
            ),

            Gap(20),
            SettingsGroup(
              title: "SUPPORT",
              children: <Widget>[Gap(10), buildDonationTile()],
            ),

            Gap(20),
          ],
        ),
      ),
    );
  }

  Widget buildDarkMode() => SwitchSettingTile(
    leading: IconWidget(icon: Icons.dark_mode, color: Colors.deepPurple),
    title: "Dunkler Modus",

    value: Provider.of<ThemeNotifier>(context).themeMode == ThemeMode.dark,

    onChanged: (_) =>
        Provider.of<ThemeNotifier>(context, listen: false).toggleTheme(),
  );

  Widget buildNotificationSwitch() => SwitchSettingTile(
    value: isNotification,
    leading: IconWidget(
      icon: Icons.text_snippet_rounded,
      color: Colors.yellow.shade700,
    ),
    title: "Benachrichtigungen",

    onChanged: (isNews) {
      isNotification = isNews;
      act();
    },
  );

  Widget buildMassageTile() => SimpleSettingTile(
    leading: IconWidget(
      icon: Icons.email_rounded,
      color: Colors.green.shade800,
    ),
    title: "Nachricht",

    subtitle: "Email dem Entwickler",
    onTap: () {
      String? encodeQueryParameters(Map<String, String> params) {
        return params.entries
            .map(
              (MapEntry<String, String> e) =>
                  '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
            )
            .join('&');
      }

      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'infinity.tasks.feedback@gmail.com',
        query: encodeQueryParameters(<String, String>{
          'subject': "Developer Support",
        }),
      );
      launchUrl(emailLaunchUri);
    },
  );

  Widget buildDonationTile() => SimpleSettingTile(
    leading: IconWidget(icon: Icons.paypal_rounded, color: Colors.lightBlue),
    title: "Spende",

    subtitle: "Supporte den Entwickler",
    onTap: () {
      launchUrl(
        Uri.parse(
          "https://www.paypal.com/donate/?hosted_button_id=3DABQ3TSQ2YGN",
        ),
      );
    },
  );
}
