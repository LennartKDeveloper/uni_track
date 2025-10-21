class Event {
  final String title;

  Event({required this.title});

  // Konvertiert ein Event-Objekt in ein JSON-Format (Map),
  // damit es gespeichert werden kann.
  Map<String, dynamic> toJson() => {'title': title};

  // Erstellt ein Event-Objekt aus einer JSON-Map,
  // wenn die Daten geladen werden.
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(title: json['title']);
  }

  @override
  String toString() => title;
}
