import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../services/compass_service.dart';
import '../services/location_service.dart';
import '../services/qibla_calculator.dart';
import '../widgets/qibla_compass.dart';

/// The main compass page that displays the Qibla direction.
///
/// This page uses a StreamBuilder to listen to compass updates and displays
/// a rotating arrow that points toward the Qibla (Kaaba in Mecca).
class CompassPage extends StatefulWidget {
  /// Creates a new compass page.
  const CompassPage({super.key});

  @override
  State<CompassPage> createState() => _CompassPageState();
}

class _CompassPageState extends State<CompassPage> {
  /// Service for handling compass sensor data.
  final CompassService _compassService = CompassService();

  /// Service for handling GPS location.
  final LocationService _locationService = LocationService();

  /// Service for calculating Qibla direction.
  final QiblaCalculator _qiblaCalculator = QiblaCalculator();

  /// The Qibla bearing from true north (0-360).
  double? _qiblaBearing;

  /// Error message to display if something goes wrong.
  String? _errorMessage;

  /// Whether we are currently loading the initial data.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeCompass();
  }

  /// Initializes the compass by fetching location and calculating Qibla bearing.
  Future<void> _initializeCompass() async {
    try {
      // Get current position and calculate Qibla bearing
      final position = await _locationService.getCurrentPosition();
      final qiblaBearing = _qiblaCalculator.calculateQiblaBearing(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _qiblaBearing = qiblaBearing;
        _isLoading = false;
      });

      // Start listening to compass updates
      _compassService.startListening();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _compassService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qibla Compass'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: Center(
        child: _buildBody(),
      ),
    );
  }

  /// Builds the body content based on current state.
  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingIndicator();
    }

    if (_errorMessage != null) {
      return _buildErrorView();
    }

    if (_qiblaBearing == null) {
      return _buildErrorView();
    }

    return _buildCompassStream();
  }

  /// Builds a loading indicator while initializing.
  Widget _buildLoadingIndicator() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text(
          'Getting your location...',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  /// Builds an error view when something goes wrong.
  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'An error occurred',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _errorMessage = null;
                _isLoading = true;
              });
              _initializeCompass();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Builds the compass with StreamBuilder for reactive updates.
  Widget _buildCompassStream() {
    return StreamBuilder<CompassEvent?>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        // Handle loading state
        if (!snapshot.hasData) {
          return _buildCompassDisplay(0.0);
        }

        // Handle null compass events (Android sensor unavailable)
        final event = snapshot.data;
        if (event == null) {
          return _buildCompassDisplay(0.0);
        }

        // Get the device heading (magnetic north on Android, true north on iOS)
        final deviceHeading = event.heading ?? 0.0;

        // Calculate Qibla angle for display
        // Note: For Android, this uses magnetic north (±5-10° variance from true north)
        // For iOS, the heading is already true north
        final qiblaAngle = _compassService.calculateQiblaAngle(
          deviceHeading,
          _qiblaBearing!,
        );

        return _buildCompassDisplay(qiblaAngle);
      },
    );
  }

  /// Builds the compass display with the given Qibla angle.
  Widget _buildCompassDisplay(double qiblaAngle) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        QiblaCompass(qiblaAngle: qiblaAngle),
        const SizedBox(height: 32),
        Text(
          'Qibla Bearing: ${_qiblaBearing!.toStringAsFixed(1)}°',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Hold your device flat',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
