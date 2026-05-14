import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/locations.dart' as local_data;
import '../models/location_model.dart';
import '../models/player_model.dart';
import '../services/functions_service.dart';
import '../services/gps_service.dart';
import '../services/uid_service.dart';
import 'dialog_screen.dart';

class MapScreen extends StatefulWidget {
  static const routeName = '/map';

  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _gpsService = GpsService();
  final _functionsService = FunctionsService();
  final _uidService = UidService();

  bool _isLoading = true;
  String? _error;
  String _distanceText = '--';
  bool _withinRadius = false;

  List<LocationModel> _locations = [];
  PlayerModel? _player;
  String? _uid;

  // Primeiro local desbloqueado e ainda não visitado
  LocationModel? get _currentTarget {
    if (_player == null || _locations.isEmpty) return null;
    for (final loc in _locations) {
      if (_player!.unlockedLocationIds.contains(loc.id) &&
          !_player!.visitedLocationIds.contains(loc.id)) {
        return loc;
      }
    }
    return null;
  }

  bool get _allCompleted =>
      _player != null &&
      _locations.isNotEmpty &&
      _currentTarget == null;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _gpsService.requestPermission();
      _uid = await _uidService.getOrCreateUid();
      await _loadData();
      if (mounted) setState(() => _isLoading = false);
      if (_currentTarget != null) await _updateDistance();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro ao carregar: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _functionsService.getLocations(),
        _functionsService.loadProgress(_uid!),
      ]);
      _locations = results[0] as List<LocationModel>;
      _player = results[1] as PlayerModel;

      if (_player!.unlockedLocationIds.isEmpty && _locations.isNotEmpty) {
        _player = PlayerModel.fresh(_uid!, _locations.first.id);
      }
    } catch (_) {
      _locations = local_data.locations;
      _player = PlayerModel.fresh(_uid!, local_data.locations.first.id);
    }
  }

  Future<void> _updateDistance() async {
    final target = _currentTarget;
    if (target == null) return;
    final position = await _gpsService.getCurrentPosition();
    if (position != null && mounted) {
      final meters = _gpsService.calculateDistance(position, target);
      setState(() {
        _distanceText = _gpsService.formatDistance(meters);
        _withinRadius = meters <= target.radius;
      });
    }
  }

  Future<void> _onLocationCompleted() async {
    final target = _currentTarget;
    if (target == null || _uid == null || _player == null) return;

    final visited = {..._player!.visitedLocationIds, target.id};

    LocationModel? nextLoc;
    try {
      nextLoc = _locations.firstWhere(
        (l) => l.sequence == target.sequence + 1,
      );
    } catch (_) {
      nextLoc = null;
    }

    final unlocked = {
      ..._player!.unlockedLocationIds,
      if (nextLoc != null) nextLoc.id,
    };

    try {
      await _functionsService.saveProgress(_uid!, visited, unlocked);
    } catch (_) {
    }

    if (mounted) {
      setState(() {
        _player = PlayerModel(
          uid: _uid!,
          visitedLocationIds: visited,
          unlockedLocationIds: unlocked,
        );
        _withinRadius = false;
        _distanceText = '--';
      });
    }

    if (_currentTarget != null) await _updateDistance();
  }

  void _openDialog() {
    final target = _currentTarget;
    if (target == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DialogScreen(
          location: target,
          onComplete: _onLocationCompleted,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D1554),
        body: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : _error != null
                  ? Center(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : _allCompleted
                      ? _buildCompleted()
                      : _buildGame(),
        ),
      ),
    );
  }

  Widget _buildCompleted() {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, color: Colors.amber, size: 72),
              SizedBox(height: 24),
              Text(
                'Parabéns!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Você visitou todos os ambientes!',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGame() {
    final target = _currentTarget;
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_withinRadius)
                  const Text(
                    'Você chegou!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else ...[
                  const Text(
                    'Você está a:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_distanceText do destino',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'Próximo destino',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  target?.name ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            children: [
              if (_withinRadius) ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _openDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCC2222),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Ver localização',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _updateDistance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _withinRadius
                        ? Colors.white.withValues(alpha: 0.1)
                        : const Color(0xFFCC2222),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Atualizar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
