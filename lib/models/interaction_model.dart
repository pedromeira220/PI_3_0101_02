import 'dialog_model.dart';

class InteractionModel {
  final String locationId;
  final List<DialogStep> dialogs;
  final String? musicPath;
  final String? unlockHint;

  const InteractionModel({
    required this.locationId,
    required this.dialogs,
    this.musicPath,
    this.unlockHint,
  });

  factory InteractionModel.fromJson(String id, Map<String, dynamic> json) {
    return InteractionModel(
      locationId: id,
      dialogs: (json['dialogs'] as List<dynamic>? ?? [])
          .map((d) => DialogStep.fromJson(
                Map<String, dynamic>.from(d as Map),
              ))
          .toList(),
      musicPath: json['musicPath'] as String?,
      unlockHint: json['unlockHint'] as String?,
    );
  }
}
