import '../constants/modes.dart';

class SettingsHelper {
  static List<Map<String, String>> getBarcodeTypesForMode(String mode) {
    switch (mode) {
      case ScannerModes.dpm:
        return [
          {'id': 'qr', 'label': 'QR'},
          {'id': 'qrMicro', 'label': 'QR Micro'},
          {'id': 'datamatrix', 'label': 'Data Matrix'},
        ];
      case ScannerModes.vin:
        return [
          {'id': 'code39', 'label': 'Code 39'},
          {'id': 'code128', 'label': 'Code 128'},
          {'id': 'qr', 'label': 'QR'},
          {'id': 'datamatrix', 'label': 'Data Matrix'},
          {'id': 'ocrText', 'label': 'OCR Text'},
        ];
      case ScannerModes.mrz:
        return [];
      case ScannerModes.deblur:
        return [
          {'id': 'upcA', 'label': 'UPC-A'},
          {'id': 'upcE', 'label': 'UPC-E'},
          {'id': 'ean13', 'label': 'EAN-13'},
          {'id': 'ean8', 'label': 'EAN-8'},
        ];
      case ScannerModes.dotcode:
        return [];
      case ScannerModes.arMode:
        return [
          {'id': 'qr', 'label': 'QR'},
          {'id': 'code128', 'label': 'Code 128'},
          {'id': 'code39', 'label': 'Code 39'},
          {'id': 'upcA', 'label': 'UPC-A'},
          {'id': 'upcE', 'label': 'UPC-E'},
          {'id': 'ean13', 'label': 'EAN-13'},
          {'id': 'ean8', 'label': 'EAN-8'},
        ];
      default:
        return [];
    }
  }

  static bool shouldShowBarcodeTypes(String mode) {
    return mode == ScannerModes.mode1D ||
        mode == ScannerModes.mode2D ||
        mode == ScannerModes.continuous ||
        mode == ScannerModes.multiscan ||
        mode == 'anyscan' ||
        mode == ScannerModes.dpm ||
        mode == ScannerModes.vin ||
        mode == ScannerModes.mrz ||
        mode == ScannerModes.deblur ||
        mode == ScannerModes.dotcode ||
        mode == ScannerModes.arMode;
  }

  static bool shouldShow1DBarcodes(String mode) {
    return mode == ScannerModes.mode1D ||
        mode == ScannerModes.continuous ||
        mode == ScannerModes.multiscan ||
        mode == 'anyscan';
  }

  static bool shouldShow2DBarcodes(String mode) {
    return mode == ScannerModes.mode2D ||
        mode == ScannerModes.continuous ||
        mode == ScannerModes.multiscan ||
        mode == 'anyscan';
  }
}
