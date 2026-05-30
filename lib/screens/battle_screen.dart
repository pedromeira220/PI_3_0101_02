import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../models/dialog_model.dart';
import '../models/location_model.dart';

class _QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  const _QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

enum _BattlePhase { intro, quiz, winNarration, gameOver }

class BattleScreen extends StatefulWidget {
  final LocationModel location;
  final Future<void> Function()? onComplete;

  const BattleScreen({
    super.key,
    required this.location,
    this.onComplete,
  });

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  _BattlePhase _phase = _BattlePhase.intro;
  int _introStep = 0;
  int _quizIndex = 0;
  int _correctCount = 0;
  int? _selectedAnswer;
  bool _answered = false;
  bool _isSaving = false;
  final _audioPlayer = AudioPlayer();

  static const int _minCorrectToWin = 4;

  static const _questions = <_QuizQuestion>[
    _QuizQuestion(
      question: 'Qual widget do Flutter é ideal para listas longas com rolagem?',
      options: ['Column', 'ListView', 'GridView'],
      correctIndex: 1,
    ),
    _QuizQuestion(
      question: 'O que o setState() faz em um StatefulWidget?',
      options: [
        'Salva dados no Firestore',
        'Navega para outra tela',
        'Reconstrói a interface com os novos valores',
      ],
      correctIndex: 2,
    ),
    _QuizQuestion(
      question: 'No Firestore, qual método cria ou sobrescreve um documento?',
      options: ['update()', 'insert()', 'set()'],
      correctIndex: 2,
    ),
    _QuizQuestion(
      question: 'O que diferencia StatefulWidget de StatelessWidget?',
      options: [
        'StatefulWidget pode armazenar e alterar estado interno',
        'StatelessWidget não pode receber parâmetros',
        'StatefulWidget só funciona em telas completas',
      ],
      correctIndex: 0,
    ),
    _QuizQuestion(
      question: 'No Flutter, o que é o pubspec.yaml?',
      options: [
        'Arquivo que define as dependências e assets do projeto',
        'Arquivo de configuração do emulador Android',
        'Arquivo gerado automaticamente com o código compilado',
      ],
      correctIndex: 0,
    ),
  ];

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
      await AudioPlayer.global.setAudioContext(AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
        android: AudioContextAndroid(
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ));
      final assetPath =
          path.startsWith('assets/') ? path.substring('assets/'.length) : path;
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('[Audio] erro: $e');
    }
  }

  List<DialogStep> get _introDialogs => widget.location.dialogs;

  void _advanceIntro(int? nextStep) {
    // Na narração de vitória o único avanço possível é terminar o jogo
    if (_phase == _BattlePhase.winNarration) {
      _handleWin();
      return;
    }
    if (nextStep == -1) {
      _startQuiz();
      return;
    }
    final wouldGoTo = nextStep ?? _introStep + 1;
    // Interceta antes do último step (ending antigo) e inicia o quiz
    if (_introDialogs.isEmpty || wouldGoTo >= _introDialogs.length - 1) {
      _startQuiz();
      return;
    }
    setState(() => _introStep = wouldGoTo);
  }

  void _startQuiz() {
    setState(() {
      _phase = _BattlePhase.quiz;
      _quizIndex = 0;
      _correctCount = 0;
      _selectedAnswer = null;
      _answered = false;
    });
  }

  void _selectAnswer(int index) {
    if (_answered) return;

    final isCorrect = index == _questions[_quizIndex].correctIndex;
    final newCorrectCount = _correctCount + (isCorrect ? 1 : 0);
    final newIncorrectCount = (_quizIndex + 1) - newCorrectCount;

    setState(() {
      _selectedAnswer = index;
      _answered = true;
      _correctCount = newCorrectCount;
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;

      // 4ª resposta errada: impossível vencer, game over imediato
      if (newIncorrectCount >= 4) {
        setState(() => _phase = _BattlePhase.gameOver);
        return;
      }

      if (_quizIndex < _questions.length - 1) {
        setState(() {
          _quizIndex++;
          _selectedAnswer = null;
          _answered = false;
        });
      } else {
        if (newCorrectCount >= _minCorrectToWin) {
          setState(() {
            _phase = _BattlePhase.winNarration;
            _introStep = _introDialogs.length - 1;
          });
        } else {
          setState(() => _phase = _BattlePhase.gameOver);
        }
      }
    });
  }

  Future<void> _handleWin() async {
    setState(() => _isSaving = true);
    try {
      await _audioPlayer.stop();
      await widget.onComplete?.call();
    } finally {
      if (mounted) Navigator.pop(context);
    }
  }

  void _retryBattle() {
    setState(() {
      _phase = _BattlePhase.intro;
      _introStep = 0;
      _quizIndex = 0;
      _correctCount = 0;
      _selectedAnswer = null;
      _answered = false;
    });
  }

  void _goToMenu() {
    _audioPlayer.stop();
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Future<void> _onBack() async {
    await _audioPlayer.stop();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_phase == _BattlePhase.gameOver) return _buildGameOverScreen();

    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: const Color(0xFF050D2D),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              widget.location.imagePath.isNotEmpty
                  ? widget.location.imagePath
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
          if (_phase == _BattlePhase.intro)
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
              child: switch (_phase) {
                _BattlePhase.intro || _BattlePhase.winNarration => _buildIntro(),
                _BattlePhase.quiz => _buildQuiz(),
                _BattlePhase.gameOver => const SizedBox.shrink(),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    if (_introDialogs.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
        _phase == _BattlePhase.winNarration ? _handleWin() : _startQuiz(),
      );
      return const SizedBox.shrink();
    }

    final step = _introDialogs[_introStep];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (step.speaker != null) ...[
          _characterRow(step.speaker!, step.characterImage),
          const SizedBox(height: 8),
        ],
        _dialogBox(
          Text(step.text,
              style:
                  const TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
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
                  onPressed: () => _advanceIntro(opt.nextStep),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child:
                      Text(opt.text, style: const TextStyle(fontSize: 14)),
                ),
              ),
            ),
          )
        else
          _primaryButton('Continuar', () => _advanceIntro(null)),
      ],
    );
  }

  Widget _buildQuiz() {
    final q = _questions[_quizIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _characterRow('Professor', 'assets/images/professor_image.jpeg'),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1A4A).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_quizIndex + 1} / ${_questions.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _dialogBox(
          Text(q.question,
              style:
                  const TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
        ),
        const SizedBox(height: 12),
        ...List.generate(q.options.length, (i) {
          final isCorrect = i == q.correctIndex;
          final isSelected = i == _selectedAnswer;

          Color borderColor = Colors.white54;
          Color bgColor = Colors.transparent;
          if (_answered) {
            if (isCorrect) {
              borderColor = Colors.greenAccent;
              bgColor = Colors.green.withValues(alpha: 0.2);
            } else if (isSelected) {
              borderColor = Colors.redAccent;
              bgColor = Colors.red.withValues(alpha: 0.2);
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: _answered ? null : () => _selectAnswer(i),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white,
                  backgroundColor: bgColor,
                  disabledBackgroundColor: bgColor,
                  side: BorderSide(color: borderColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(q.options[i],
                    style: const TextStyle(fontSize: 14)),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGameOverScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF050D2D),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withValues(alpha: 0.15),
                    border: Border.all(color: Colors.redAccent, width: 2),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.redAccent, size: 52),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Game Over',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$_correctCount / ${_questions.length} respostas corretas',
                  style: const TextStyle(color: Colors.white54, fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  '"Você claramente não escreveu isso.\nPode ir embora."',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 14,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 52),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _retryBattle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCC1F2E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Continuar',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: _goToMenu,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Voltar ao menu',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _characterRow(String speaker, String? characterImage) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0D1A4A),
            border: Border.all(color: Colors.white38, width: 2),
          ),
          child: ClipOval(
            child: characterImage != null
                ? Image.asset(
                    characterImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(Icons.person,
                        color: Colors.white54, size: 24),
                  )
                : const Icon(Icons.person, color: Colors.white54, size: 24),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          speaker,
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

  Widget _primaryButton(String? label, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: (_isSaving || label == null) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFCC1F2E),
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              const Color(0xFFCC1F2E).withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Text(label ?? '', style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
