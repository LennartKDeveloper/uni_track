class TimetableEvent {
  final String id;
  final String title;
  final String room;
  final int dayIndex; 
  final double startHour; 
  final double duration; 
  final int colorValue;

  TimetableEvent({
    required this.id,
    required this.title,
    required this.room,
    required this.dayIndex,
    required this.startHour,
    required this.duration,
    required this.colorValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'room': room,
      'dayIndex': dayIndex,
      'startHour': startHour,
      'duration': duration,
      'colorValue': colorValue,
    };
  }

  factory TimetableEvent.fromMap(Map<String, dynamic> map) {
    return TimetableEvent(
      id: map['id'],
      title: map['title'],
      room: map['room'],
      dayIndex: map['dayIndex'],
      startHour: map['startHour'],
      duration: map['duration'],
      colorValue: map['colorValue'],
    );
  }
}
