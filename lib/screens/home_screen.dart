import 'package:flutter/material.dart';
import '../services/functions_service.dart';
import '../services/uid_service.dart';
import 'map_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasProgress = false;
  String? _uid;

  @override
  void initState() {
    super.initState();
    _checkProgress();
  }

  Future<void> _checkProgress() async {
    try {
      final uid = await UidService().getOrCreateUid();
      _uid = uid;
      final player = await FunctionsService().loadProgress(uid);
      if (mounted && player.visitedLocationIds.isNotEmpty) {
        setState(() => _hasProgress = true);
      }
    } catch (_) {}
  }

  Future<void> _startNewGame() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo jogo'),
        content: const Text('Tem certeza? O progresso atual será apagado.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await FunctionsService().saveProgress(_uid!, {}, {});
    } catch (_) {}
    if (mounted) Navigator.pushNamed(context, MapScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1554),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 72,
              ),
              const SizedBox(height: 24),
              const Text(
                'PUC RPG',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _hasProgress ? 'Continue de onde parou' : 'Inicie o jogo',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 64),
              SizedBox(
                width: 200,
                height: 56,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, MapScreen.routeName),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCC2222),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _hasProgress ? 'Continuar' : 'Iniciar',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (_hasProgress) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: 200,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _startNewGame,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Novo jogo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
