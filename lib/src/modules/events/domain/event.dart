import 'package:flutter/material.dart';

import '../../../shared/domain/coordinates.dart';
import '../../../shared/domain/map_item.dart';

class Event implements MapItem {
  const Event({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    this.description,
  });

  @override
  final String id;
  final String title;
  final String? description;
  final Coordinates location;
  final DateTime date;

  @override
  Coordinates get coordinates => location;

  @override
  String get displayName => title;

  @override
  String? get subtitle => description;

  @override
  MapItemCategory get category => MapItemCategory.event;

  @override
  Color get markerColor => const Color(0xFF7B1FA2);

  @override
  String get moduleId => 'events';

  @override
  DateTime? get lastUpdated => date;

  @override
  Map<String, dynamic> get metadata => {};
}
