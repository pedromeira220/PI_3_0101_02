import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../models/dialog_model.dart';
import '../models/location_model.dart';

class DialogScreen extends StatefulWidget {
  final LocationModel location;
  final Future<void> Function()? onComplete;

  const DialogScreen({
    super.key,
    required this.location,
    this.onComplete,
  });

  @override
  State<DialogScreen> createState() => _DialogScreenState();
}

class _DialogScreenState extends State<DialogScreen> {
  int _stepIndex = 0;
  bool _isSaving = false;
  final _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playMusic();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playMusic() async {
    final path = widget.location.musicPath;
    if (path == null || path.isEmpty) return;
    try {
      final assetPath =
          path.startsWith('assets/') ? path.substring(7) : path;
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (_) {}
  }

  List<DialogStep> get _dialogs => widget.location.dialogs;
  DialogStep? get _currentStep =>
      _dialogs.isEmpty ? null : _dialogs[_stepIndex];

  Future<void> _advance(int? nextStep) async {
    if (_isSaving) return;

    final isEnd = nextStep == -1 ||
        _dialogs.isEmpty ||
        (nextStep == null && _stepIndex >= _dialogs.length - 1);

    if (isEnd) {
      setState(() => _isSaving = true);
      try {
        await _audioPlayer.stop();
        await widget.onComplete?.call();
      } finally {
        if (mounted) Navigator.pop(context);
      }
      return;
    }

    setState(() {
      _stepIndex = nextStep ?? _stepIndex + 1;
    });
  }

  Future<void> _onBack() async {
    await _audioPlayer.stop();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final location = widget.location;
    final step = _currentStep;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF050D2D),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              location.imagePath.isNotEmpty
                  ? location.imagePath
                  : 'assets/estacionamento.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 600,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white),
                      onPressed: _onBack,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 32 + bottomPadding),
              child: step == null
                  ? _buildFallback(location)
                  : _buildDialog(step),
            ),
          ),
        ],
      ),
    );
  }

  // Exibido quando o local não tem diálogos definidos
  Widget _buildFallback(LocationModel location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          location.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _dialogBox(
          Text(
            location.description ?? 'Você chegou a ${location.name}!',
            style: const TextStyle(
                color: Colors.white, fontSize: 14, height: 1.5),
          ),
        ),
        const SizedBox(height: 16),
        _continueButton(() => _advance(null)),
      ],
    );
  }

  Widget _buildDialog(DialogStep step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (step.speaker != null) ...[
          _characterRow(step),
          const SizedBox(height: 8),
        ],
        _dialogBox(
          Text(
            step.text,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, height: 1.5),
          ),
        ),
        const SizedBox(height: 12),
        if (step.options != null && step.options!.isNotEmpty)
          ...step.options!.map(
            (opt) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _isSaving ? null : () => _advance(opt.nextStep),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(opt.text,
                      style: const TextStyle(fontSize: 14)),
                ),
              ),
            ),
          )
        else
          _continueButton(() => _advance(null)),
      ],
    );
  }

  Widget _characterRow(DialogStep step) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0D1A4A),
            border: Border.all(color: Colors.white38, width: 2),
          ),
          child: ClipOval(
            child: step.characterImage != null
                ? Image.asset(
                    step.characterImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.person,
                      color: Colors.white54,
                      size: 24,
                    ),
                  )
                : const Icon(Icons.person, color: Colors.white54, size: 24),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          step.speaker!,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _dialogBox(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1A4A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _continueButton(VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isSaving ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFCC1F2E),
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              const Color(0xFFCC1F2E).withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : const Text('Continuar', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
