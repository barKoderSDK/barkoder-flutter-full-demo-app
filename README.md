# Barkoder App Flutter

A Flutter recreation of the Barkoder barcode scanner app with comprehensive scanning capabilities.

## Features

- **Multiple Scanning Modes**: 1D barcodes, 2D barcodes, continuous scanning, multi-scan, VIN, DPM, DeBlur, DotCode, AR Mode, and MRZ
- **Gallery Scanning**: Scan barcodes from images in your photo library
- **Scan History**: Automatic saving and tracking of scanned barcodes with deduplication
- **Barcode Details**: View detailed information about scanned barcodes
- **Export Options**: Copy to clipboard, search online, export to CSV
- **Flash and Zoom Controls**: Camera controls for optimal scanning
- **About Screen**: SDK information and device details

## Project Structure

```
lib/
├── constants/
│   ├── barcode_types.dart   # 1D and 2D barcode type definitions
│   ├── home_sections.dart   # Home screen grid configuration
│   └── modes.dart          # Scanner mode constants
├── models/
│   └── history_item.dart   # Scan history data model
├── screens/
│   ├── home_screen.dart           # Main screen with scanner modes
│   ├── scanner_screen.dart        # Barcode scanner interface
│   ├── barcode_details_screen.dart # Individual barcode details
│   ├── history_screen.dart        # Scan history list
│   └── about_screen.dart         # App and SDK information
├── services/
│   └── history_service.dart # Scan history storage management
├── widgets/
│   ├── top_bar.dart        # App bar component
│   ├── bottom_bar.dart     # Navigation bar
│   └── home_grid.dart      # Home screen grid layout
└── main.dart              # App entry point and routing
```

## Setup Instructions

### 1. Install Dependencies

```bash
cd barkoder_app_flutter
flutter pub get
```

### 2. Configure Barkoder SDK

You need to add your Barkoder license key in the scanner screen:

1. Open `lib/screens/scanner_screen.dart`
2. Find the line: `await _barkoderViewController.setLicenseKey('YOUR_LICENSE_KEY');`
3. Replace `'YOUR_LICENSE_KEY'` with your actual Barkoder license key

You can get a free trial license at: https://barkoder.com/trial

### 3. Platform-Specific Setup

#### Android

Add camera permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" />
<uses-feature android:name="android.hardware.camera.autofocus" />
```

Set minimum SDK version in `android/app/build.gradle`:

```gradle
minSdkVersion 21
```

#### iOS

Add camera permissions to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app requires camera access to scan barcodes</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app requires photo library access to scan barcodes from images</string>
```

Set minimum iOS version in `ios/Podfile`:

```ruby
platform :ios, '13.0'
```

### 4. Run the App

```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter devices  # List available devices
flutter run -d <device-id>
```

## Dependencies

- **go_router**: Navigation and routing
- **barkoder_flutter**: Barcode scanner SDK
- **shared_preferences**: Local data storage
- **path_provider**: File system paths
- **image_picker**: Gallery image selection
- **share_plus**: Share functionality
- **url_launcher**: Open URLs and deep links
- **device_info_plus**: Device information
- **intl**: Date formatting

## Features Implementation

### Home Screen
- Grid layout with scanning mode options
- Direct navigation to scanner or gallery
- Access to history and about sections

### Scanner Screen
- Real-time barcode scanning with Barkoder SDK
- Multiple barcode type support (1D, 2D)
- Flash and camera controls
- Automatic scan result handling
- Pause/resume scanning capability

### Barcode Details Screen
- Display scanned barcode information
- Barcode type identification
- Copy to clipboard
- Google search integration
- Image preview (when available)

### History Screen
- Chronological list of scanned barcodes
- Grouped by date
- Duplicate detection with count
- Quick access to details

### About Screen
- SDK version information
- App version
- Device ID
- Links to resources and trial signup

## Scan History

Scans are automatically saved locally using SharedPreferences. The history service:
- Deduplicates identical scans (increments count)
- Stores barcode images efficiently
- Maintains chronological order
- Supports clearing history

## Customization

### Colors

The app uses a primary color theme defined in `main.dart`:
```dart
const Color(0xFFE52E4C) // Barkoder red
```

### Scanner Modes

Configure scanning modes in `lib/constants/modes.dart` and implement mode-specific logic in the scanner screen's `_configureScanningMode` method.

### Barcode Types

All supported barcode types are defined in `lib/constants/barcode_types.dart`.

## Next Steps

To fully match the React Native version, consider adding:
1. Advanced scanner settings panel
2. Gallery image scanning implementation
3. CSV export functionality
4. Continuous scanning mode with multiple result handling
5. AR mode visualization
6. More detailed error handling and user feedback

## License

This is a recreation of the Barkoder demo app. Please ensure you have appropriate licenses for:
- Barkoder SDK (https://barkoder.com/trial)
- Any other third-party packages used

## Support

For Barkoder SDK support:
- Website: https://barkoder.com/
- Documentation: https://docs.barkoder.com/
- Contact: https://barkoder.com/contact

