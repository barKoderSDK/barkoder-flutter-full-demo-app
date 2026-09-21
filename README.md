# barKoder Flutter Barcode Scanner Plugin

Integrate enterprise-grade barcode scanning into **Flutter applications for Android and iOS** with the official barKoder Flutter plugin. The plugin exposes the native barKoder scanning engine through a Flutter-friendly API, allowing one codebase to handle QR Codes, Data Matrix, PDF417, retail barcodes and demanding scanning workflows such as DPM, Batch MultiScan, VIN and MRZ.

Use this repository when you need a production barcode scanner inside a Flutter app rather than redirecting users to an external scanner application or relying on dedicated scanning hardware.

## Quick links

- **Flutter Barcode Scanner SDK:** [https://barkoder.com/barcode-scanner-sdk/frameworks/flutter](https://barkoder.com/barcode-scanner-sdk/frameworks/flutter)
- **pub.dev package:** [https://pub.dev/packages/barkoder_flutter](https://pub.dev/packages/barkoder_flutter)
- **Installation guide:** [https://barkoder.com/docs/v1/flutter/flutter-installation](https://barkoder.com/docs/v1/flutter/flutter-installation)
- **Flutter example:** [https://barkoder.com/docs/v1/flutter/flutter-example](https://barkoder.com/docs/v1/flutter/flutter-example)
- **API reference:** [https://barkoder.com/docs/v1/flutter/flutter-api-reference](https://barkoder.com/docs/v1/flutter/flutter-api-reference)
- **Full demo app:** [https://github.com/barKoderSDK/barkoder-flutter-full-demo-app](https://github.com/barKoderSDK/barkoder-flutter-full-demo-app)
- **Free trial:** [https://barkoder.com/trial](https://barkoder.com/trial)

## Key capabilities

barKoder is designed for production barcode capture workflows where speed and decode reliability matter. Depending on the license and configuration, the SDK supports capabilities such as:

- 30+ 1D and 2D barcode symbologies, including QR Code, Data Matrix, PDF417, Code 128, Code 39, EAN/UPC, Aztec, DotCode and GS1 formats
- [Direct Part Marking (DPM) scanning](https://barkoder.com/barcode-scanner-sdk/dpm) for difficult Data Matrix codes on metal, plastic and other industrial surfaces
- [Batch MultiScan](https://barkoder.com/barcode-scanner-sdk/batch-multiscan) for decoding multiple barcodes in a single camera view
- [VIN barcode scanning](https://barkoder.com/barcode-scanner-sdk/vin-scanning) for automotive workflows
- [MRZ scanning](https://barkoder.com/barcode-scanner-sdk/mrz) for passports, ID cards and travel documents
- Continuous scanning, image/gallery scanning and configurable regions of interest
- Advanced decoding for damaged, deformed, low-quality and blurry barcodes
- On-device scanning for normal mobile scanning workflows

For the complete feature set and platform-specific configuration options, use the official documentation linked below.


## Installation

Add the plugin to `pubspec.yaml` using the current package version from [pub.dev](https://pub.dev/packages/barkoder_flutter):

```yaml
dependencies:
  barkoder_flutter: <package-version>
```

Install dependencies:

```bash
flutter pub get
```

Import the plugin:

```dart
import 'package:barkoder_flutter/barkoder_flutter.dart';
```

Follow the [Flutter installation guide](https://barkoder.com/docs/v1/flutter/flutter-installation) for the required Android/iOS project configuration and camera permissions.

## Example

This repository includes an [`example`](./example) project. For a larger feature showcase, use the [barKoder Flutter full demo app](https://github.com/barKoderSDK/barkoder-flutter-full-demo-app).

The official Flutter documentation includes configuration examples for common decoders, scanning modes and result handling:

- [Flutter installation](https://barkoder.com/docs/v1/flutter/flutter-installation)
- [Flutter example](https://barkoder.com/docs/v1/flutter/flutter-example)
- [Flutter API reference](https://barkoder.com/docs/v1/flutter/flutter-api-reference)

## Trial license

You can evaluate barKoder in your own application with a free trial license:

**[Get a free barKoder SDK trial](https://barkoder.com/trial)**

The SDK can be initialized without a valid license for integration testing, but decoded results may be partially masked or marked as unlicensed. Use a valid trial or production license for complete results and licensed functionality.

Do not publish a trial license in a production application or public source repository.


## Support

Need help with integration or testing?

- Documentation: [https://barkoder.com/docs/v1/home](https://barkoder.com/docs/v1/home)
- Technical support: [support@barkoder.com](mailto:support@barkoder.com)
- Sales and licensing: [sales@barkoder.com](mailto:sales@barkoder.com)

## License

See the `LICENSE` file in this repository for the terms applicable to the repository contents. Use of the barKoder SDK itself is subject to the applicable barKoder license agreement.
