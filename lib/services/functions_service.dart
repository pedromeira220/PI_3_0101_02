import 'package:cloud_functions/cloud_functions.dart';
import '../models/interaction_model.dart';
import '../models/location_model.dart';
import '../models/player_model.dart';

class FunctionsService {
  final _functions = FirebaseFunctions.instance;

  Future<List<LocationModel>> getLocations() async {
    final result = await _functions.httpsCallable('getLocations').call<List<dynamic>>();
    final list = result.data;
    return list
        .map((e) => LocationModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) => a.sequence.compareTo(b.sequence));
  }

  Future<PlayerModel> getOrCreatePlayer(String uid) async {
    final result = await _functions
        .httpsCallable('getOrCreatePlayer')
        .call<Map<String, dynamic>>({'uid': uid});
    return PlayerModel.fromJson(uid, Map<String, dynamic>.from(result.data));
  }

  Future<void> saveProgress(
    String uid,
    Set<String> visited,
    Set<String> unlocked,
  ) async {
    await _functions.httpsCallable('saveProgress').call({
      'uid': uid,
      'visited': visited.toList(),
      'unlocked': unlocked.toList(),
    });
  }

  Future<PlayerModel> loadProgress(String uid) async {
    final result = await _functions
        .httpsCallable('loadProgress')
        .call<Map<String, dynamic>>({'uid': uid});
    return PlayerModel.fromJson(uid, Map<String, dynamic>.from(result.data));
  }

  Future<Map<String, InteractionModel>> getInteractions() async {
    final result = await _functions
        .httpsCallable('getInteractions')
        .call<List<dynamic>>();
    final map = <String, InteractionModel>{};
    for (final raw in result.data) {
      final e = Map<String, dynamic>.from(raw as Map);
      final id = e['locationId'].toString();
      map[id] = InteractionModel.fromJson(id, e);
    }
    return map;
  }
}
