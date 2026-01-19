# End-to-End Verification Guide

## Qibla Compass App - Physical Device Testing

This document provides step-by-step instructions for end-to-end verification of the Qibla Compass app on a physical Android device.

## Prerequisites

1. **Physical Android Device** (required - sensors not available in emulators)
   - Android 5.0 (API 21) or higher
   - Magnetometer and accelerometer sensors
   - GPS/location services

2. **Build the APK**
   ```bash
   cd qbla_compass
   flutter build apk --release
   ```
   - Output: `build/app/outputs/flutter-apk/app-release.apk`

3. **Install APK on Device**
   - Transfer APK to device via USB, email, or cloud storage
   - Enable "Install from Unknown Sources" in device settings
   - Open APK file to install

## Verification Steps

### 1. First Launch & Permissions

| Step | Action | Expected Result | ✓ |
|------|--------|-----------------|---|
| 1.1 | Open the app | App launches within 2 seconds | |
| 1.2 | Location permission prompt appears | "Allow Qibla Compass to access your location?" | |
| 1.3 | Tap "Allow" | Permission granted, loading indicator shows | |
| 1.4 | Wait for location acquisition | "Getting your location..." message appears | |
| 1.5 | Location acquired within 5 seconds | Compass displays with Qibla arrow | |

### 2. Compass Display Verification

| Step | Action | Expected Result | ✓ |
|------|--------|-----------------|---|
| 2.1 | View compass rose | Circular dial with N/E/S/W labels visible | |
| 2.2 | View Qibla arrow | Purple arrow points in Qibla direction | |
| 2.3 | View Qibla bearing text | "Qibla Bearing: XX.X°" displayed below compass | |
| 2.4 | View instruction text | "Hold your device flat" displayed | |

### 3. Device Rotation Test

| Step | Action | Expected Result | ✓ |
|------|--------|-----------------|---|
| 3.1 | Hold device flat, pointing north | Arrow points toward Qibla | |
| 3.2 | Rotate device 90° clockwise | Arrow rotates 90° counter-clockwise (relative to device) | |
| 3.3 | Rotate device to face east | Arrow rotates smoothly | |
| 3.4 | Rotate device 360° slowly | Arrow makes full rotation smoothly | |
| 3.5 | Rotate device quickly | Arrow responds without lag or stuttering | |

### 4. Qibla Direction Accuracy

| Step | Action | Expected Result | ✓ |
|------|--------|-----------------|---|
| 4.1 | Note your current location | Get latitude/longitude from device GPS | |
| 4.2 | Calculate expected Qibla bearing | Use online Qibla calculator or reference | |
| 4.3 | Compare with app's Qibla bearing | Should match within ±10° (±5° for iOS) | |
| 4.4 | Point device toward known Qibla direction | Arrow should point upward when aligned | |

**Note**: Android devices use magnetic north (±5-10° variance from true north). iOS devices use true north.

### 5. Error Handling

| Step | Action | Expected Result | ✓ |
|------|--------|-----------------|---|
| 5.1 | Deny location permission | Error message with "Retry" button appears | |
| 5.2 | Tap "Retry" and grant permission | Compass loads successfully | |
| 5.3 | Disable device GPS | Error message about location services | |
| 5.4 | Re-enable GPS and tap "Retry" | Compass loads successfully | |

### 6. Console & Performance

| Step | Action | Expected Result | ✓ |
|------|--------|-----------------|---|
| 6.1 | Run `flutter run` for console output | No errors or exceptions during operation | |
| 6.2 | Monitor compass updates | Smooth 60fps animation during rotation | |
| 6.3 | Check memory usage | No memory leaks after 5 minutes of use | |
| 6.4 | Test for 10 minutes | No performance degradation | |

## Known Limitations

1. **Android Magnetic Declination**
   - Android compass provides magnetic north headings
   - May vary ±5-10° from true north depending on location
   - iOS provides true north headings (more accurate)

2. **Sensor Interference**
   - Metal objects or magnets can affect compass accuracy
   - Calibrate device by moving in figure-8 pattern if inaccurate

3. **Location Accuracy**
   - Requires GPS signal for accurate Qibla calculation
   - Indoor use may reduce accuracy

## Reference Qibla Bearings

For quick verification, here are approximate Qibla bearings from major cities:

| City | Qibla Bearing |
|------|---------------|
| Jakarta, Indonesia | ~295° |
| London, UK | ~119° |
| New York, USA | ~58° |
| Tokyo, Japan | ~293° |
| Sydney, Australia | ~277° |
| Jeddah, Saudi Arabia | ~23° |
| Dubai, UAE | ~25° |
| Istanbul, Turkey | ~142° |

## Verification Checklist Summary

- [ ] App installs and launches successfully
- [ ] Location permissions requested and handled correctly
- [ ] Compass displays within 5 seconds of launch
- [ ] Compass rose with cardinal directions is visible
- [ ] Qibla arrow rotates smoothly during device rotation
- [ ] Qibla bearing display shows correct value (±10° tolerance)
- [ ] No console errors during operation
- [ ] Smooth 60fps animation performance
- [ ] Error states handled gracefully (permission denied, GPS off)
- [ ] App works correctly for 10+ minutes without issues

## Sign-off

**Tester**: _______________________
**Date**: _______________________
**Device Model**: _______________________
**Android Version**: _______________________
**Overall Result**: PASS / FAIL
**Notes**: _______________________

---

## Troubleshooting

### Compass doesn't appear
- Check that location permissions are granted
- Ensure GPS/location services are enabled
- Try force-stopping and reopening the app

### Arrow doesn't rotate
- Ensure device has magnetometer sensor
- Calibrate compass by moving device in figure-8 pattern
- Check for nearby metal objects causing interference

### Inaccurate Qibla direction
- Verify location is accurate
- Allow GPS to acquire accurate fix (stay near window)
- For Android, expect ±5-10° variance (magnetic vs true north)
- Recalibrate device compass

### App crashes
- Check console output for error messages
- Ensure Android version is 5.0 (API 21) or higher
- Report issue with device model and Android version
