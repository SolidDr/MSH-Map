import 'package:flutter/material.dart';
import 'coordinates.dart';
import 'map_item.dart';

/// MapItem-Implementierung für Locations aus Assets
class AssetLocation implements MapItem {

  AssetLocation({
    required String id,
    required String displayName,
    required String category,
    required double latitude,
    required double longitude,
    required Map<String, dynamic> rawData,
    String? city,
    String? description,
  })  : _id = id,
        _displayName = displayName,
        _category = category,
        _latitude = latitude,
        _longitude = longitude,
        _city = city,
        _description = description,
        _rawData = rawData;

  /// Factory constructor aus JSON
  factory AssetLocation.fromJson(Map<String, dynamic> json) {
    return AssetLocation(
      id: json['id'] as String,
      displayName: json['displayName'] as String? ?? json['name'] as String,
      category: json['category'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      rawData: json,
      city: json['city'] as String?,
      description: json['description'] as String?,
    );
  }
  final String _id;
  final String _displayName;
  final String _category;
  final double _latitude;
  final double _longitude;
  final String? _city;
  final String? _description;
  final Map<String, dynamic> _rawData;

  @override
  String get id => _id;

  @override
  Coordinates get coordinates => Coordinates(
        latitude: _latitude,
        longitude: _longitude,
      );

  @override
  String get displayName => _displayName;

  @override
  String? get subtitle => _city;

  @override
  MapItemCategory get category => _parseCategoryString(_category);

  @override
  Color get markerColor => _getCategoryColor(category);

  @override
  String get moduleId => 'asset_locations';

  @override
  DateTime? get lastUpdated => null;

  @override
  Map<String, dynamic> get metadata => _rawData;

  String get description => _description ?? '';

  /// Konvertiert String-Kategorie zu MapItemCategory
  static MapItemCategory _parseCategoryString(String category) {
    switch (category.toLowerCase()) {
      case 'restaurant':
        return MapItemCategory.restaurant;
      case 'cafe':
        return MapItemCategory.cafe;
      case 'imbiss':
        return MapItemCategory.imbiss;
      case 'bar':
        return MapItemCategory.bar;
      case 'event':
        return MapItemCategory.event;
      case 'culture':
        return MapItemCategory.culture;
      case 'sport':
        return MapItemCategory.sport;
      case 'playground':
        return MapItemCategory.playground;
      case 'museum':
        return MapItemCategory.museum;
      case 'nature':
        return MapItemCategory.nature;
      case 'zoo':
        return MapItemCategory.zoo;
      case 'castle':
        return MapItemCategory.castle;
      case 'pool':
        return MapItemCategory.pool;
      case 'indoor':
        return MapItemCategory.indoor;
      case 'farm':
        return MapItemCategory.farm;
      case 'adventure':
        return MapItemCategory.adventure;
      default:
        return MapItemCategory.custom;
    }
  }

  /// Bestimmt Farbe basierend auf Kategorie
  static Color _getCategoryColor(MapItemCategory category) {
    switch (category) {
      case MapItemCategory.restaurant:
      case MapItemCategory.cafe:
      case MapItemCategory.imbiss:
      case MapItemCategory.bar:
        return Colors.orange;
      case MapItemCategory.event:
      case MapItemCategory.culture:
        return Colors.purple;
      case MapItemCategory.sport:
        return Colors.red;
      case MapItemCategory.playground:
      case MapItemCategory.museum:
      case MapItemCategory.zoo:
        return Colors.blue;
      case MapItemCategory.nature:
      case MapItemCategory.farm:
        return Colors.green;
      case MapItemCategory.castle:
        return Colors.brown;
      case MapItemCategory.pool:
        return Colors.cyan;
      case MapItemCategory.indoor:
        return Colors.indigo;
      case MapItemCategory.adventure:
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}
