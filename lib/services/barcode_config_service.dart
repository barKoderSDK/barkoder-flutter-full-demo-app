import 'package:barkoder_flutter/barkoder_flutter.dart';
import '../constants/barcode_types.dart';
import '../constants/modes.dart';

class BarcodeConfigService {
  static List<String> getEnabledTypesForMode(String mode) {
    switch (mode) {
      case ScannerModes.mode1D:
        return barcodeTypes1D.map((t) => t['id']!).toList();
      case ScannerModes.mode2D:
        return barcodeTypes2D.map((t) => t['id']!).toList();
      case ScannerModes.continuous:
      case ScannerModes.multiscan:
      case ScannerModes.anyscan:
        return [
          ...barcodeTypes1D.map((t) => t['id']!),
          ...barcodeTypes2D.map((t) => t['id']!),
        ];
      case ScannerModes.dotcode:
        return ['dotcode'];
      case ScannerModes.arMode:
        return ['qr', 'code128', 'code39', 'upcA', 'upcE', 'ean13', 'ean8'];
      case ScannerModes.vin:
        return ['code39', 'code128', 'qr', 'datamatrix', 'ocrText'];
      case ScannerModes.dpm:
        return ['qr', 'qrMicro', 'datamatrix'];
      case ScannerModes.deblur:
        return ['upcA', 'upcE', 'ean13', 'ean8'];
      case ScannerModes.mrz:
        return ['idDocument'];
      default:
        return ['ean13', 'upcA', 'code128', 'qr', 'datamatrix'];
    }
  }

  static bool isContinuousMode(String mode, Map<String, dynamic> settings) {
    if (settings.containsKey('continuousScanning')) {
      return settings['continuousScanning'] as bool;
    }

    return mode == ScannerModes.continuous ||
        mode == ScannerModes.multiscan ||
        mode == ScannerModes.mrz ||
        mode == ScannerModes.dotcode ||
        mode == ScannerModes.arMode;
  }

  static void applyModeSpecificSettings(
    Barkoder barkoder,
    String mode,
    Map<String, dynamic> settings,
  ) {
    switch (mode) {
      case ScannerModes.multiscan:
        barkoder.setMaximumResultsCount(200);
        barkoder.setMulticodeCachingDuration(3000);
        barkoder.setMulticodeCachingEnabled(true);
        barkoder.setDecodingSpeed(DecodingSpeed.normal);
        barkoder.setBarkoderResolution(BarkoderResolution.HD);
        break;
      case ScannerModes.vin:
        barkoder.setEnableVINRestrictions(true);
        barkoder.setRegionOfInterest(0, 35, 100, 30);
        barkoder.setRegionOfInterestVisible(true);
        barkoder.setDecodingSpeed(DecodingSpeed.slow);
        barkoder.setBarkoderResolution(BarkoderResolution.UHD);
        barkoder.setEnableMisshaped1DEnabled(settings['scanDeformed'] ?? true);
        break;
      case ScannerModes.dpm:
        barkoder.setDatamatrixDpmModeEnabled(true);
        barkoder.setRegionOfInterest(40, 40, 20, 10);
        barkoder.setRegionOfInterestVisible(true);
        barkoder.setDecodingSpeed(DecodingSpeed.slow);
        barkoder.setBarkoderResolution(BarkoderResolution.UHD);
        break;
      case ScannerModes.deblur:
        barkoder.setUpcEanDeblurEnabled(settings['scanBlurred'] ?? true);
        barkoder.setEnableMisshaped1DEnabled(true);
        break;
      case ScannerModes.dotcode:
        barkoder.setRegionOfInterest(30, 40, 40, 9);
        barkoder.setRegionOfInterestVisible(true);
        barkoder.setDecodingSpeed(DecodingSpeed.slow);
        barkoder.setBarkoderResolution(BarkoderResolution.HD);
        break;
      case ScannerModes.arMode:
        barkoder.setBarkoderResolution(BarkoderResolution.HD);
        barkoder.setDecodingSpeed(DecodingSpeed.slow);
        barkoder.setCloseSessionOnResultEnabled(false);
        barkoder.setARMode(
          settings['arMode'] ?? BarkoderARMode.interactiveEnabled,
        );
        barkoder.setARLocationType(
          settings['arLocationType'] ?? BarkoderARLocationType.boundingBox,
        );
        barkoder.setARHeaderShowMode(
          settings['arHeaderShowMode'] ?? BarkoderARHeaderShowMode.onSelected,
        );
        barkoder.setAROverlayRefresh(
          settings['arOverlayRefresh'] ?? BarkoderAROverlayRefresh.normal,
        );
        barkoder.setARDoubleTapToFreezeEnabled(
          settings['arDoubleTapToFreeze'] ?? true,
        );
        barkoder.setARSelectedLocationColor('#00FF00');
        barkoder.setARNonSelectedLocationColor('#FF0000');
        break;
      default:
        barkoder.setDecodingSpeed(DecodingSpeed.normal);
        barkoder.setBarkoderResolution(BarkoderResolution.HD);
        break;
    }
  }

