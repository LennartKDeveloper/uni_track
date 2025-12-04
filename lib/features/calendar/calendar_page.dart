import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_track/features/calendar/timetable_event.dart';

// --- DATENMODELL ---

// --- HAUPTWIDGET ---

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // Konfiguration
  final int _startHour = 8;
  final int _endHour = 20;
  final double _hourHeight = 60.0;
  final List<String> _weekDays = ['Mo', 'Di', 'Mi', 'Do', 'Fr'];

  // State
  List<TimetableEvent> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  // --- LOGIK: LADEN, SPEICHERN, PRÜFEN ---

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventsJson = prefs.getString('timetable_events');
    if (eventsJson != null) {
      final List<dynamic> decoded = jsonDecode(eventsJson);
      setState(() {
        _events = decoded.map((e) => TimetableEvent.fromMap(e)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_events.map((e) => e.toMap()).toList());
    await prefs.setString('timetable_events', encoded);
  }

  // Prüft auf Überschneidungen
  // excludeId: Wird beim Bearbeiten benötigt, damit das Event nicht mit sich selbst kollidiert
  bool _hasOverlap(
    int dayIndex,
    double start,
    double end, {
    String? excludeId,
  }) {
    for (final event in _events) {
      if (event.id == excludeId) continue; // Sich selbst ignorieren
      if (event.dayIndex != dayIndex) continue; // Anderer Tag

      double eventEnd = event.startHour + event.duration;

      // Logik: (StartA < EndB) und (EndA > StartB) bedeutet Überlappung
      if (start < eventEnd && end > event.startHour) {
        return true;
      }
    }
    return false;
  }

  void _addOrUpdateEvent(TimetableEvent newEvent) {
    setState(() {
      // Falls wir bearbeiten (ID existiert schon), altes entfernen
      _events.removeWhere((e) => e.id == newEvent.id);
      _events.add(newEvent);
    });
    _saveEvents();
  }

  void _deleteEvent(String id) {
    setState(() {
      _events.removeWhere((e) => e.id == id);
    });
    _saveEvents();
  }

  // --- DIALOG FÜR NEUE / BEARBEITEN ---

  void _showEventDialog(
    BuildContext context, {
    required int dayIndex,
    double? startHourSuggestion,
    TimetableEvent? existingEvent, // Wenn gesetzt, sind wir im "Edit Mode"
  }) {
    final bool isEditing = existingEvent != null;

    // Startwerte ermitteln
    double initialStart =
        existingEvent?.startHour ??
        startHourSuggestion ??
        _startHour.toDouble();
    if (!isEditing) {
      initialStart = initialStart
          .floorToDouble(); // Beim Neuanlegen auf volle Stunde runden
      if (initialStart < _startHour) initialStart = _startHour.toDouble();
      if (initialStart >= _endHour) initialStart = (_endHour - 1).toDouble();
    }

    double initialDuration = existingEvent?.duration ?? 1.0;

    // Controller & State für Dialog
    final titleController = TextEditingController(
      text: existingEvent?.title ?? "",
    );
    final roomController = TextEditingController(
      text: existingEvent?.room ?? "",
    );

    double start = initialStart;
    double end = initialStart + initialDuration;
    Color selectedColor = existingEvent != null
        ? Color(existingEvent.colorValue)
        : Theme.of(context).colorScheme.primary;

    final List<Color> colors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.error,
      Colors.green,
      Colors.orange,
      Colors.purpleAccent,
      Colors.teal,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing
                            ? "Termin bearbeiten"
                            : "Neuer Termin (${_weekDays[dayIndex]})",
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (isEditing)
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () {
                            // Dialog schließen
                            Navigator.pop(context);
                            // Event löschen
                            _deleteEvent(existingEvent.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Termin gelöscht"),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Titel
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: "Titel (z.B. Mathe)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surface.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Raum
                  TextField(
                    controller: roomController,
                    decoration: InputDecoration(
                      labelText: "Raum (z.B. H101)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surface.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Zeit Slider
                  Text("Zeitraum: ${_formatTime(start)} - ${_formatTime(end)}"),
                  RangeSlider(
                    values: RangeValues(start, end),
                    min: _startHour.toDouble(),
                    max: _endHour.toDouble(),
                    divisions: (_endHour - _startHour) * 2, // 30 Min Schritte
                    labels: RangeLabels(_formatTime(start), _formatTime(end)),
                    onChanged: (values) {
                      if (values.end - values.start >= 0.5) {
                        // Mind. 30 Min
                        setModalState(() {
                          start = values.start;
                          end = values.end;
                        });
                      }
                    },
                  ),

                  // Farbe
                  const SizedBox(height: 12),
                  const Text("Farbe"),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: colors.map((c) {
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedColor = c),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: selectedColor == c
                                ? Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: selectedColor == c
                              ? Icon(
                                  Icons.check,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  size: 20,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Speichern Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (titleController.text.isEmpty) return;

                        // 1. Überschneidung prüfen
                        if (_hasOverlap(
                          dayIndex,
                          start,
                          end,
                          excludeId: existingEvent?.id,
                        )) {
                          // Fehlermeldung zeigen
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Achtung: Zeitüberschneidung!"),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                            ),
                          );
                          return; // Nicht speichern
                        }

                        // 2. Speichern
                        _addOrUpdateEvent(
                          TimetableEvent(
                            id:
                                existingEvent?.id ??
                                DateTime.now().toIso8601String(),
                            title: titleController.text,
                            room: roomController.text,
                            dayIndex: dayIndex,
                            startHour: start,
                            duration: end - start,
                            colorValue: selectedColor.value,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: Text(
                        isEditing ? "Änderungen speichern" : "Erstellen",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Gap(20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- UI HELPER ---

  String _formatTime(double hour) {
    int h = hour.floor();
    int m = ((hour - h) * 60).round();
    return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 50),
                  ...List.generate(
                    5,
                    (index) => Expanded(
                      child: Center(
                        child: Text(
                          _weekDays[index],
                          style: Theme.of(context).textTheme.displayMedium!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).textTheme.labelMedium!.color,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // GRID
            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  height: (_endHour - _startHour) * _hourHeight,
                  child: Stack(
                    children: [
                      // 1. Hintergrund-Linien & Zeit
                      Column(
                        children: List.generate(_endHour - _startHour, (index) {
                          return SizedBox(
                            height: _hourHeight,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 50,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 5,
                                      right: 8,
                                    ),
                                    child: Text(
                                      "${_startHour + index}:00",
                                      textAlign: TextAlign.right,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(fontSize: 12),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: Theme.of(
                                            context,
                                          ).dividerColor.withOpacity(0.2),
                                        ),
                                        left: BorderSide(
                                          color: Theme.of(
                                            context,
                                          ).dividerColor.withOpacity(0.2),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),

                      // 2. Vertikale Tag-Trenner
                      Row(
                        children: [
                          const SizedBox(width: 50),
                          ...List.generate(
                            5,
                            (index) => Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      color: Colors.grey.withOpacity(0.1),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 3. INTERAKTIONS-LAYER FÜR NEUE TERMINE (Hintergrund-Klicks)
                      // WICHTIG: Dies muss VOR den Events im Stack kommen (also weiter unten im Code),
                      // oder wir müssen sicherstellen, dass Events drüber liegen.
                      // Hier legen wir den "leeren" Klickbereich zuerst, damit Events (die später kommen) darüber liegen.
                      Row(
                        children: [
                          const SizedBox(width: 50),
                          ...List.generate(5, (dayIndex) {
                            return Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTapUp: (details) {
                                  final double y = details.localPosition.dy;
                                  final double clickedHour =
                                      _startHour + (y / _hourHeight);
                                  // Dialog für NEUEN Termin
                                  _showEventDialog(
                                    context,
                                    dayIndex: dayIndex,
                                    startHourSuggestion: clickedHour,
                                  );
                                },
                                child: Container(color: Colors.transparent),
                              ),
                            );
                          }),
                        ],
                      ),

                      // 4. DIE EVENTS (Drübergelegt, damit sie klickbar sind)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final double dayWidth =
                              (constraints.maxWidth - 50) / 5;

                          return Stack(
                            children: _events.map((event) {
                              return Positioned(
                                left: 50 + (event.dayIndex * dayWidth),
                                top:
                                    (event.startHour - _startHour) *
                                    _hourHeight,
                                width: dayWidth - 2,
                                height: event.duration * _hourHeight,
                                child: GestureDetector(
                                  onTap: () {
                                    // Dialog zum BEARBEITEN
                                    _showEventDialog(
                                      context,
                                      dayIndex: event.dayIndex,
                                      existingEvent: event,
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.all(1),
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Color(event.colorValue),
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(
                                            context,
                                          ).shadowColor.withOpacity(0.2),
                                          blurRadius: 2,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (event.duration > 0.5) ...[
                                          // Nur anzeigen wenn genug Platz
                                          const SizedBox(height: 2),
                                          Text(
                                            event.room,
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.9,
                                              ),
                                              fontSize: 10,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
