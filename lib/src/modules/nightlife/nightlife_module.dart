import 'package:flutter/material.dart';
import '../../core/theme/msh_colors.dart';
import '../../shared/domain/bounding_box.dart';
import '../../shared/domain/map_item.dart';
import '../_module_registry.dart';
import 'data/nightlife_repository.dart';
import 'domain/nightlife_category.dart';
import 'domain/nightlife_venue.dart';
import 'presentation/nightlife_venue_detail.dart';

/// Modul für Nachtleben (Bars, Clubs, Pubs)
class NightlifeModule extends MshModule {
  NightlifeModule({NightlifeRepository? repository})
      : _repository = repository ?? NightlifeRepository();

  final NightlifeRepository _repository;

  @override
  String get moduleId => 'nightlife';

  @override
  String get displayName => 'Nachtleben';

  @override
  IconData get icon => Icons.nightlife;

  @override
  Color get primaryColor => MshColors.categoryNightlife;

  @override
  Future<void> initialize() async {
    await _repository.loadFromAssets();
  }

  @override
  Future<void> dispose() async {
    _repository.dispose();
  }

  @override
  Stream<List<MapItem>> watchItemsInRegion(BoundingBox region) {
    return _repository.watchVenuesInRegion(region);
  }

  @override
  Future<List<MapItem>> getItemsInRegion(BoundingBox region) {
    return _repository.getVenuesInRegion(region);
  }

  @override
  Widget buildDetailView(BuildContext context, MapItem item) {
    if (item is NightlifeVenue) {
      return NightlifeVenueDetailContent(venue: item);
    }
    return const Text('Unbekannter Typ');
  }

  @override
  List<FilterOption> get filterOptions => [
        // Kategorie-Filter
        FilterOption(
          id: 'nightlife_pub',
          label: 'Pubs',
          icon: Icons.sports_bar,
          predicate: (item) =>
              item is NightlifeVenue &&
              item.nightlifeCategory == NightlifeCategory.pub,
        ),
        FilterOption(
          id: 'nightlife_bar',
          label: 'Bars',
          icon: Icons.local_bar,
          predicate: (item) =>
              item is NightlifeVenue &&
              item.nightlifeCategory == NightlifeCategory.bar,
        ),
        FilterOption(
          id: 'nightlife_cocktailbar',
          label: 'Cocktailbars',
          icon: Icons.wine_bar,
          predicate: (item) =>
              item is NightlifeVenue &&
              item.nightlifeCategory == NightlifeCategory.cocktailbar,
        ),
        FilterOption(
          id: 'nightlife_club',
          label: 'Clubs/Discos',
          icon: Icons.nightlife,
          predicate: (item) =>
              item is NightlifeVenue &&
              item.nightlifeCategory == NightlifeCategory.club,
        ),

        // Feature-Filter
        FilterOption(
          id: 'nightlife_food',
          label: 'Mit Essen',
          icon: Icons.restaurant,
          predicate: (item) => item is NightlifeVenue && item.hasFood,
        ),
        FilterOption(
          id: 'nightlife_live_music',
          label: 'Live-Musik',
          icon: Icons.music_note,
          predicate: (item) => item is NightlifeVenue && item.hasLiveMusic,
        ),
      ];
}
