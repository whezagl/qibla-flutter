import 'dart:async';
import 'package:flutter_compass/flutter_compass.dart';

/// Service for handling device compass sensor data.
///
/// Provides access to compass heading updates for Qibla direction calculation.
/// Note: On iOS, the compass provides true north headings. On Android,
/// it provides magnetic north headings (may vary ±5-10° from true north).
class CompassService {
  /// Stream subscription for compass events.
  StreamSubscription<CompassEvent>? _subscription;

  /// Stream controller for compass heading updates.
  final _headingController = StreamController<double>.broadcast();

  /// Stream of compass headings in degrees (0-360).
  ///
  /// Emits values as the device rotates.
  /// On iOS: headings are true north (already adjusted for declination).
  /// On Android: headings are magnetic north.
  Stream<double> get headingStream => _headingController.stream;

  /// Starts listening to compass sensor updates.
  ///
  /// Throws [CompassServiceException] if the compass sensor is unavailable.
  void startListening() {
    if (_subscription != null) {
      // Already listening
      return;
    }

    _subscription = FlutterCompass.events?.listen(
      (CompassEvent? event) {
        if (event == null) {
          // Android returns null when sensor is unavailable
          return;
        }

        // Get the device heading
        // On iOS: provides true north heading (already adjusted for declination)
        // On Android: provides magnetic north heading
        final heading = event.heading ?? 0.0;

        // Emit the heading
        _headingController.add(heading);
      },
      onError: (error) {
        throw CompassServiceException(
          'Compass sensor error: ${error.toString()}',
        );
      },
    );

    if (_subscription == null) {
      throw const CompassServiceException(
        'Compass sensor is not available on this device.',
      );
    }
  }

  /// Stops listening to compass sensor updates.
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Calculates the Qibla angle for display on the compass.
  ///
  /// The Qibla angle represents how much to rotate the Qibla arrow
  /// relative to the device's current orientation.
  ///
  /// Parameters:
  /// - [deviceHeading]: Device heading in degrees (0-360)
  /// - [qiblaBearing]: Qibla bearing in degrees from true north (0-360)
  ///
  /// Returns the angle in degrees (0-360) to rotate the Qibla arrow.
  /// A value of 0 means the arrow points to Qibla when device points north.
  ///
  /// Note: On iOS, deviceHeading is true north. On Android, it's magnetic north.
  /// For accurate Qibla direction on Android, magnetic declination adjustment
  /// would be needed (typically ±5-10° variance).
  double calculateQiblaAngle(double deviceHeading, double qiblaBearing) {
    // Qibla angle = device heading - Qibla bearing
    // This tells us how much to rotate the arrow to point to Qibla
    final qiblaAngle = deviceHeading - qiblaBearing;
    return _normalizeAngle(qiblaAngle);
  }

  /// Normalizes an angle to the 0-360 degree range.
  ///
  /// Handles negative angles and angles greater than 360.
  double _normalizeAngle(double angle) {
    return (angle % 360 + 360) % 360;
  }

  /// Disposes of resources used by the compass service.
  void dispose() {
    stopListening();
    _headingController.close();
  }
}

/// Exception thrown when compass service operations fail.
class CompassServiceException implements Exception {
  /// The error message describing the failure.
  final String message;

  /// Creates a new compass service exception with the given [message].
  const CompassServiceException(this.message);

  @override
  String toString() => message;
}
