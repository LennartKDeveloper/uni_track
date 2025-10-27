import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uni_track/features/calendar/data/calendar_sharedprefs_hander.dart';
import 'package:uni_track/features/calendar/models/event.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- neu: Locale-Initialisierung import

// ####################################################################
// # 1. Datenmodell für einen Termin
// #    Diese Klasse repräsentiert einen einzelnen Kalendereintrag.
// ####################################################################

// ####################################################################
// # 2. DataHandler zur persistenten Speicherung
// #    Diese Klasse kümmert sich um das Laden und Speichern der
// #    Termine mithilfe von SharedPreferences.
// ####################################################################

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // Instanz des DataHandlers für die Datenpersistenz.
  final CalendarSharedprefsHander dataHandler = CalendarSharedprefsHander();

  // State-Variablen
  late final ValueNotifier<List<Event>> _selectedEvents;
  Map<DateTime, List<Event>> _events = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final TextEditingController _eventController = TextEditingController();

  // Neu: Flag, das anzeigt, ob Locale-Daten initialisiert wurden.
  bool _localeInitialized = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _loadEventsFromStorage();
    _initializeLocale(); // <-- neu: Locale-Initialisierung starten
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    _eventController.dispose();
    super.dispose();
  }

  // Lädt die Termine beim Start der App.
  void _loadEventsFromStorage() async {
    final loadedEvents = await dataHandler.loadEvents();
    setState(() {
      _events = loadedEvents;
    });
    _selectedEvents.value = _getEventsForDay(_selectedDay!);
  }

  // Speichert die Termine, wann immer eine Änderung vorgenommen wird.
  void _saveEventsToStorage() {
    dataHandler.saveEvents(_events);
  }

  // Hilfsmethode, um die Termine für einen bestimmten Tag zu erhalten.
  List<Event> _getEventsForDay(DateTime day) {
    // Wichtig: Normalisiert das Datum auf Mitternacht, um Vergleiche zu ermöglichen.
    DateTime normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  // Wird aufgerufen, wenn ein Tag im Kalender ausgewählt wird.
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  // Zeigt einen Dialog zum Hinzufügen eines neuen Termins an.
  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Neuen Termin hinzufügen'),
          content: TextField(
            controller: _eventController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Terminbeschreibung'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_eventController.text.isEmpty) return;

                final normalizedDay = DateTime.utc(
                  _selectedDay!.year,
                  _selectedDay!.month,
                  _selectedDay!.day,
                );

                setState(() {
                  if (_events[normalizedDay] != null) {
                    _events[normalizedDay]!.add(
                      Event(title: _eventController.text),
                    );
                  } else {
                    _events[normalizedDay] = [
                      Event(title: _eventController.text),
                    ];
                  }
                  _eventController.clear();
                  _selectedEvents.value = _getEventsForDay(normalizedDay);
                  _saveEventsToStorage();
                });

                Navigator.pop(context);
              },
              child: const Text('Hinzufügen'),
            ),
          ],
        );
      },
    );
  }

  // Neu: Locale-Daten asynchron initialisieren.
  Future<void> _initializeLocale() async {
    try {
      await initializeDateFormatting('de_DE', null);
    } catch (_) {
      // Falls die Initialisierung fehlschlägt, weiter ohne Locale (stumm behandeln)
    }
    if (mounted) {
      setState(() {
        _localeInitialized = true;
      });
    }
  }

  // UI-Build-Methode
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mein Kalender')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Das Kalender-Widget
          TableCalendar<Event>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            eventLoader: _getEventsForDay,
            calendarStyle: const CalendarStyle(
              // Hebt den heutigen Tag hervor
              todayDecoration: BoxDecoration(
                color: Colors.orangeAccent,
                shape: BoxShape.circle,
              ),
              // Hebt den ausgewählten Tag hervor
              selectedDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible:
                  false, // Versteckt den "2 Weeks/Month"-Button
              titleCentered: true,
            ),
            // Deutsche Lokalisierung — nur setzen, wenn initialisiert
            locale: _localeInitialized ? 'de_DE' : null,
          ),
          const SizedBox(height: 8.0),
          const Divider(),
          // Liste der Termine für den ausgewählten Tag
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                if (value.isEmpty) {
                  return const Center(
                    child: Text('Keine Termine für diesen Tag.'),
                  );
                }
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        onTap: () => print('${value[index]}'),
                        title: Text('${value[index]}'),
                        // Hier könnte man eine Lösch-Funktion hinzufügen
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            final normalizedDay = DateTime.utc(
                              _selectedDay!.year,
                              _selectedDay!.month,
                              _selectedDay!.day,
                            );
                            setState(() {
                              _events[normalizedDay]!.removeWhere(
                                (event) => event.title == value[index].title,
                              );
                              if (_events[normalizedDay]!.isEmpty) {
                                _events.remove(normalizedDay);
                              }
                              _selectedEvents.value = _getEventsForDay(
                                normalizedDay,
                              );
                              _saveEventsToStorage();
                            });
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
