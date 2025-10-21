import 'package:flutter/material.dart';
import 'package:uni_track/features/home/models/hive_modul.dart';
import 'package:uni_track/features/home/models/hive_weekly_modul.dart';
import 'package:url_launcher/url_launcher.dart';

class WeeklyModuleCard extends StatefulWidget {
  final WeeklyModule wm;
  final ValueChanged<bool?> onCompletedChanged;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onLinkChanged;
  final VoidCallback onCycleImportance;
  final VoidCallback onDelete;

  const WeeklyModuleCard({
    super.key,
    required this.wm,
    required this.onCompletedChanged,
    required this.onNameChanged,
    required this.onLinkChanged,
    required this.onCycleImportance,
    required this.onDelete,
  });

  @override
  State<WeeklyModuleCard> createState() => _WeeklyModuleCardState();
}

class _WeeklyModuleCardState extends State<WeeklyModuleCard> {
  late TextEditingController nameController;
  late TextEditingController linkController;
  late FocusNode nameFocusNode;
  late FocusNode linkFocusNode;
  bool editingName = false;
  bool editingLink = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.wm.module.name);
    linkController = TextEditingController(text: widget.wm.module.link);

    nameFocusNode = FocusNode();
    linkFocusNode = FocusNode();

    nameFocusNode.addListener(() {
      if (!nameFocusNode.hasFocus && editingName) {
        setState(() => editingName = false);
        widget.onNameChanged(nameController.text);
      }
    });

    linkFocusNode.addListener(() {
      if (!linkFocusNode.hasFocus && editingLink) {
        setState(() => editingLink = false);
        widget.onLinkChanged(linkController.text);
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    linkController.dispose();
    nameFocusNode.dispose();
    linkFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = switch (widget.wm.importance) {
      Importance.red => Colors.red,
      Importance.yellow => Colors.orange,
      Importance.green => Colors.green,
    };

    return Container(
      key: widget.key,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        //boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black12)],
        border: Border.all(color: Colors.black, width: 1.2),
        borderRadius: BorderRadius.circular(12),
      ),
      // Wrap Row in IntrinsicHeight so the left stripe matches the content height
      child: IntrinsicHeight(
        child: Row(
          children: [
            // --- Left color stripe ---
            GestureDetector(
              onTap: widget.onCycleImportance,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Container(width: 11, color: color),
              ),
            ),

            // --- Main content ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Row + Delete Button
                    Row(
                      children: [
                        Expanded(
                          child: editingName
                              ? TextField(
                                  controller: nameController,
                                  focusNode: nameFocusNode,
                                  autofocus: true,
                                  onSubmitted: (val) {
                                    setState(() => editingName = false);
                                    widget.onNameChanged(val);
                                  },
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displayMedium,
                                  decoration: InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.black,
                                        width: 1.2,
                                      ), // 👈 Fokusfarbe
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    setState(() => editingName = true);
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(nameFocusNode);
                                  },
                                  child: Text(
                                    nameController.text,

                                    style: Theme.of(
                                      context,
                                    ).textTheme.displayMedium,
                                  ),
                                ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.grey[700],
                          onPressed: widget.onDelete,
                        ),
                      ],
                    ),

                    // Link Row
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.link),
                          onPressed: () async {
                            final url = linkController.text.trim();
                            if (url.isNotEmpty &&
                                await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url));
                            }
                          },
                        ),
                        Expanded(
                          child: editingLink
                              ? TextField(
                                  controller: linkController,
                                  focusNode: linkFocusNode,
                                  autofocus: true,
                                  onSubmitted: (val) {
                                    setState(() => editingLink = false);
                                    widget.onLinkChanged(val);
                                  },
                                  style: TextStyle(color: Colors.blue),
                                  decoration: InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                        width: 1.2,
                                      ),
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    setState(() => editingLink = true);
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(linkFocusNode);
                                  },
                                  child: Text(
                                    linkController.text.isEmpty
                                        ? 'Link hinzufügen'
                                        : linkController.text,
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
