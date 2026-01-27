import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/traffic_counter_service.dart';

/// Provider für den Traffic Counter Service
final trafficCounterServiceProvider = Provider<TrafficCounterService>((ref) {
  return TrafficCounterService();
});

/// Provider für Traffic-Statistiken (einmaliger Abruf)
final trafficStatsProvider = FutureProvider<TrafficStats>((ref) async {
  final service = ref.watch(trafficCounterServiceProvider);
  return service.getStats();
});

/// Stream-Provider für Echtzeit-Updates der Statistiken
final trafficStatsStreamProvider = StreamProvider<TrafficStats>((ref) {
  final service = ref.watch(trafficCounterServiceProvider);
  return service.watchStats();
});
