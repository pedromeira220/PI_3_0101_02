import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../services/device_id_service.dart';
import '../services/gps_service.dart';
import '../services/location_service.dart';

class MapScreen extends StatefulWidget {
  static const routeName = '/map';

  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _deviceIdService = DeviceIdService();
  final _gpsService = GpsService();
  final _locationService = LocationService();

  bool _isLoading = true;
  String? _error;
  bool _isSaving = false;
  LocationModel? _nextLocation;
  bool _completed = false;
  String _distanceText = '--';
  String? _deviceId;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final deviceId = await _deviceIdService.getDeviceId();
      _deviceId = deviceId;
      await _gpsService.requestPermission();
      final result = await _locationService.getNextLocation(deviceId);
      if (mounted) {
        setState(() {
          _nextLocation = result.nextLocation;
          _completed = result.completed;
          _isLoading = false;
        });
        await _updateDistance();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro ao carregar: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateDistance() async {
    if (_nextLocation == null) return;
    final position = await _gpsService.getCurrentPosition();
    if (position != null && mounted) {
      final meters = _gpsService.calculateDistance(position, _nextLocation!);
      setState(() {
        _distanceText = _gpsService.formatDistance(meters);
      });
    }
  }

  Future<void> _saveProgress() async {
    if (_deviceId == null || _nextLocation == null || _isSaving || _completed) return;
    setState(() => _isSaving = true);
    try {
      final result = await _locationService.saveProgress(
        _deviceId!,
        _nextLocation!.sequence,
      );
      if (mounted) {
        setState(() {
          _nextLocation = result.nextLocation;
          _completed = result.completed;
          _isSaving = false;
          _distanceText = '--';
        });
        await _updateDistance();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_completed ? 'Percurso completo!' : 'Progresso salvo!'),
              backgroundColor: const Color(0xFF1A7F3C),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: (_isSaving || _completed) ? null : _saveProgress,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A7F3C),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  const Color(0xFF1A7F3C).withValues(alpha: 0.4),
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
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Salvar Progresso',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: _completed
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 64,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Percurso completo!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
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
                                      _nextLocation?.name ?? '',
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
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _completed ? null : _updateDistance,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFCC2222),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  const Color(0xFFCC2222).withValues(alpha: 0.4),
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
                      ),
                    ],
                  ),
      ),
    );
  }
}
