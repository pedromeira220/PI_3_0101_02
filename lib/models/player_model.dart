class PlayerModel {
  final String uid;
  final Set<String> visitedLocationIds;
  final Set<String> unlockedLocationIds;

  const PlayerModel({
    required this.uid,
    required this.visitedLocationIds,
    required this.unlockedLocationIds,
  });

  factory PlayerModel.fresh(String uid, String firstLocationId) {
    return PlayerModel(
      uid: uid,
      visitedLocationIds: {},
      unlockedLocationIds: {firstLocationId},
    );
  }

  factory PlayerModel.fromJson(String uid, Map<String, dynamic> json) {
    return PlayerModel(
      uid: uid,
      visitedLocationIds: Set<String>.from(
        (json['visited'] as List<dynamic>? ?? []).map((e) => e.toString()),
      ),
      unlockedLocationIds: Set<String>.from(
        (json['unlocked'] as List<dynamic>? ?? []).map((e) => e.toString()),
      ),
    );
  }
}
