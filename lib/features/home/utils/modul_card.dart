import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:uni_track/features/home/models/hive_modul.dart';
import 'package:uni_track/features/home/models/hive_weekly_modul.dart';
import 'package:uni_track/features/home/utils/fancy_checkbox.dart';
import 'package:uni_track/shared/error_alert.dart';
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
    // Falls noch an anderen Stellen eine Farbe gewünscht ist, mappe hier:
    Color importanceColor;
    if (widget.wm.importance == 1) {
      importanceColor = Colors.red;
    } else if (widget.wm.importance == 2) {
      importanceColor = Colors.orange;
    } else {
      importanceColor = Colors.green;
    }

    double heightFactor;
    if (widget.wm.importance == 1) {
      heightFactor = 0.33;
    } else if (widget.wm.importance == 2) {
      heightFactor = 0.66;
    } else {
      heightFactor = 1;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Slidable(
        closeOnScroll: false, // Neccessary for ReorderableListview to Work
        endActionPane: ActionPane(
          motion: DrawerMotion(),
          children: [
            SlidableAction(
              borderRadius: BorderRadius.circular(12),
              onPressed: (context) => widget.onDelete(),
              icon: Icons.delete_outlined,
              label: "Delete",
              spacing: 10,
              backgroundColor: const Color.fromARGB(255, 181, 1, 1),
            ),
          ],
        ),
        child: Container(
          key: widget.key,
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
                // --- Left area: show importance as number (clickable to cycle) ---
                GestureDetector(
                  onTap: widget.onCycleImportance,
                  child: Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: [
                      Container(color: Colors.grey[200]),
                      SizedBox(
                        width: 13,
                        child: FractionallySizedBox(
                          alignment: Alignment.bottomCenter,
                          heightFactor: heightFactor,
                          child: Container(
                            width: 56,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: heightFactor == 1
                                    ? Radius.circular(9)
                                    : Radius.circular(0),
                                bottomLeft: Radius.circular(9),
                              ),
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                      mainAxisAlignment: MainAxisAlignment.center,
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
                          ],
                        ),

                        // Link Row
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.link),
                              onPressed: () async {
                                final url = linkController.text.trim();
                                try {
                                  await launchUrl(Uri.parse(url));
                                } catch (e) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return ErrorAlert();
                                    },
                                  );
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 40,
                  ),
                  child: FancyCheckbox(
                    isChecked: widget.wm.isCompleted,
                    onChanged: (value) => widget.onCompletedChanged(value),
                    activeColor: Theme.of(context).colorScheme.primary,
                    inactiveBorderColor: Theme.of(
                      context,
                    ).colorScheme.secondary,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
