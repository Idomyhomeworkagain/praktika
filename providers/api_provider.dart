import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

final apiProvider = Provider((ref) => ChessApi());

// Явно пишем <Map<String, dynamic>, int>
final profileProvider = FutureProvider.family<Map<String, dynamic>, int>((
  ref,
  userId,
) async {
  return ref.watch(apiProvider).getProfile(userId);
});

final progressProvider = FutureProvider.family<Map<String, dynamic>, int>((
  ref,
  userId,
) async {
  return ref.watch(apiProvider).getProgress(userId);
});

// Явно пишем <List<dynamic>>
final tasksProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(apiProvider).getTasks();
});
