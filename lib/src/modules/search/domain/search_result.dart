import 'package:flutter/material.dart';

import '../../../shared/domain/coordinates.dart';
import '../../../shared/domain/map_item.dart';

class SearchResult implements MapItem {
  const SearchResult({
    required this.id,
    required this.title,
    required this.location,
    required this.source,
    this.snippet,
  });

  @override
  final String id;
  final String title;
  final String? snippet;
  final Coordinates location;
  final String source;

  @override
  Coordinates get coordinates => location;

  @override
  String get displayName => title;

  @override
  String? get subtitle => snippet;

  @override
  MapItemCategory get category => MapItemCategory.search;

  @override
  Color get markerColor => const Color(0xFF1976D2);

  @override
  String get moduleId => 'search';

  @override
  DateTime? get lastUpdated => null;

  @override
  Map<String, dynamic> get metadata => {'source': source};

  @override
  bool? get isOpenNow => null;

  @override
  double get markerOpacity => 1.0;
}
