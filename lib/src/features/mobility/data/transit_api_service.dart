/// Transit API Service für v6.db.transport.rest
/// Kostenlose ÖPNV-API ohne Authentifizierung
/// Rate Limit: 100 req/min (burst 200)
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

import '../domain/departure.dart';
import '../domain/transit_stop.dart';

/// Exception für Transit API Fehler
class TransitApiException implements Exception {
  const TransitApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'TransitApiException: $message (Status: $statusCode)';

  /// Benutzerfreundliche Fehlermeldung
  String get userMessage {
    if (statusCode == 429) {
      return 'Zu viele Anfragen. Bitte warten Sie einen Moment.';
    }
    if (statusCode == 404) {
      return 'Haltestelle nicht gefunden.';
    }
    if (statusCode != null && statusCode! >= 500) {
      return 'Der Server ist momentan nicht erreichbar.';
    }
    return 'Ein Fehler ist aufgetreten. Bitte versuchen Sie es später erneut.';
  }
}

/// API Service für v6.db.transport.rest
class TransitApiService {
  TransitApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = 'https://v6.db.transport.rest';
  static const Duration _timeout = Duration(seconds: 10);

  final http.Client _client;

  /// Haltestellen in der Nähe finden
  ///
  /// [latitude] Geografische Breite
  /// [longitude] Geografische Länge
  /// [results] Maximale Anzahl Ergebnisse (Standard: 5)
  /// [distance] Maximale Entfernung in Metern (optional)
  Future<List<TransitStop>> getNearbyStops({
    required double latitude,
    required double longitude,
    int results = 5,
    int? distance,
  }) async {
    final queryParams = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'results': results.toString(),
      'stops': 'true',
      'poi': 'false',
      'language': 'de',
    };

    if (distance != null) {
      queryParams['distance'] = distance.toString();
    }

    final uri = Uri.parse('$_baseUrl/locations/nearby').replace(
      queryParameters: queryParams,
    );

    debugPrint('Transit API: GET $uri');

    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        throw TransitApiException(
          'Fehler beim Laden der Haltestellen',
          statusCode: response.statusCode,
        );
      }

      final data = jsonDecode(response.body);

      if (data is! List) {
        debugPrint('Transit API: Unexpected response format');
        return [];
      }

      return data
          .where((item) => item['type'] == 'stop' || item['type'] == 'station')
          .map((item) => TransitStop.fromJson(item as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw const TransitApiException('Keine Internetverbindung');
    } on TimeoutException {
      throw const TransitApiException('Server antwortet nicht');
    } on FormatException catch (e) {
      debugPrint('Transit API: JSON parse error: $e');
      throw const TransitApiException('Ungültige Antwort vom Server');
    }
  }

  /// Abfahrten an einer Haltestelle abrufen
  ///
  /// [stopId] ID der Haltestelle
  /// [duration] Zeitraum in Minuten (Standard: 30)
  /// [results] Maximale Anzahl Ergebnisse (optional)
  Future<List<Departure>> getDepartures({
    required String stopId,
    int duration = 30,
    int? results,
  }) async {
    final queryParams = {
      'duration': duration.toString(),
      'language': 'de',
      'remarks': 'true',
    };

    if (results != null) {
      queryParams['results'] = results.toString();
    }

    final uri = Uri.parse('$_baseUrl/stops/$stopId/departures').replace(
      queryParameters: queryParams,
    );

    debugPrint('Transit API: GET $uri');

    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        throw TransitApiException(
          'Fehler beim Laden der Abfahrten',
          statusCode: response.statusCode,
        );
      }

      final data = jsonDecode(response.body);

      // API gibt { departures: [...] } oder direkt [...] zurück
      List<dynamic> departures;
      if (data is Map<String, dynamic>) {
        departures = data['departures'] as List<dynamic>? ?? [];
      } else if (data is List) {
        departures = data;
      } else {
        debugPrint('Transit API: Unexpected response format');
        return [];
      }

      return departures
          .map((item) => Departure.fromJson(item as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw const TransitApiException('Keine Internetverbindung');
    } on TimeoutException {
      throw const TransitApiException('Server antwortet nicht');
    } on FormatException catch (e) {
      debugPrint('Transit API: JSON parse error: $e');
      throw const TransitApiException('Ungültige Antwort vom Server');
    }
  }

  /// Haltestellen und Orte nach Name suchen (für Autocomplete)
  ///
  /// [query] Suchbegriff (min. 2 Zeichen)
  /// [results] Maximale Anzahl Ergebnisse (Standard: 8)
  Future<List<TransitStop>> searchLocations({
    required String query,
    int results = 8,
  }) async {
    if (query.length < 2) return [];

    final queryParams = {
      'query': query,
      'results': results.toString(),
      'stops': 'true',
      'addresses': 'true',
      'poi': 'false',
      'language': 'de',
    };

    final uri = Uri.parse('$_baseUrl/locations').replace(
      queryParameters: queryParams,
    );

    debugPrint('Transit API: GET $uri');

    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        throw TransitApiException(
          'Fehler bei der Suche',
          statusCode: response.statusCode,
        );
      }

      final data = jsonDecode(response.body);

      if (data is! List) {
        debugPrint('Transit API: Unexpected response format');
        return [];
      }

      return data
          .map((item) => TransitStop.fromJson(item as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw const TransitApiException('Keine Internetverbindung');
    } on TimeoutException {
      throw const TransitApiException('Server antwortet nicht');
    } on FormatException catch (e) {
      debugPrint('Transit API: JSON parse error: $e');
      throw const TransitApiException('Ungültige Antwort vom Server');
    }
  }

  /// Haltestelle nach ID abrufen
  Future<TransitStop?> getStop(String stopId) async {
    final uri = Uri.parse('$_baseUrl/stops/$stopId').replace(
      queryParameters: {'language': 'de'},
    );

    debugPrint('Transit API: GET $uri');

    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode == 404) {
        return null;
      }

      if (response.statusCode != 200) {
        throw TransitApiException(
          'Fehler beim Laden der Haltestelle',
          statusCode: response.statusCode,
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return TransitStop.fromJson(data);
    } on SocketException {
      throw const TransitApiException('Keine Internetverbindung');
    } on TimeoutException {
      throw const TransitApiException('Server antwortet nicht');
    }
  }

  /// Ressourcen freigeben
  void dispose() {
    _client.close();
  }
}
