import 'package:geolocator/geolocator.dart';

/// Service for handling GPS location and permissions.
///
/// Provides methods to check/request location permissions and retrieve
/// the user's current location with high accuracy for Qibla calculations.
class LocationService {
  /// Cached position to avoid unnecessary GPS queries.
  Position? _cachedPosition;

  /// Checks if location permissions are granted.
  ///
  /// Returns [LocationPermission.always] or [LocationPermission.whileInUse]
  /// if permissions are granted. Returns [LocationPermission.denied] or
  /// [LocationPermission.deniedForever] if permissions are not granted.
  Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (e) {
      // Return denied on error to allow graceful handling
      return LocationPermission.denied;
    }
  }

  /// Requests location permissions from the user.
  ///
  /// Returns the permission status after requesting. Note that if
  /// permissions were permanently denied, the user must manually enable
  /// them in app settings.
  Future<LocationPermission> requestPermission() async {
    try {
      return await Geolocator.requestPermission();
    } catch (e) {
      // Return denied on error to allow graceful handling
      return LocationPermission.denied;
    }
  }

  /// Gets the user's current position with high accuracy.
  ///
  /// Returns a cached position if available, otherwise fetches a new one.
  /// Throws [LocationServiceException] if permissions are denied or
  /// location services are disabled.
  ///
  /// The position is cached to avoid unnecessary GPS queries, as the
  /// Qibla direction only needs to be calculated once per session.
  Future<Position> getCurrentPosition() async {
    // Return cached position if available
    if (_cachedPosition != null) {
      return _cachedPosition!;
    }

    // Check permissions first
    final permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      // Request permission if not granted
      final newPermission = await requestPermission();
      if (newPermission == LocationPermission.denied) {
        throw const LocationServiceException(
          'Location permissions are denied. Please enable them in app settings.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationServiceException(
        'Location permissions are permanently denied. Please enable them in app settings.',
      );
    }

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceException(
        'Location services are disabled. Please enable them to use the Qibla compass.',
      );
    }

    try {
      // Get current position with high accuracy
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Cache the position
      _cachedPosition = position;
      return position;
    } catch (e) {
      throw LocationServiceException(
        'Failed to get location: ${e.toString()}',
      );
    }
  }

  /// Clears the cached position.
  ///
  /// Use this to force a fresh location fetch on the next call to
  /// [getCurrentPosition].
  void clearCache() {
    _cachedPosition = null;
  }
}

/// Exception thrown when location service operations fail.
class LocationServiceException implements Exception {
  /// The error message describing the failure.
  final String message;

  /// Creates a new location service exception with the given [message].
  const LocationServiceException(this.message);

  @override
  String toString() => message;
}
