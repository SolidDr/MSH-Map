import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/msh_colors.dart';
import '../../core/theme/msh_spacing.dart';
import '../../core/theme/msh_theme.dart';
import '../domain/map_item.dart';

/// Suchleiste mit Auto-Vervollständigung
class SearchAutocomplete extends StatefulWidget {
  const SearchAutocomplete({
    super.key,
    required this.items,
    required this.onItemSelected,
  });

  final List<MapItem> items;
  final ValueChanged<MapItem> onItemSelected;

  @override
  State<SearchAutocomplete> createState() => _SearchAutocompleteState();
}

/// Synonym mapping for common search terms
const Map<String, List<String>> _searchSynonyms = {
  'schwimm': ['schwimmbad', 'hallenbad', 'freibad', 'pool', 'baden', 'stadtbad'],
  'baden': ['schwimmbad', 'hallenbad', 'freibad', 'pool', 'see', 'badesee'],
  'essen': ['restaurant', 'gastro', 'küche', 'speisen', 'lokal'],
  'kaffee': ['café', 'cafe', 'coffee', 'kaffehaus'],
  'cafe': ['café', 'kaffee', 'coffee', 'kaffehaus'],
  'arzt': ['doktor', 'praxis', 'medizin', 'gesundheit', 'krankenhaus'],
  'kinder': ['spielplatz', 'familie', 'kinderspielplatz', 'familienfreundlich'],
  'spielen': ['spielplatz', 'indoor', 'kinderspielplatz'],
  'wandern': ['natur', 'wald', 'berg', 'aussicht', 'tal'],
  'burg': ['schloss', 'festung', 'castle', 'ruine'],
  'schloss': ['burg', 'festung', 'castle', 'palast'],
  'museum': ['ausstellung', 'galerie', 'kultur'],
  'tier': ['zoo', 'tierpark', 'wildpark', 'streichelzoo', 'farm', 'bauernhof'],
  'bahn': ['zug', 'eisenbahn', 'dampflok', 'selketalbahn'],
  'höhle': ['grotte', 'tropfstein', 'unterirdisch'],
};

