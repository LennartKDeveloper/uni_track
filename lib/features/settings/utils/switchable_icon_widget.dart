import 'package:flutter/material.dart';

class SwitchableIconWidget extends StatelessWidget {
  final IconData icon;
  final IconData icon2;
  final Color color;
  final bool state;

  const SwitchableIconWidget({
    super.key,
    required this.color,
    required this.icon,
    required this.icon2,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (!state) {
      return Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: Icon(icon, color: Theme.of(context).colorScheme.onPrimary),
      );
    } else {
      return Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: Icon(icon2, color: Theme.of(context).colorScheme.onPrimary),
      );
    }
  }
}