  static List<String> getEnabledTypesDisplayNames(List<String> typeIds) {
    final allTypes = [...barcodeTypes1D, ...barcodeTypes2D];
    final displayNames = <String>[];

    for (final typeId in typeIds) {
      final type = allTypes.firstWhere(
        (t) => t['id'] == typeId,
        orElse: () => {'id': typeId, 'label': typeId},
      );
      displayNames.add(type['label']!);
    }

    return displayNames;
  }

  static BarcodeType getBarcodeTypeFromId(String typeId) {
    for (final type in BarcodeType.values) {
      if (barcodeTypeToId(type) == typeId) {
        return type;
      }
    }
    return BarcodeType.qr;
  }

  static String barcodeTypeToId(BarcodeType type) {
    switch (type) {
      case BarcodeType.aztec:
        return 'aztec';
      case BarcodeType.aztecCompact:
        return 'aztecCompact';
      case BarcodeType.qr:
        return 'qr';
      case BarcodeType.qrMicro:
        return 'qrMicro';
      case BarcodeType.code128:
        return 'code128';
      case BarcodeType.code93:
        return 'code93';
      case BarcodeType.code39:
        return 'code39';
      case BarcodeType.codabar:
        return 'codabar';
      case BarcodeType.code11:
        return 'code11';
      case BarcodeType.msi:
        return 'msi';
      case BarcodeType.upcA:
        return 'upcA';
      case BarcodeType.upcE:
        return 'upcE';
      case BarcodeType.upcE1:
        return 'upcE1';
      case BarcodeType.ean13:
        return 'ean13';
      case BarcodeType.ean8:
        return 'ean8';
      case BarcodeType.pdf417:
        return 'pdf417';
      case BarcodeType.pdf417Micro:
        return 'pdf417Micro';
      case BarcodeType.datamatrix:
        return 'datamatrix';
      case BarcodeType.code25:
        return 'code25';
      case BarcodeType.interleaved25:
        return 'interleaved25';
      case BarcodeType.itf14:
        return 'itf14';
      case BarcodeType.iata25:
        return 'iata25';
      case BarcodeType.matrix25:
        return 'matrix25';
      case BarcodeType.datalogic25:
        return 'datalogic25';
      case BarcodeType.coop25:
        return 'coop25';
      case BarcodeType.code32:
        return 'code32';
      case BarcodeType.telepen:
        return 'telepen';
      case BarcodeType.dotcode:
        return 'dotcode';
      case BarcodeType.databar14:
        return 'databar14';
      case BarcodeType.databarLimited:
        return 'databarLimited';
      case BarcodeType.databarExpanded:
        return 'databarExpanded';
      case BarcodeType.maxiCode:
        return 'maxiCode';
      case BarcodeType.australianPost:
        return 'australianPost';
      case BarcodeType.japanesePost:
        return 'japanesePost';
      case BarcodeType.royalMail:
        return 'royalMail';
      case BarcodeType.kix:
        return 'kix';
      case BarcodeType.postnet:
        return 'postnet';
      case BarcodeType.planet:
        return 'planet';
      case BarcodeType.postalIMB:
        return 'postalIMB';
      case BarcodeType.idDocument:
        return 'idDocument';
      default:
        return 'unknown';
    }
  }
}
