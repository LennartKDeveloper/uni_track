import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:slide_to_act/slide_to_act.dart';

class DataDownloadAlert extends StatelessWidget {
  final String currentUserEmail;
  final VoidCallback callback;
  const DataDownloadAlert({
    super.key,
    required this.currentUserEmail,
    required this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      content: SizedBox(
        height: 340,
        child: Column(
          children: [
            Gap(15),
            Icon(Icons.cloud_download_rounded, size: 50),
            Gap(25),
            Text(
              "Are you sure?",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(25),
            Padding(
              padding: const EdgeInsets.only(right: 12, left: 12),
              child: Center(
                child: Text(
                  "If you send the data from the cloud to the email:  $currentUserEmail\nThis data will irretrievably overwrite all data stored on this device.",
                  style: TextStyle(color: Colors.grey.shade300),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Gap(25),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.tertiary,
                boxShadow: [
                  BoxShadow(
                    spreadRadius: -10,
                    blurRadius: 5,
                    offset: Offset(-2, -2),
                    color: Theme.of(context).colorScheme.shadow,
                  ),
                  BoxShadow(
                    spreadRadius: -1,
                    blurRadius: 5,
                    offset: Offset(2, 2),
                    color: Theme.of(context).colorScheme.shadow,
                  ),
                ],
              ),

              child: SlideAction(
                sliderRotate: false,
                height: 50,
                sliderButtonIconPadding: 10,
                sliderButtonIconSize: 20,
                innerColor: Colors.white,
                outerColor: Colors.red.shade700,
                sliderButtonIcon: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red.shade700,
                  size: 25,
                ),
                borderRadius: 12,

                text: "Slide to execute",
                textStyle: TextStyle(fontSize: 16, color: Colors.white),
                onSubmit: () async {
                  callback();
                },
              ),
            ),
          ],
        ),
      ),
    );
    ;
  }
}
