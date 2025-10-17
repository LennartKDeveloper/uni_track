import 'package:flutter/material.dart';

class SwitchSettingTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final TextStyle? titleTextStyle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SwitchSettingTile({
    super.key,
    required this.leading,
    required this.title,
    this.titleTextStyle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style:
                  titleTextStyle ?? Theme.of(context).textTheme.displayMedium,
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
