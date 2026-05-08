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

  @override
  void initState() {
    super.initState();
    _checkProgress();
  }

  Future<void> _checkProgress() async {
    try {
      final uid = await UidService().getOrCreateUid();
      final player = await FunctionsService().loadProgress(uid);
      if (mounted && player.visitedLocationIds.isNotEmpty) {
        setState(() => _hasProgress = true);
      }
    } catch (_) {
      // sem progress salvo ou erro no firebase
    }
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
            ],
          ),
        ),
      ),
    );
  }
}
