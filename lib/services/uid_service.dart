import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UidService {
  static const _key = 'player_uid';

  Future<String> getOrCreateUid() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_key);
    if (existing != null) return existing;
    final uid = const Uuid().v4();
    await prefs.setString(_key, uid);
    return uid;
  }
}