class _SearchAutocompleteState extends State<SearchAutocomplete> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;
  List<MapItem> _suggestions = [];
  int _activeIndex = -1;
  Timer? _debounceTimer;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _removeOverlay();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      // Verzögert schließen, damit Tap auf Item registriert wird
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!_focusNode.hasFocus) {
          _removeOverlay();
        }
      });
    }
  }

  void _onTextChanged(String query) {
    _debounceTimer?.cancel();

    if (query.length < 2) {
      _removeOverlay();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 150), () {
      _updateSuggestions(query);
    });
  }

  void _updateSuggestions(String query) {
    final lowerQuery = query.toLowerCase();

    // Get expanded search terms including synonyms
    final searchTerms = _getExpandedSearchTerms(lowerQuery);

    final suggestions = widget.items.where((item) {
      // Check display name
      if (item.displayName.toLowerCase().contains(lowerQuery)) return true;

      // Check category name
      if (item.category.name.toLowerCase().contains(lowerQuery)) return true;

      // Check subtitle
      if (item.subtitle?.toLowerCase().contains(lowerQuery) ?? false) return true;

      // Check tags from metadata
      final tags = item.metadata['tags'];
      if (tags is List) {
        for (final tag in tags) {
          final tagStr = tag.toString().toLowerCase();
          if (tagStr.contains(lowerQuery)) return true;
          // Also check if any synonym matches the tag
          for (final term in searchTerms) {
            if (tagStr.contains(term)) return true;
          }
        }
      }

      // Check description from metadata
      final description = item.metadata['description'];
      if (description is String && description.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      // Check if any expanded search term matches
      for (final term in searchTerms) {
        if (item.displayName.toLowerCase().contains(term) ||
            item.category.name.toLowerCase().contains(term) ||
            (item.subtitle?.toLowerCase().contains(term) ?? false)) {
          return true;
        }
      }

      return false;
    }).take(8).toList();

    setState(() {
      _suggestions = suggestions;
      _activeIndex = -1;
    });

    if (suggestions.isNotEmpty) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  /// Get expanded search terms including synonyms
  List<String> _getExpandedSearchTerms(String query) {
    final terms = <String>[];

    for (final entry in _searchSynonyms.entries) {
      // If query starts with or contains a synonym key
      if (query.contains(entry.key) || entry.key.contains(query)) {
        terms.addAll(entry.value);
      }
      // Also check if query matches any of the values
      for (final value in entry.value) {
        if (value.contains(query) || query.contains(value)) {
          terms.add(entry.key);
          terms.addAll(entry.value);
          break;
        }
      }
    }

    return terms.toSet().toList(); // Remove duplicates
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => _SuggestionsOverlay(
        link: _layerLink,
        suggestions: _suggestions,
        activeIndex: _activeIndex,
        query: _controller.text,
        onItemTap: _selectItem,
        onClose: _removeOverlay,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isOpen = true;
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
  }

  void _selectItem(MapItem item) {
    _controller.text = item.displayName;
    _removeOverlay();
    _focusNode.unfocus();
    widget.onItemSelected(item);
  }

  void _handleKeyEvent(KeyEvent event) {
    if (!_isOpen || _suggestions.isEmpty) return;

    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowDown:
          setState(() {
            _activeIndex = (_activeIndex + 1).clamp(0, _suggestions.length - 1);
          });
          _showOverlay();

        case LogicalKeyboardKey.arrowUp:
          setState(() {
            _activeIndex = (_activeIndex - 1).clamp(0, _suggestions.length - 1);
          });
          _showOverlay();

        case LogicalKeyboardKey.enter:
          if (_activeIndex >= 0 && _activeIndex < _suggestions.length) {
            _selectItem(_suggestions[_activeIndex]);
          }

        case LogicalKeyboardKey.escape:
          _removeOverlay();
          _focusNode.unfocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: _handleKeyEvent,
        child: Material(
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(MshTheme.radiusLarge),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onTextChanged,
            decoration: InputDecoration(
              hintText: 'In MSH suchen...',
              hintStyle: const TextStyle(color: MshColors.textMuted),
              prefixIcon: const Icon(
                Icons.search,
                color: MshColors.textSecondary,
                size: 20,
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _controller.clear();
                        _removeOverlay();
                      },
                    )
                  : null,
              filled: true,
              fillColor: MshColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MshTheme.radiusLarge),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: MshSpacing.md,
                vertical: MshSpacing.md,
              ),
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}

/// Dropdown-Overlay für Vorschläge
class _SuggestionsOverlay extends StatelessWidget {
  const _SuggestionsOverlay({
    required this.link,
    required this.suggestions,
    required this.activeIndex,
    required this.query,
    required this.onItemTap,
    required this.onClose,
  });

  final LayerLink link;
  final List<MapItem> suggestions;
  final int activeIndex;
  final String query;
  final ValueChanged<MapItem> onItemTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      width: MediaQuery.of(context).size.width - (MshSpacing.lg * 2),
      child: CompositedTransformFollower(
        link: link,
        showWhenUnlinked: false,
        offset: const Offset(0, 56), // Unterhalb der Suchleiste
        child: Material(
          elevation: 8,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(MshTheme.radiusMedium),
          ),
          color: MshColors.darkSurface,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final item = suggestions[index];
                final isActive = index == activeIndex;

                return _SuggestionItem(
                  item: item,
                  query: query,
                  isActive: isActive,
                  onTap: () => onItemTap(item),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Einzelner Vorschlag-Eintrag
class _SuggestionItem extends StatelessWidget {
  const _SuggestionItem({
    required this.item,
    required this.query,
    required this.isActive,
    required this.onTap,
  });

  final MapItem item;
  final String query;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: MshSpacing.md,
          vertical: MshSpacing.sm + 4, // Größere Touch-Targets
        ),
        decoration: BoxDecoration(
          color: isActive ? MshColors.darkSurfaceVariant : Colors.transparent,
          border: const Border(
            bottom: BorderSide(
              color: MshColors.darkSurfaceVariant,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Kategorie-Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: item.markerColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(item.category),
                color: item.markerColor,
                size: 18,
              ),
            ),
            const SizedBox(width: MshSpacing.sm),

            // Name + Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HighlightedText(
                    text: item.displayName,
                    query: query,
                    style: const TextStyle(
                      color: MshColors.darkTextPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (item.subtitle != null)
                    Text(
                      item.subtitle!,
                      style: const TextStyle(
                        color: MshColors.darkTextSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Kategorie-Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: item.markerColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _getCategoryLabel(item.category),
                style: TextStyle(
                  color: item.markerColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(MapItemCategory category) {
    return switch (category) {
      MapItemCategory.restaurant => Icons.restaurant,
      MapItemCategory.cafe => Icons.local_cafe,
      MapItemCategory.imbiss => Icons.fastfood,
      MapItemCategory.bar => Icons.local_bar,
      MapItemCategory.event => Icons.event,
      MapItemCategory.culture => Icons.theater_comedy,
      MapItemCategory.sport => Icons.sports,
      MapItemCategory.playground => Icons.toys,
      MapItemCategory.museum => Icons.museum,
      MapItemCategory.nature => Icons.park,
      MapItemCategory.zoo => Icons.pets,
      MapItemCategory.castle => Icons.castle,
      MapItemCategory.pool => Icons.pool,
      MapItemCategory.indoor => Icons.house,
      MapItemCategory.farm => Icons.agriculture,
      MapItemCategory.adventure => Icons.explore,
      MapItemCategory.service => Icons.business,
      MapItemCategory.search => Icons.search,
      MapItemCategory.custom => Icons.place,
    };
  }

  String _getCategoryLabel(MapItemCategory category) {
    return switch (category) {
      MapItemCategory.restaurant => 'Restaurant',
      MapItemCategory.cafe => 'Café',
      MapItemCategory.imbiss => 'Imbiss',
      MapItemCategory.bar => 'Bar',
      MapItemCategory.event => 'Event',
      MapItemCategory.culture => 'Kultur',
      MapItemCategory.sport => 'Sport',
      MapItemCategory.playground => 'Spielplatz',
      MapItemCategory.museum => 'Museum',
      MapItemCategory.nature => 'Natur',
      MapItemCategory.zoo => 'Zoo',
      MapItemCategory.castle => 'Burg',
      MapItemCategory.pool => 'Baden',
      MapItemCategory.indoor => 'Indoor',
      MapItemCategory.farm => 'Bauernhof',
      MapItemCategory.adventure => 'Abenteuer',
      MapItemCategory.service => 'Service',
      MapItemCategory.search => 'Suche',
      MapItemCategory.custom => 'Ort',
    };
  }
}

/// Widget zum Hervorheben von Suchtreffern
class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.text,
    required this.query,
    required this.style,
  });

  final String text;
  final String query;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: style);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final startIndex = lowerText.indexOf(lowerQuery);

    if (startIndex == -1) {
      return Text(text, style: style);
    }

    final endIndex = startIndex + query.length;

    return RichText(
      text: TextSpan(
        children: [
          // Text vor dem Match
          if (startIndex > 0)
            TextSpan(
              text: text.substring(0, startIndex),
              style: style,
            ),
          // Hervorgehobener Match
          TextSpan(
            text: text.substring(startIndex, endIndex),
            style: style.copyWith(
              backgroundColor: MshColors.primary.withValues(alpha: 0.3),
              color: MshColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          // Text nach dem Match
          if (endIndex < text.length)
            TextSpan(
              text: text.substring(endIndex),
              style: style,
            ),
        ],
      ),
    );
  }
}
