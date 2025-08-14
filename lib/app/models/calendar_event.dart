import 'package:equatable/equatable.dart';

class CalendarEvent extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime startAt;
  final DateTime? endAt;
  final bool allDay;
  final String? location;
  final DateTime createdAt;

  const CalendarEvent({
    required this.id,
    required this.title,
    this.description,
    required this.startAt,
    this.endAt,
    this.allDay = false,
    this.location,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    startAt,
    endAt,
    allDay,
    location,
    createdAt,
  ];

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startAt: DateTime.parse(json['start_at']),
      endAt: json['end_at'] == null ? null : DateTime.parse(json['end_at']),
      allDay: json['all_day'] ?? false,
      location: json['location'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt?.toIso8601String(),
      'all_day': allDay,
      'location': location,
      'created_at': createdAt.toIso8601String(),
    };
  }

  CalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startAt,
    DateTime? endAt,
    bool? allDay,
    String? location,
    DateTime? createdAt,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      allDay: allDay ?? this.allDay,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}