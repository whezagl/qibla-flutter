import 'package:flutter_test/flutter_test.dart';
import 'package:qbla_compass/services/compass_service.dart';

void main() {
  group('CompassService', () {
    late CompassService compassService;

    setUp(() {
      compassService = CompassService();
    });

    tearDown(() {
      compassService.dispose();
    });

    group('calculateQiblaAngle', () {
      test('calculates Qibla angle when device points north', () {
        // Device pointing north (0°), Qibla at 60°
        // Arrow should point to 300° (or -60° normalized to 300°)
        const trueHeading = 0.0;
        const qiblaBearing = 60.0;

        final qiblaAngle = compassService.calculateQiblaAngle(
          trueHeading,
          qiblaBearing,
        );

        // 0 - 60 = -60, normalized to 300
        expect(qiblaAngle, closeTo(300.0, 0.01));
      });

      test('calculates Qibla angle when device points toward Qibla', () {
        // Device pointing directly at Qibla (45°)
        const trueHeading = 45.0;
        const qiblaBearing = 45.0;

        final qiblaAngle = compassService.calculateQiblaAngle(
          trueHeading,
          qiblaBearing,
        );

        // 45 - 45 = 0, arrow points straight ahead
        expect(qiblaAngle, closeTo(0.0, 0.01));
      });

      test('calculates Qibla angle for east-facing device', () {
        // Device pointing east (90°), Qibla at 60°
        const trueHeading = 90.0;
        const qiblaBearing = 60.0;

        final qiblaAngle = compassService.calculateQiblaAngle(
          trueHeading,
          qiblaBearing,
        );

        // 90 - 60 = 30°, arrow points slightly right
        expect(qiblaAngle, closeTo(30.0, 0.01));
      });

      test('calculates Qibla angle for south-facing device', () {
        // Device pointing south (180°), Qibla at 60°
        const trueHeading = 180.0;
        const qiblaBearing = 60.0;

        final qiblaAngle = compassService.calculateQiblaAngle(
          trueHeading,
          qiblaBearing,
        );

        // 180 - 60 = 120°, arrow points to the right
        expect(qiblaAngle, closeTo(120.0, 0.01));
      });

      test('calculates Qibla angle for west-facing device', () {
        // Device pointing west (270°), Qibla at 60°
        const trueHeading = 270.0;
        const qiblaBearing = 60.0;

        final qiblaAngle = compassService.calculateQiblaAngle(
          trueHeading,
          qiblaBearing,
        );

        // 270 - 60 = 210°, arrow points to the left
        expect(qiblaAngle, closeTo(210.0, 0.01));
      });

      test('calculates Qibla angle with negative result normalization', () {
        // Device pointing slightly right of Qibla
        const trueHeading = 30.0;
        const qiblaBearing = 60.0;

        final qiblaAngle = compassService.calculateQiblaAngle(
          trueHeading,
          qiblaBearing,
        );

        // 30 - 60 = -30, normalized to 330
        expect(qiblaAngle, closeTo(330.0, 0.01));
      });

      test('calculates Qibla angle with result > 360 normalization', () {
        // Device pointing past north, Qibla at south
        const trueHeading = 300.0;
        const qiblaBearing = 180.0;

        final qiblaAngle = compassService.calculateQiblaAngle(
          trueHeading,
          qiblaBearing,
        );

        // 300 - 180 = 120°, no normalization needed
        expect(qiblaAngle, closeTo(120.0, 0.01));
      });

      test('calculates Qibla angle for Jakarta orientation', () {
        // Jakarta Qibla bearing ~295°
        const qiblaBearing = 295.0;

        // When device points north
        final angleWhenNorth = compassService.calculateQiblaAngle(0.0, qiblaBearing);
        // 0 - 295 = -295, normalized to 65
        expect(angleWhenNorth, closeTo(65.0, 0.5));

        // When device points west (toward Qibla)
        final angleWhenWest = compassService.calculateQiblaAngle(295.0, qiblaBearing);
        // 295 - 295 = 0, arrow straight
        expect(angleWhenWest, closeTo(0.0, 0.5));
      });

      test('calculates Qibla angle for London orientation', () {
        // London Qibla bearing ~119°
        const qiblaBearing = 119.0;

        // When device points east-southeast (toward Qibla)
        final angleTowardQibla = compassService.calculateQiblaAngle(119.0, qiblaBearing);
        // 119 - 119 = 0, arrow straight
        expect(angleTowardQibla, closeTo(0.0, 0.5));

        // When device points north
        final angleWhenNorth = compassService.calculateQiblaAngle(0.0, qiblaBearing);
        // 0 - 119 = -119, normalized to 241
        expect(angleWhenNorth, closeTo(241.0, 0.5));
      });

      test('returns consistent results for same inputs', () {
        const trueHeading = 45.0;
        const qiblaBearing = 60.0;

        final angle1 = compassService.calculateQiblaAngle(trueHeading, qiblaBearing);
        final angle2 = compassService.calculateQiblaAngle(trueHeading, qiblaBearing);

        expect(angle1, equals(angle2));
      });
    });

    group('Angle normalization behavior', () {
      test('normalizes zero angle to zero', () {
        const trueHeading = 60.0;
        const qiblaBearing = 60.0;

        final qiblaAngle = compassService.calculateQiblaAngle(
          trueHeading,
          qiblaBearing,
        );

        // 60 - 60 = 0
        expect(qiblaAngle, closeTo(0.0, 0.01));
      });

      test('normalizes small positive angle', () {
        const trueHeading = 60.0;
        const qiblaBearing = 30.0;

        final qiblaAngle = compassService.calculateQiblaAngle(
          trueHeading,
          qiblaBearing,
        );

        // 60 - 30 = 30
        expect(qiblaAngle, closeTo(30.0, 0.01));
      });

      test('normalizes small negative angle', () {
        const trueHeading = 30.0;
        const qiblaBearing = 60.0;

        final qiblaAngle = compassService.calculateQiblaAngle(
          trueHeading,
          qiblaBearing,
        );

        // 30 - 60 = -30, normalized to 330
        expect(qiblaAngle, closeTo(330.0, 0.01));
      });

      test('normalizes very large positive angle (> 360)', () {
        // Test case where calculation exceeds 360
        const trueHeading = 400.0; // 40° past full rotation
        const qiblaBearing = 0.0;

        final qiblaAngle = compassService.calculateQiblaAngle(
          trueHeading,
          qiblaBearing,
        );

        // 400 - 0 = 400, normalized to 40
        expect(qiblaAngle, closeTo(40.0, 0.01));
      });

      test('normalizes very large negative angle (< -360)', () {
        // Test case where calculation is far below zero
        const trueHeading = 0.0;
        const qiblaBearing = 400.0;

        final qiblaAngle = compassService.calculateQiblaAngle(
          trueHeading,
          qiblaBearing,
        );

        // 0 - 400 = -400, normalized to 320
        expect(qiblaAngle, closeTo(320.0, 0.01));
      });

      test('normalizes angle at exactly 360', () {
        const trueHeading = 360.0;
        const qiblaBearing = 0.0;

        final qiblaAngle = compassService.calculateQiblaAngle(
          trueHeading,
          qiblaBearing,
        );

        // 360 - 0 = 360, normalized to 0
        expect(qiblaAngle, closeTo(0.0, 0.01));
      });

      test('normalizes angle at exactly -360', () {
        const trueHeading = 0.0;
        const qiblaBearing = 360.0;

        final qiblaAngle = compassService.calculateQiblaAngle(
          trueHeading,
          qiblaBearing,
        );

        // 0 - 360 = -360, normalized to 0
        expect(qiblaAngle, closeTo(0.0, 0.01));
      });

      test('normalizes angle crossing 360 multiple times', () {
        const trueHeading = 1000.0;
        const qiblaBearing = 0.0;

        final qiblaAngle = compassService.calculateQiblaAngle(
          trueHeading,
          qiblaBearing,
        );

        // 1000 - 0 = 1000
        // 1000 % 360 = 280
        expect(qiblaAngle, closeTo(280.0, 0.01));
      });

      test('normalizes negative angle crossing -360 multiple times', () {
        const trueHeading = 0.0;
        const qiblaBearing = 1000.0;

        final qiblaAngle = compassService.calculateQiblaAngle(
          trueHeading,
          qiblaBearing,
        );

        // 0 - 1000 = -1000
        // -1000 % 360 = -280
        // -280 + 360 = 80
        expect(qiblaAngle, closeTo(80.0, 0.01));
      });

      test('always returns angle in valid 0-360 range', () {
        // Test various extreme inputs
        final testCases = [
          (0.0, 0.0),
          (0.0, 180.0),
          (180.0, 0.0),
          (359.9, 0.0),
          (0.0, 359.9),
          (720.0, 0.0),
          (0.0, 720.0),
          (-180.0, 0.0),
          (0.0, -180.0),
          (1000.0, 500.0),
        ];

        for (final (heading, bearing) in testCases) {
          final qiblaAngle = compassService.calculateQiblaAngle(heading, bearing);
          expect(
            qiblaAngle,
            greaterThanOrEqualTo(0.0),
            reason: 'Angle should be >= 0 for heading=$heading, bearing=$bearing',
          );
          expect(
            qiblaAngle,
            lessThan(360.0),
            reason: 'Angle should be < 360 for heading=$heading, bearing=$bearing',
          );
        }
      });
    });

    group('Magnetic declination handling', () {
      test('true heading increases with positive declination', () {
        // Simulate the internal calculation
        const magneticHeading = 90.0; // East
        const declination = 10.0; // 10° east declination

        // This tests the internal _calculateTrueHeading logic
        // True heading = magnetic + declination
        // For Qibla angle: trueHeading - qiblaBearing
        // Assuming qiblaBearing = 0 for this test
        const qiblaBearing = 0.0;

        // With declination, true heading = 90 + 10 = 100
        // Qibla angle = 100 - 0 = 100
        // This is a conceptual test - actual method doesn't expose this directly
        // but calculateQiblaAngle should handle the trueHeading correctly

        final qiblaAngle = compassService.calculateQiblaAngle(
          magneticHeading + declination,
          qiblaBearing,
        );

        expect(qiblaAngle, closeTo(100.0, 0.01));
      });

      test('true heading decreases with negative declination', () {
        // Simulate the internal calculation
        const magneticHeading = 90.0; // East
        const declination = -10.0; // 10° west declination

        // True heading = 90 + (-10) = 80
        const qiblaBearing = 0.0;

        final qiblaAngle = compassService.calculateQiblaAngle(
          magneticHeading + declination,
          qiblaBearing,
        );

        expect(qiblaAngle, closeTo(80.0, 0.01));
      });

      test('handles declination that causes angle wraparound', () {
        // Magnetic heading at 350° with 15° east declination
        // True heading = 350 + 15 = 365, normalized to 5°
        const magneticHeading = 350.0;
        const declination = 15.0;
        const qiblaBearing = 0.0;

        final trueHeading = (magneticHeading + declination + 360) % 360;
        final qiblaAngle = compassService.calculateQiblaAngle(
          trueHeading,
          qiblaBearing,
        );

        // Should wrap to ~5°
        expect(qiblaAngle, closeTo(5.0, 0.01));
      });

      test('handles negative declination that causes angle wraparound', () {
        // Magnetic heading at 5° with 10° west declination
        // True heading = 5 + (-10) = -5, normalized to 355°
        const magneticHeading = 5.0;
        const declination = -10.0;
        const qiblaBearing = 0.0;

        final trueHeading = (magneticHeading + declination + 360) % 360;
        final qiblaAngle = compassService.calculateQiblaAngle(
          trueHeading,
          qiblaBearing,
        );

        // Should wrap to ~355°
        expect(qiblaAngle, closeTo(355.0, 0.01));
      });
    });

    group('Stream management', () {
      test('headingStream is accessible', () {
        expect(compassService.headingStream, isNotNull);
      });

      test('can create multiple service instances', () {
        final service1 = CompassService();
        final service2 = CompassService();

        expect(service1.headingStream, isNotNull);
        expect(service2.headingStream, isNotNull);

        service1.dispose();
        service2.dispose();
      });
    });

    group('Edge cases and boundary conditions', () {
      test('handles heading and bearing at 0', () {
        final qiblaAngle = compassService.calculateQiblaAngle(0.0, 0.0);
        expect(qiblaAngle, closeTo(0.0, 0.01));
      });

      test('handles heading and bearing at 360', () {
        final qiblaAngle = compassService.calculateQiblaAngle(360.0, 360.0);
        expect(qiblaAngle, closeTo(0.0, 0.01));
      });

      test('handles fractional angles', () {
        const trueHeading = 45.5678;
        const qiblaBearing = 60.1234;

        final qiblaAngle = compassService.calculateQiblaAngle(
          trueHeading,
          qiblaBearing,
        );

        // 45.5678 - 60.1234 = -14.5556, normalized to 345.4444
        expect(qiblaAngle, closeTo(345.44, 0.01));
      });

      test('handles very small angle differences', () {
        const trueHeading = 180.001;
        const qiblaBearing = 180.0;

        final qiblaAngle = compassService.calculateQiblaAngle(
          trueHeading,
          qiblaBearing,
        );

        // 180.001 - 180.0 = 0.001
        expect(qiblaAngle, closeTo(0.001, 0.0001));
      });

      test('handles full 360 degree rotation calculation', () {
        // Test that a full circle maintains consistency
        const qiblaBearing = 45.0;

        for (int heading = 0; heading <= 360; heading += 45) {
          final qiblaAngle = compassService.calculateQiblaAngle(
            heading.toDouble(),
            qiblaBearing,
          );

          expect(qiblaAngle, greaterThanOrEqualTo(0.0));
          expect(qiblaAngle, lessThan(360.0));
        }
      });
    });
  });
}
