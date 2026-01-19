import 'package:flutter_test/flutter_test.dart';
import 'package:qbla_compass/services/qibla_calculator.dart';

void main() {
  group('QiblaCalculator', () {
    late QiblaCalculator calculator;

    setUp(() {
      calculator = QiblaCalculator();
    });

    group('calculateQiblaBearing', () {
      test('calculates correct bearing from Jakarta, Indonesia to Mecca', () {
        // Jakarta: 6.2088° S, 106.8456° E
        // Expected Qibla direction is approximately 295° (west-northwest)
        const jakartaLatitude = -6.2088;
        const jakartaLongitude = 106.8456;

        final bearing = calculator.calculateQiblaBearing(
          jakartaLatitude,
          jakartaLongitude,
        );

        // Verify bearing is in expected range (295° ± 2° for calculation tolerance)
        expect(bearing, greaterThanOrEqualTo(293.0));
        expect(bearing, lessThanOrEqualTo(297.0));
      });

      test('calculates correct bearing from London, UK to Mecca', () {
        // London: 51.5074° N, 0.1278° W
        // Expected Qibla direction is approximately 119° (east-southeast)
        const londonLatitude = 51.5074;
        const londonLongitude = -0.1278;

        final bearing = calculator.calculateQiblaBearing(
          londonLatitude,
          londonLongitude,
        );

        // Verify bearing is in expected range (119° ± 2°)
        expect(bearing, greaterThanOrEqualTo(117.0));
        expect(bearing, lessThanOrEqualTo(121.0));
      });

      test('calculates correct bearing from New York, USA to Mecca', () {
        // New York: 40.7128° N, 74.0060° W
        // Expected Qibla direction is approximately 58° (east-northeast)
        const newYorkLatitude = 40.7128;
        const newYorkLongitude = -74.0060;

        final bearing = calculator.calculateQiblaBearing(
          newYorkLatitude,
          newYorkLongitude,
        );

        // Verify bearing is in expected range (58° ± 2°)
        expect(bearing, greaterThanOrEqualTo(56.0));
        expect(bearing, lessThanOrEqualTo(60.0));
      });

      test('calculates correct bearing from Tokyo, Japan to Mecca', () {
        // Tokyo: 35.6762° N, 139.6503° E
        // Expected Qibla direction is approximately 294° (west-northwest)
        const tokyoLatitude = 35.6762;
        const tokyoLongitude = 139.6503;

        final bearing = calculator.calculateQiblaBearing(
          tokyoLatitude,
          tokyoLongitude,
        );

        // Verify bearing is in expected range (294° ± 2°)
        expect(bearing, greaterThanOrEqualTo(292.0));
        expect(bearing, lessThanOrEqualTo(296.0));
      });

      test('calculates correct bearing from location near Mecca', () {
        // Jeddah: 21.5433° N, 39.1728° E (near Mecca)
        // Expected Qibla direction should be roughly southeast (around 135°)
        const jeddahLatitude = 21.5433;
        const jeddahLongitude = 39.1728;

        final bearing = calculator.calculateQiblaBearing(
          jeddahLatitude,
          jeddahLongitude,
        );

        // Verify bearing is in expected range (135° ± 10° for close proximity)
        expect(bearing, greaterThanOrEqualTo(125.0));
        expect(bearing, lessThanOrEqualTo(145.0));
      });

      test('calculates correct bearing from Sydney, Australia to Mecca', () {
        // Sydney: 33.8688° S, 151.2093° E
        // Expected Qibla direction is approximately 281° (west-northwest)
        const sydneyLatitude = -33.8688;
        const sydneyLongitude = 151.2093;

        final bearing = calculator.calculateQiblaBearing(
          sydneyLatitude,
          sydneyLongitude,
        );

        // Verify bearing is in expected range (281° ± 2°)
        expect(bearing, greaterThanOrEqualTo(279.0));
        expect(bearing, lessThanOrEqualTo(283.0));
      });

      test('handles location at equator', () {
        // Equator at Prime Meridian: 0°, 0°
        const equatorLatitude = 0.0;
        const equatorLongitude = 0.0;

        final bearing = calculator.calculateQiblaBearing(
          equatorLatitude,
          equatorLongitude,
        );

        // Bearing should be northeast direction (around 60-70°)
        expect(bearing, greaterThanOrEqualTo(60.0));
        expect(bearing, lessThanOrEqualTo(70.0));
      });

      test('handles extreme northern latitude', () {
        // Near North Pole: 80.0° N, 0.0° E
        const arcticLatitude = 80.0;
        const arcticLongitude = 0.0;

        final bearing = calculator.calculateQiblaBearing(
          arcticLatitude,
          arcticLongitude,
        );

        // Should return a valid bearing regardless of extreme location
        expect(bearing, greaterThanOrEqualTo(0.0));
        expect(bearing, lessThan(360.0));
      });

      test('handles extreme southern latitude', () {
        // Near South Pole: -80.0° N, 0.0° E
        const antarcticLatitude = -80.0;
        const antarcticLongitude = 0.0;

        final bearing = calculator.calculateQiblaBearing(
          antarcticLatitude,
          antarcticLongitude,
        );

        // Should return a valid bearing regardless of extreme location
        expect(bearing, greaterThanOrEqualTo(0.0));
        expect(bearing, lessThan(360.0));
      });

      test('returns bearing in valid 0-360 range', () {
        // Test multiple locations to ensure all bearings are normalized
        final testLocations = [
          (51.5074, -0.1278), // London
          (40.7128, -74.006), // New York
          (35.6762, 139.6503), // Tokyo
          (-33.8688, 151.2093), // Sydney
          (1.3521, 103.8198), // Singapore
        ];

        for (final (lat, lng) in testLocations) {
          final bearing = calculator.calculateQiblaBearing(lat, lng);
          expect(bearing, greaterThanOrEqualTo(0.0));
          expect(bearing, lessThan(360.0));
        }
      });
    });

    group('Angle normalization behavior', () {
      test('normalizes bearing from Mecca to itself to 0', () {
        // At the Kaaba coordinates
        const kaabaLatitude = 21.4225;
        const kaabaLongitude = 39.8262;

        final bearing = calculator.calculateQiblaBearing(
          kaabaLatitude,
          kaabaLongitude,
        );

        // Bearing should be normalized to 0 when source equals destination
        expect(bearing, closeTo(0.0, 1.0));
      });

      test('handles International Date Line crossing', () {
        // Location west of Date Line: 20.0° N, 179.0° E
        const dateLineLatitude = 20.0;
        const dateLineLongitude = 179.0;

        final bearing = calculator.calculateQiblaBearing(
          dateLineLatitude,
          dateLineLongitude,
        );

        // Should handle the longitude wraparound correctly
        expect(bearing, greaterThanOrEqualTo(0.0));
        expect(bearing, lessThan(360.0));
      });

      test('handles antimeridian location', () {
        // Location east of Date Line: 20.0° N, -179.0° E
        const antimeridianLatitude = 20.0;
        const antimeridianLongitude = -179.0;

        final bearing = calculator.calculateQiblaBearing(
          antimeridianLatitude,
          antimeridianLongitude,
        );

        // Should handle the longitude wraparound correctly
        expect(bearing, greaterThanOrEqualTo(0.0));
        expect(bearing, lessThan(360.0));
      });
    });

    group('Kaaba coordinates', () {
      test('uses correct Kaaba latitude constant', () {
        expect(QiblaCalculator.kaabaLatitude, 21.4225);
      });

      test('uses correct Kaaba longitude constant', () {
        expect(QiblaCalculator.kaabaLongitude, 39.8262);
      });
    });

    group('Calculation consistency', () {
      test('returns consistent results for same input', () {
        const latitude = 51.5074;
        const longitude = -0.1278;

        final bearing1 = calculator.calculateQiblaBearing(latitude, longitude);
        final bearing2 = calculator.calculateQiblaBearing(latitude, longitude);

        expect(bearing1, equals(bearing2));
      });

      test('calculates different bearings for different locations', () {
        final bearingLondon = calculator.calculateQiblaBearing(51.5074, -0.1278);
        final bearingTokyo = calculator.calculateQiblaBearing(35.6762, 139.6503);

        expect(bearingLondon, isNot(equals(bearingTokyo)));
      });

      test('northern hemisphere has westward Qibla bias', () {
        // Northern hemisphere locations should generally have Qibla toward south/southeast
        const northernLatitude = 45.0;
        const northernLongitude = 0.0;

        final bearing = calculator.calculateQiblaBearing(
          northernLatitude,
          northernLongitude,
        );

        // Northern hemisphere locations face more southward toward Mecca
        expect(bearing, greaterThan(90.0)); // East of due south
        expect(bearing, lessThan(270.0)); // West of due south
      });
    });
  });
}
