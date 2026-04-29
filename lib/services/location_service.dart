import 'package:cloud_functions/cloud_functions.dart';
import '../models/location_model.dart';

class LocationService {
  final _functions = FirebaseFunctions.instance;

  Future<({LocationModel? nextLocation, bool completed})> getNextLocation(
    String deviceId,
  ) async {
    final callable = _functions.httpsCallable('getNextLocation');
    final result = await callable.call({'deviceId': deviceId});
    final data = Map<String, dynamic>.from(result.data as Map);
    final completed = data['completed'] as bool? ?? false;
    if (completed || data['nextLocation'] == null) {
      return (nextLocation: null, completed: true);
    }
    final loc = LocationModel.fromJson(
      Map<String, dynamic>.from(data['nextLocation'] as Map),
    );
    return (nextLocation: loc, completed: false);
  }

  Future<({LocationModel? nextLocation, bool completed, bool success})>
      saveProgress(String deviceId, int currentSequence) async {
    final callable = _functions.httpsCallable('saveProgress');
    final result = await callable.call({
      'deviceId': deviceId,
      'currentSequence': currentSequence,
    });
    final data = Map<String, dynamic>.from(result.data as Map);
    final completed = data['completed'] as bool? ?? false;
    final success = data['success'] as bool? ?? false;
    if (completed || data['nextLocation'] == null) {
      return (nextLocation: null, completed: true, success: success);
    }
    final loc = LocationModel.fromJson(
      Map<String, dynamic>.from(data['nextLocation'] as Map),
    );
    return (nextLocation: loc, completed: false, success: success);
  }
}
