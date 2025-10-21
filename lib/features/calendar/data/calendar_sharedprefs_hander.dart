import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_track/features/calendar/models/event.dart';

class CalendarSharedprefsHander {
  // Speichert die Termine auf dem Gerät.
  Future<void> saveEvents(Map<DateTime, List<Event>> events) async {
    final prefs = await SharedPreferences.getInstance();

    // Konvertiert die Map<DateTime, List<Event>> in ein speicherbares Format:
    // Map<String, List<Map<String, dynamic>>>
    final Map<String, dynamic> eventsToSave = {};
    events.forEach((key, value) {
      // Der DateTime-Schlüssel wird in einen String konvertiert.
      final dateKey = key.toIso8601String();
      // Die Liste der Events wird in eine Liste von JSON-Objekten konvertiert.
      eventsToSave[dateKey] = value.map((event) => event.toJson()).toList();
    });

    // Die gesamte Map wird als einzelner JSON-String gespeichert.
    await prefs.setString('calendar_events', json.encode(eventsToSave));
  }

  // Lädt die gespeicherten Termine vom Gerät.
  Future<Map<DateTime, List<Event>>> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventsString = prefs.getString('calendar_events');

    if (eventsString == null) {
      return {};
    }

    // Der JSON-String wird zurück in eine Map geparst.
    final Map<String, dynamic> decodedEvents = json.decode(eventsString);
    final Map<DateTime, List<Event>> events = {};

    decodedEvents.forEach((key, value) {
      // Der String-Schlüssel wird zurück in ein DateTime-Objekt konvertiert.
      final dateKey = DateTime.parse(key);
      // Die Liste von JSON-Objekten wird zurück in eine Liste von Event-Objekten konvertiert.
      final List<Event> eventList = (value as List<dynamic>)
          .map((item) => Event.fromJson(item as Map<String, dynamic>))
          .toList();
      events[dateKey] = eventList;
    });

    return events;
  }
}
