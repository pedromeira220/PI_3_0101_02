import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/locations.dart';
import '../models/location_model.dart';
import '../services/gps_service.dart';
import 'dialog_screen.dart';

class MapScreen extends StatefulWidget {
  static const routeName = '/map';

  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _gpsService = GpsService();

  bool _isLoading = true;
  String? _error;
  String _distanceText = '--';
  bool _withinRadius = false;

  LocationModel get _currentTarget => locations.first;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _gpsService.requestPermission();
      if (mounted) setState(() => _isLoading = false);
      await _updateDistance();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro ao carregar: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _openDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DialogScreen(
          characterName: _currentTarget.name,
          dialogText: _currentTarget.description ?? 'Você chegou a ${_currentTarget.name}!',
          characterWidget: const SizedBox.shrink(),
          onContinue: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Future<void> _updateDistance() async {
    final position = await _gpsService.getCurrentPosition();
    if (position != null && mounted) {
      final meters = _gpsService.calculateDistance(position, _currentTarget);
      setState(() {
        _distanceText = _gpsService.formatDistance(meters);
        _withinRadius = meters <= _currentTarget.radius;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
      backgroundColor: const Color(0xFF0D1554),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : _error != null
                ? Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Column(
                    children: [
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
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentTarget.name,
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
                  ),
      ),
      ),
    );
  }
}
