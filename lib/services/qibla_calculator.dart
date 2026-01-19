import 'package:geolocator/geolocator.dart';

/// Service for calculating Qibla direction (bearing toward the Kaaba in Mecca).
class QiblaCalculator {
  /// Kaaba coordinates in Mecca, Saudi Arabia.
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  /// Calculates the Qibla bearing from a given position to the Kaaba.
  ///
  /// The bearing is returned in degrees from true north (0-360).
  /// Uses the [Geolocator.bearingBetween] method for accurate calculation.
  ///
  /// Parameters:
  /// - [latitude]: User's current latitude in decimal degrees
  /// - [longitude]: User's current longitude in decimal degrees
  ///
  /// Returns the bearing in degrees (0-360) where:
  /// - 0° = North
  /// - 90° = East
  /// - 180° = South
  /// - 270° = West
  double calculateQiblaBearing(double latitude, double longitude) {
    final bearing = Geolocator.bearingBetween(
      latitude,
      longitude,
      kaabaLatitude,
      kaabaLongitude,
    );
    return _normalizeAngle(bearing);
  }

  /// Normalizes an angle to the 0-360 degree range.
  ///
  /// Handles negative angles and angles greater than 360.
  double _normalizeAngle(double angle) {
    return (angle % 360 + 360) % 360;
  }
}
