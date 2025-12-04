import 'package:flutter/material.dart';

class SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final TextStyle? titleTextStyle;
  final EdgeInsetsGeometry titlePadding;

  const SettingsGroup({
    super.key,
    required this.title,
    required this.children,
    this.titleTextStyle,
    this.titlePadding = const EdgeInsets.only(left: 12, top: 8, bottom: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Überschrift
        Padding(
          padding: titlePadding,
          child: Text(
            title,
            style:
                titleTextStyle ??
                TextStyle(
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        // Inhalte
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.05),
            //     blurRadius: 4,
            //     offset: const Offset(0, 2),
            //   ),
            // ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}
