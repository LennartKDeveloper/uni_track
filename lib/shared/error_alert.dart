import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ErrorAlert extends StatelessWidget {
  const ErrorAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      content: SizedBox(
        height: 240,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Gap(15),
              Icon(Icons.wifi_off_rounded, size: 50),
              Gap(30),
              Text(
                "Kein Internet!",
                style: Theme.of(context).textTheme.displayLarge,
              ),
              Gap(15),
              Center(
                child: Text(
                  "Ups! Du hast scheinbar keine Internetverbindung...",
                  style: Theme.of(context).textTheme.labelMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              Gap(15),
            ],
          ),
        ),
      ),
    );
  }
}
