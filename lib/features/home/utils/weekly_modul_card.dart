import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:uni_track/features/home/models/hive_weekly_modul.dart';
import 'package:uni_track/features/home/utils/fancy_checkbox.dart';
import 'package:uni_track/shared/error_alert.dart';
import 'package:url_launcher/url_launcher.dart';

class WeeklyModuleCard extends StatefulWidget {
  final WeeklyModule wm;

  final GlobalKey? linkKey;
  final GlobalKey? linkButtonKey;
  final GlobalKey? lectureButtonKey;
  final GlobalKey? taskButtonKey;

  final ValueChanged<bool?> onLectureCompletedChanged;
  final ValueChanged<bool?> onTaskCompletedChanged;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onLinkChanged;
  final VoidCallback onCycleImportance;
  final VoidCallback onDelete;

  const WeeklyModuleCard({
    super.key,
    required this.wm,
    required this.onNameChanged,
    required this.onLinkChanged,
    required this.onCycleImportance,
    required this.onDelete,
    required this.onLectureCompletedChanged,
    required this.onTaskCompletedChanged,

    this.linkKey,
    this.linkButtonKey,
    this.lectureButtonKey,
    this.taskButtonKey,
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
        closeOnScroll: false,
        endActionPane: ActionPane(
          motion: DrawerMotion(),
          children: [
            SlidableAction(
              borderRadius: BorderRadius.circular(12),
              onPressed: (context) => widget.onDelete(),
              icon: Icons.delete_outlined,
              label: "Delete",
              spacing: 10,
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          ],
        ),
        child: Container(
          key: widget.key,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.onCycleImportance,
                  child: Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: [
                      Container(color: Theme.of(context).colorScheme.surface),
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
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

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
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            width: 1.2,
                                          ),
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

                        
                        Row(
                          children: [
                            IconButton(
                              key: widget.linkButtonKey, 
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
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                      decoration: InputDecoration(
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
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
                                        key: widget.linkKey, 
                                        linkController.text.isEmpty
                                            ? 'Link hinzufügen'
                                            : linkController.text,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 110,
                  width: 70,
                  child: Column(
                    mainAxisAlignment: .spaceEvenly,
                    crossAxisAlignment: .center,
                    children: [
                      FancyCheckbox(
                        key: widget.lectureButtonKey, 
                        icon: Icons.book_outlined,
                        isChecked: widget.wm.isLectureCompleted,
                        onChanged: (value) =>
                            widget.onLectureCompletedChanged(value),
                        activeColor: Theme.of(context).colorScheme.primary,
                        inactiveBorderColor: Theme.of(
                          context,
                        ).colorScheme.secondary,
                        checkColor: Theme.of(
                          context,
                        ).colorScheme.inverseSurface,
                        size: 30,
                      ),

                      FancyCheckbox(
                        key: widget.taskButtonKey, 
                        icon: Icons.fitness_center_outlined,
                        isChecked: widget.wm.isTaskCompleted,
                        checkColor: Theme.of(
                          context,
                        ).colorScheme.inverseSurface,
                        onChanged: (value) =>
                            widget.onTaskCompletedChanged(value),
                        activeColor: Theme.of(context).colorScheme.primary,
                        inactiveBorderColor: Theme.of(
                          context,
                        ).colorScheme.secondary,
                        size: 30,
                      ),
                    ],
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
