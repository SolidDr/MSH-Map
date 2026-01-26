import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

/// Provider for OpenAI API key - should be set from environment
final openAiApiKeyProvider = Provider<String>((ref) {
  // TODO: Load from secure storage or environment
  // For now, this should be set via --dart-define=OPENAI_API_KEY=xxx
  return const String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
});

/// Provider for the OpenAI service
final openAiServiceProvider = Provider<OpenAiService>((ref) {
  final apiKey = ref.watch(openAiApiKeyProvider);
  return OpenAiService(apiKey: apiKey);
});

/// Parsed menu item from OCR
class ParsedMenuItem {
  final String name;
  final String? description;
  final double? price;
  final String? category;

  ParsedMenuItem({
    required this.name,
    this.description,
    this.price,
    this.category,
  });

  factory ParsedMenuItem.fromJson(Map<String, dynamic> json) {
    return ParsedMenuItem(
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'price': price,
        'category': category,
      };
}

/// OCR result containing parsed menu items
class OcrResult {
  final List<ParsedMenuItem> items;
  final String? rawText;
  final String? error;

  OcrResult({
    required this.items,
    this.rawText,
    this.error,
  });

  bool get hasError => error != null;
  bool get isEmpty => items.isEmpty;
}

/// Service for OpenAI Vision API (OCR)
class OpenAiService {
  final String apiKey;
  final http.Client _client = http.Client();

  OpenAiService({required this.apiKey});

  /// Extract menu items from an image using GPT-4 Vision
  Future<OcrResult> extractMenuFromImage(File imageFile) async {
    if (apiKey.isEmpty) {
      return OcrResult(
        items: [],
        error: 'OpenAI API Key nicht konfiguriert',
      );
    }

    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await _client
          .post(
            Uri.parse('${AppConstants.openAiBaseUrl}/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              'model': 'gpt-4o',
              'messages': [
                {
                  'role': 'system',
                  'content': '''Du bist ein Experte für die Erkennung von Speisekarten.
Extrahiere alle Gerichte aus dem Bild und gib sie als JSON-Array zurück.
Jedes Gericht sollte folgende Felder haben:
- name: Name des Gerichts (Pflicht)
- description: Kurze Beschreibung (optional)
- price: Preis als Zahl ohne Währung (optional)
- category: Kategorie wie "Vorspeise", "Hauptgericht", "Dessert", "Getränk" (optional)

Antworte NUR mit dem JSON-Array, keine anderen Texte.
Beispiel: [{"name": "Schnitzel", "price": 12.50, "category": "Hauptgericht"}]''',
                },
                {
                  'role': 'user',
                  'content': [
                    {
                      'type': 'text',
                      'text':
                          'Extrahiere alle Gerichte aus dieser Speisekarte:',
                    },
                    {
                      'type': 'image_url',
                      'image_url': {
                        'url': 'data:image/jpeg;base64,$base64Image',
                      },
                    },
                  ],
                },
              ],
              'max_tokens': 2000,
            }),
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode != 200) {
        return OcrResult(
          items: [],
          error: 'API Fehler: ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final content =
          data['choices'][0]['message']['content'] as String;

      // Parse the JSON response
      final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(content);
      if (jsonMatch == null) {
        return OcrResult(
          items: [],
          rawText: content,
          error: 'Keine Gerichte erkannt',
        );
      }

      final itemsJson = jsonDecode(jsonMatch.group(0)!) as List;
      final items = itemsJson
          .map((item) => ParsedMenuItem.fromJson(item as Map<String, dynamic>))
          .toList();

      return OcrResult(
        items: items,
        rawText: content,
      );
    } on SocketException {
      return OcrResult(
        items: [],
        error: 'Keine Internetverbindung',
      );
    } on FormatException {
      return OcrResult(
        items: [],
        error: 'Fehler beim Parsen der Antwort',
      );
    } on Exception catch (e) {
      return OcrResult(
        items: [],
        error: 'Fehler: $e',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}
