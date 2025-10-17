import 'package:flutter/material.dart';

import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_act/slide_to_act.dart';
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

  String getCurrentUserEmail() {
    return "FAKE@gmail.com";
  }

  void showDataDownloadAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return DataDownloadAlert(
          currentUserEmail: getCurrentUserEmail(),
          callback: () {
            //FIXME: callback für Datadownload fehlt
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(24),
          children: [
            SettingsGroup(
              title: "GENERAL",
              children: <Widget>[
                // Widgets in ListView
                buildDarkMode(),
                buildNotificationSwitch(),
              ],
            ),

            Gap(20),
            SettingsGroup(
              title: "FUNCTION",
              children: <Widget>[
                // Widgets in ListView
                buildOrderSwitch(),
                buildRewardSwitch(),
              ],
            ),

            Gap(20),
            SettingsGroup(
              title: "HELP",
              children: <Widget>[
                // Widgets in ListView
                Gap(10),
                buildMassageTile(),
              ],
            ),

            Gap(20),
            SettingsGroup(
              title: "SUPPORT",
              children: <Widget>[
                // Widgets in ListView
                Gap(10),
                buildDonationTile(),
              ],
            ),

            Gap(20),
            SettingsGroup(
              title: "ACCOUNT",
              children: <Widget>[
                // Widgets in ListView
                Gap(10),

                buildDownloadTile(),

                buildLogInTile(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDarkMode() => SwitchSettingTile(
    leading: IconWidget(icon: Icons.dark_mode, color: Colors.deepPurple),
    title: "Dark Mode",

    // keep listening here (used during build)
    value: Provider.of<ThemeNotifier>(context).themeMode == ThemeMode.dark,
    // but do not listen inside the event handler — use listen: false
    onChanged: (_) =>
        Provider.of<ThemeNotifier>(context, listen: false).toggleTheme(),
  );

  Widget buildNotificationSwitch() => SwitchSettingTile(
    value: isNotification,
    leading: IconWidget(
      icon: Icons.text_snippet_rounded,
      color: Colors.yellow.shade700,
    ),
    title: "Allow Notifications",

    onChanged: (isNews) {
      isNotification = isNews;
      act();
    },
  );

  Widget buildOrderSwitch() => SwitchSettingTile(
    value: isTopOrder,
    leading: SwitchableIconWidget(
      state: isTopOrder,
      icon: Icons.vertical_align_bottom_rounded,
      icon2: Icons.vertical_align_top_rounded,
      color: Colors.blue,
    ),

    title: "Order for new Cards",
    onChanged: (order) {
      isTopOrder = order;
      act();
    },
  );

  Widget buildRewardSwitch() => SwitchSettingTile(
    value: isReward,
    leading: SwitchableIconWidget(
      state: isReward,
      icon: Icons.auto_fix_off_rounded,
      icon2: Icons.auto_fix_high,
      color: Colors.pinkAccent.shade700,
    ),

    title: "Rewards",
    onChanged: (reward) {
      isReward = reward;
      act();
    },
  );

  Widget buildMassageTile() => SimpleSettingTile(
    leading: IconWidget(
      icon: Icons.email_rounded,
      color: Colors.green.shade800,
    ),
    title: "Message",

    subtitle: "Email the Developer",
    onTap: () {
      String? encodeQueryParameters(Map<String, String> params) {
        return params.entries
            .map(
              (MapEntry<String, String> e) =>
                  '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
            )
            .join('&');
      }

      // ···
      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'infinity.tasks.feedback@gmail.com',
        query: encodeQueryParameters(<String, String>{
          //Betreff
          'subject': "Developer Support",
        }),
      );
      launchUrl(emailLaunchUri);
    },
  );

  Widget buildDonationTile() => SimpleSettingTile(
    leading: IconWidget(icon: Icons.paypal_rounded, color: Colors.lightBlue),
    title:
        "Donation"
        "Spende",

    subtitle: "Support the Developer",
    onTap: () {
      launchUrl(
        Uri.parse(
          "https://www.paypal.com/donate/?hosted_button_id=3DABQ3TSQ2YGN",
        ),
      );
      //Track Activity
    },
  );

  Widget buildDownloadTile() => SimpleSettingTile(
    leading: IconWidget(
      icon: Icons.cloud_download_rounded,
      color: Colors.greenAccent,
    ),
    title: "Download",
    subtitle: "secured data from the cloud",
    onTap: showDataDownloadAlert,
  );
  Widget buildLogInTile() => SimpleSettingTile(
    leading: IconWidget(
      icon: Icons.account_circle_rounded,
      color: isguest ? Colors.green : Colors.red,
    ),
    title: isguest ? "log in" : "Log out",
    subtitle: getCurrentUserEmail(),
    onTap: () {
      isguest = !isguest;
      act();
    },
  );
}
