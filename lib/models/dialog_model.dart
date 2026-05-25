class DialogOption {
  final String text;
  final int nextStep; // -1 = encerra o diálogo

  const DialogOption({required this.text, required this.nextStep});

  factory DialogOption.fromJson(Map<String, dynamic> json) {
    return DialogOption(
      text: json['text'] as String? ?? '',
      nextStep: json['nextStep'] as int? ?? -1,
    );
  }
}

class DialogStep {
  final String text;
  final String? speaker;
  final String? characterImage;
  final List<DialogOption>? options;

  const DialogStep({
    required this.text,
    this.speaker,
    this.characterImage,
    this.options,
  });

  factory DialogStep.fromJson(Map<String, dynamic> json) {
    return DialogStep(
      text: json['text'] as String? ?? '',
      speaker: json['speaker'] as String?,
      characterImage: json['characterImage'] as String?,
      options: (json['options'] as List<dynamic>?)
          ?.map((o) => DialogOption.fromJson(
                Map<String, dynamic>.from(o as Map),
              ))
          .toList(),
    );
  }
}
