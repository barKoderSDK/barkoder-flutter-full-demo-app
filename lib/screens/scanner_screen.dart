import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:barkoder_flutter/barkoder_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/history_service.dart';
import '../models/history_item.dart';
import '../constants/barcode_types.dart';
import '../constants/modes.dart';
import './settings_screen.dart';

class ScannerScreen extends StatefulWidget {
  final String mode;

  const ScannerScreen({super.key, required this.mode});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  Barkoder? _barkoder;
  List<HistoryItem> _scannedItems = [];
  bool _isFlashOn = false;
  bool _isScanningPaused = false;
  double _zoomLevel = 1.0;
  bool _isFrontCamera = false;
  List<String> _enabledBarcodeTypes = [];
  Map<String, bool> _enabledTypesMap = {};
  Map<String, dynamic> _settings = {};
  String?
  _fullCameraImagePath; // For displaying full image overlay in non-continuous modes

  void _onBarkoderViewCreated(Barkoder barkoder) async {
    _barkoder = barkoder;
    await _loadSavedSettings();
    await _configureBarkoderView();
  }

  Future<void> _configureBarkoderView() async {
    if (_barkoder == null) return;

    // If settings are not loaded yet, initialize with defaults
    if (_enabledTypesMap.isEmpty) {
      final enabledTypes = _getEnabledTypesForMode(widget.mode);
      setState(() {
        _enabledTypesMap = {for (var id in enabledTypes) id: true};
        _settings = {
          'compositeMode': false,
          'pinchToZoom': true,
          'locationInPreview': true,
          'regionOfInterest': false,
          'beepOnSuccess': true,
          'vibrateOnSuccess': true,
          'scanBlurred': widget.mode == ScannerModes.deblur,
          'scanDeformed': widget.mode == ScannerModes.vin,
          'continuousScanning': _isContinuousMode(widget.mode),
          'continuousThreshold': 5,
          'decodingSpeed': DecodingSpeed.normal,
          'resolution': BarkoderResolution.HD,
        };
      });
    }

    // Update display names based on current enabled types
    final enabledTypeIds = _enabledTypesMap.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    setState(() {
      _enabledBarcodeTypes = _getEnabledTypesDisplayNames(enabledTypeIds);
    });

    // Determine if continuous scanning
    final isContinuous = _isContinuousMode(widget.mode);

    // Configure Barkoder with basic settings first
    await _barkoder!.configureBarkoder(
      BarkoderConfig(
        locationInPreviewEnabled: _settings['locationInPreview'] ?? true,
        pinchToZoomEnabled: _settings['pinchToZoom'] ?? true,
        regionOfInterestVisible: _settings['regionOfInterest'] ?? false,
        beepOnSuccessEnabled: _settings['beepOnSuccess'] ?? true,
        vibrateOnSuccessEnabled: _settings['vibrateOnSuccess'] ?? true,
      ),
    );

    // Apply region of interest if enabled
    if (_settings['regionOfInterest'] == true) {
      await _barkoder!.setRegionOfInterest(20, 30, 60, 40);
    }

    // Apply composite mode
    await _barkoder!.setEnableComposite(
      _settings['compositeMode'] == true ? 1 : 0,
    );

    // Apply scan blurred and deformed settings
    if (_settings['scanBlurred'] == true) {
      await _barkoder!.setUpcEanDeblurEnabled(true);
    }
    if (_settings['scanDeformed'] == true) {
      await _barkoder!.setEnableMisshaped1DEnabled(true);
    }

    // Enable image and thumbnail capture
    await _barkoder!.setImageResultEnabled(true);
    // Enable thumbnail for all modes to get barcode-only image
    await _barkoder!.setBarcodeThumbnailOnResultEnabled(true);

    // Enable barcode types individually
    for (final type in BarcodeType.values) {
      final typeId = _barcodeTypeToId(type);
      final enabled = enabledTypeIds.contains(typeId);
      await _barkoder!.setBarcodeTypeEnabled(type, enabled);
    }

    // Apply mode-specific settings
    await _applyModeSpecificSettings(widget.mode);

    // Set continuous scanning
    await _barkoder!.setCloseSessionOnResultEnabled(!isContinuous);

    if (isContinuous) {
      // Get threshold from settings, default to 5 if not set
      final threshold = _settings['continuousThreshold'] as int? ?? 5;
      // Threshold values: -1 = ignore duplicates, 0 = instant, n > 0 = n seconds delay
      await _barkoder!.setThresholdBetweenDuplicatesScans(threshold);
    }

    // Start scanning
    _startScanning();
  }

  List<String> _getEnabledTypesForMode(String mode) {
    switch (mode) {
      case ScannerModes.mode1D:
        return barcodeTypes1D.map((t) => t['id']!).toList();
      case ScannerModes.mode2D:
        return barcodeTypes2D.map((t) => t['id']!).toList();
      case ScannerModes.continuous:
      case ScannerModes.multiscan:
      case ScannerModes.anyscan:
        // Enable all types
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
        // Default enabled types
        return ['ean13', 'upcA', 'code128', 'qr', 'datamatrix'];
    }
  }

  bool _isContinuousMode(String mode) {
    // Check if continuous scanning is explicitly set in settings
    if (_settings.containsKey('continuousScanning')) {
      return _settings['continuousScanning'] as bool;
    }

    // Otherwise, check the mode type
    return mode == ScannerModes.continuous ||
        mode == ScannerModes.multiscan ||
        mode == ScannerModes.mrz ||
        mode == ScannerModes.dotcode ||
        mode == ScannerModes.arMode;
  }

  Future<void> _applyModeSpecificSettings(String mode) async {
    if (_barkoder == null) return;

    switch (mode) {
      case ScannerModes.multiscan:
        await _barkoder!.setMaximumResultsCount(200);
        await _barkoder!.setMulticodeCachingDuration(3000);
        await _barkoder!.setMulticodeCachingEnabled(true);
        await _barkoder!.setDecodingSpeed(DecodingSpeed.normal);
        await _barkoder!.setBarkoderResolution(BarkoderResolution.HD);
        break;
      case ScannerModes.vin:
        await _barkoder!.setEnableVINRestrictions(true);
        await _barkoder!.setRegionOfInterest(0, 35, 100, 30);
        await _barkoder!.setRegionOfInterestVisible(true);
        await _barkoder!.setDecodingSpeed(DecodingSpeed.slow);
        await _barkoder!.setBarkoderResolution(BarkoderResolution.UHD);
        await _barkoder!.setEnableMisshaped1DEnabled(
          _settings['scanDeformed'] ?? true,
        );
        break;
      case ScannerModes.dpm:
        await _barkoder!.setBarcodeTypeEnabled(BarcodeType.datamatrix, true);
        await _barkoder!.setDatamatrixDpmModeEnabled(true);
        await _barkoder!.setRegionOfInterest(40, 40, 20, 10);
        await _barkoder!.setRegionOfInterestVisible(true);
        await _barkoder!.setDecodingSpeed(DecodingSpeed.slow);
        await _barkoder!.setBarkoderResolution(BarkoderResolution.UHD);
        break;
      case ScannerModes.deblur:
        await _barkoder!.setUpcEanDeblurEnabled(
          _settings['scanBlurred'] ?? true,
        );
        await _barkoder!.setEnableMisshaped1DEnabled(true);
        break;
      case ScannerModes.dotcode:
        await _barkoder!.setBarcodeTypeEnabled(BarcodeType.dotcode, true);
        await _barkoder!.setRegionOfInterest(30, 40, 40, 9);
        await _barkoder!.setRegionOfInterestVisible(true);
        await _barkoder!.setDecodingSpeed(DecodingSpeed.slow);
        await _barkoder!.setBarkoderResolution(BarkoderResolution.HD);
        break;
      case ScannerModes.arMode:
        await _barkoder!.setBarkoderResolution(BarkoderResolution.HD);
        await _barkoder!.setDecodingSpeed(DecodingSpeed.slow);
        await _barkoder!.setCloseSessionOnResultEnabled(false);
        await _barkoder!.setARMode(BarkoderARMode.interactiveEnabled);
        await _barkoder!.setARSelectedLocationColor('#00FF00');
        await _barkoder!.setARNonSelectedLocationColor('#FF0000');
        await _barkoder!.setARHeaderShowMode(
          BarkoderARHeaderShowMode.onSelected,
        );
        break;
      default:
        await _barkoder!.setDecodingSpeed(DecodingSpeed.normal);
        await _barkoder!.setBarkoderResolution(BarkoderResolution.HD);
        break;
    }
  }

  String _barcodeTypeToId(BarcodeType type) {
    // Map BarcodeType enum to string ID
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

  void _startScanning() {
    _barkoder?.startScanning((result) {
      _handleScanResult(result);
    });
  }

  void _handleScanResult(BarkoderResult result) async {
    // Get first decoder result if available
    if (result.decoderResults.isEmpty) {
      return;
    }

    final decoderResult = result.decoderResults.first;
    final String text = decoderResult.textualData;
    final String type = decoderResult.barcodeTypeName;

    // Process barcode image/thumbnail
    String? imagePath; // For barcode details/history (barcode-only)
    String? fullImagePath; // For display overlay (full camera image)

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final directory = await getApplicationDocumentsDirectory();

      // For MRZ mode: use thumbnail (cropped document)
      if (widget.mode == ScannerModes.mrz) {
        if (result.resultThumbnails != null &&
            result.resultThumbnails!.isNotEmpty) {
          final fileName = 'scan_$timestamp.jpg';
          final filePath = '${directory.path}/$fileName';
          final file = File(filePath);
          await file.writeAsBytes(result.resultThumbnails![0]);
          imagePath = filePath;
        }
      } else {
        // For other modes:
        // 1. Save full image for display overlay (if not continuous)
        if (!_isContinuousMode(widget.mode) && result.resultImage != null) {
          final fullFileName = 'full_$timestamp.jpg';
          final fullFilePath = '${directory.path}/$fullFileName';
          final fullFile = File(fullFilePath);
          await fullFile.writeAsBytes(result.resultImage!);
          fullImagePath = fullFilePath;
          _fullCameraImagePath = fullImagePath;
        }

        // 2. Save barcode-only thumbnail for details/history
        // Always prefer thumbnail (cropped barcode) over full camera image
        if (result.resultThumbnails != null &&
            result.resultThumbnails!.isNotEmpty) {
          final thumbnailFileName = 'scan_$timestamp.jpg';
          final thumbnailFilePath = '${directory.path}/$thumbnailFileName';
          final thumbnailFile = File(thumbnailFilePath);
          await thumbnailFile.writeAsBytes(result.resultThumbnails![0]);
          imagePath = thumbnailFilePath;
        }
        // Note: If thumbnail not available, imagePath remains null
        // This prevents showing the full camera image in the detail screen
      }
    } catch (e) {
      imagePath = null;
      fullImagePath = null;
    }

    final item = HistoryItem(
      text: text,
      type: type,
      image: imagePath,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    setState(() {
      _scannedItems.insert(0, item);
    });

    // Save to history
    await HistoryService.addScan(text: text, type: type, image: imagePath);

    // Pause scanning if not in continuous mode
    if (!_isContinuousMode(widget.mode)) {
      setState(() {
        _isScanningPaused = true;
      });
      _barkoder?.stopScanning();
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _exportToCSV() async {
    if (_scannedItems.isEmpty) return;

    try {
      // Create CSV content
      final csvContent = StringBuffer();
      csvContent.writeln('Type,Value,Timestamp');

      for (final item in _scannedItems) {
        final timestamp = DateTime.fromMillisecondsSinceEpoch(
          item.timestamp,
        ).toIso8601String();
        csvContent.writeln('${item.type},"${item.text}",$timestamp');
      }

      // Save CSV to temporary file
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/barcodes_$timestamp.csv';
      final file = File(filePath);
      await file.writeAsString(csvContent.toString());

      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Barcode Scan Results',
        text: 'Scanned barcodes',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing CSV: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _searchBarcode(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for: $text'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    _barkoder?.setFlashEnabled(_isFlashOn);
  }

  void _toggleZoom() {
    setState(() {
      _zoomLevel = _zoomLevel == 1.0 ? 1.5 : 1.0;
    });
    _barkoder?.setZoomFactor(_zoomLevel);
  }

  void _toggleCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
    _barkoder?.setCamera((_isFrontCamera ? 1 : 0) as BarkoderCameraPosition);
  }

  List<String> _getEnabledTypesDisplayNames(List<String> typeIds) {
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

  BarcodeType _getBarcodeTypeFromId(String typeId) {
    for (final type in BarcodeType.values) {
      if (_barcodeTypeToId(type) == typeId) {
        return type;
      }
    }
    return BarcodeType.qr;
  }

  void _applySettingChange(String key, dynamic value) async {
    if (_barkoder == null) return;

    switch (key) {
      case 'compositeMode':
        await _barkoder!.setEnableComposite(value ? 1 : 0);
        break;
      case 'pinchToZoom':
        await _barkoder!.setPinchToZoomEnabled(value);
        break;
      case 'locationInPreview':
        await _barkoder!.setLocationInPreviewEnabled(value);
        break;
      case 'regionOfInterest':
        if (value) {
          await _barkoder!.setRegionOfInterest(20, 30, 60, 40);
        }
        await _barkoder!.setRegionOfInterestVisible(value);
        break;
      case 'beepOnSuccess':
        await _barkoder!.setBeepOnSuccessEnabled(value);
        break;
      case 'vibrateOnSuccess':
        await _barkoder!.setVibrateOnSuccessEnabled(value);
        break;
      case 'scanBlurred':
        await _barkoder!.setUpcEanDeblurEnabled(value);
        break;
      case 'scanDeformed':
        await _barkoder!.setEnableMisshaped1DEnabled(value);
        break;
      case 'continuousScanning':
        await _barkoder!.setCloseSessionOnResultEnabled(!value);
        if (value) {
          final threshold = _settings['continuousThreshold'] as int? ?? 5;
          await _barkoder!.setThresholdBetweenDuplicatesScans(threshold);
          _barkoder!.stopScanning();
          _startScanning();
        }
        break;
      case 'continuousThreshold':
        final threshold = value as int;
        await _barkoder!.setThresholdBetweenDuplicatesScans(threshold);
        break;
      case 'decodingSpeed':
        await _barkoder!.setDecodingSpeed(value);
        break;
      case 'resolution':
        await _barkoder!.setBarkoderResolution(value);
        break;
    }
  }

  void _resetConfig() async {
    final enabledTypes = _getEnabledTypesForMode(widget.mode);
    setState(() {
      _enabledTypesMap = {for (var id in enabledTypes) id: true};
      _settings = {
        'compositeMode': false,
        'pinchToZoom': true,
        'locationInPreview': true,
        'regionOfInterest': false,
        'beepOnSuccess': true,
        'vibrateOnSuccess': true,
        'scanBlurred': widget.mode == ScannerModes.deblur,
        'scanDeformed': widget.mode == ScannerModes.vin,
        'continuousScanning': _isContinuousMode(widget.mode),
        'continuousThreshold': 5,
        'decodingSpeed': DecodingSpeed.normal,
        'resolution': BarkoderResolution.HD,
      };
      // Update display names
      _enabledBarcodeTypes = _getEnabledTypesDisplayNames(enabledTypes);
    });

    // Reconfigure barkoder
    await _configureBarkoderView();
    await _saveSettings();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'scanner_settings_${widget.mode}';

    final data = {
      'enabledTypes': _enabledTypesMap,
      'settings': _settings.map((k, v) {
        // Convert enum values to strings for serialization
        if (v is DecodingSpeed) {
          return MapEntry(k, 'DecodingSpeed.${v.toString().split('.').last}');
        } else if (v is BarkoderResolution) {
          return MapEntry(
            k,
            'BarkoderResolution.${v.toString().split('.').last}',
          );
        }
        return MapEntry(k, v);
      }),
    };

    await prefs.setString(key, jsonEncode(data));
  }

  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'scanner_settings_${widget.mode}';
    final savedData = prefs.getString(key);

    if (savedData != null) {
      try {
        final data = jsonDecode(savedData) as Map<String, dynamic>;
        final Map<String, bool> enabledTypes =
            (data['enabledTypes'] as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, v as bool),
            );
        final Map<String, dynamic> settings =
            (data['settings'] as Map<String, dynamic>).map((k, v) {
              // Convert string enum values back to enums
              if (v is String && v.startsWith('DecodingSpeed.')) {
                final enumValue = v.split('.').last;
                return MapEntry(
                  k,
                  DecodingSpeed.values.firstWhere(
                    (e) => e.toString().split('.').last == enumValue,
                    orElse: () => DecodingSpeed.normal,
                  ),
                );
              } else if (v is String && v.startsWith('BarkoderResolution.')) {
                final enumValue = v.split('.').last;
                return MapEntry(
                  k,
                  BarkoderResolution.values.firstWhere(
                    (e) => e.toString().split('.').last == enumValue,
                    orElse: () => BarkoderResolution.HD,
                  ),
                );
              }
              return MapEntry(k, v);
            });

        setState(() {
          _enabledTypesMap = enabledTypes;
          _settings = settings;
        });
      } catch (e) {
        // If error occurs during loading, use defaults
        final enabledTypes = _getEnabledTypesForMode(widget.mode);
        setState(() {
          _enabledTypesMap = {for (var id in enabledTypes) id: true};
          _settings = {
            'compositeMode': false,
            'pinchToZoom': true,
            'locationInPreview': true,
            'regionOfInterest': false,
            'beepOnSuccess': true,
            'vibrateOnSuccess': true,
            'scanBlurred': widget.mode == ScannerModes.deblur,
            'scanDeformed': widget.mode == ScannerModes.vin,
            'continuousScanning': _isContinuousMode(widget.mode),
            'continuousThreshold': 5,
            'decodingSpeed': DecodingSpeed.normal,
            'resolution': BarkoderResolution.HD,
          };
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Barkoder View
          BarkoderView(
            licenseKey: dotenv.env['BARKODER_LICENSE_KEY'] ?? '',
            onBarkoderViewCreated: _onBarkoderViewCreated,
          ),

          // Scanning paused overlay (only for non-continuous modes)
          if (_isScanningPaused && !_isContinuousMode(widget.mode))
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isScanningPaused = false;
                    _scannedItems.clear();
                    _fullCameraImagePath = null;
                  });
                  _startScanning();
                },
                child: Container(
                  decoration: BoxDecoration(
                    image: _fullCameraImagePath != null
                        ? DecorationImage(
                            image: FileImage(File(_fullCameraImagePath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: _fullCameraImagePath == null
                        ? Colors.black.withValues(alpha: 0.7)
                        : null,
                  ),
                ),
              ),
            ),

          // "Tap anywhere to continue" bar - positioned above the bottom card
          if (_isScanningPaused &&
              !_isContinuousMode(widget.mode) &&
              _scannedItems.isNotEmpty)
            Positioned(
              bottom: 280,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isScanningPaused = false;
                    _scannedItems.clear();
                    _fullCameraImagePath = null;
                  });
                  _startScanning();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 60),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/touch_icon.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Tap anywhere to continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Top Bar Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () => context.pop(),
                        ),
                        SvgPicture.asset(
                          'assets/images/logo_barkoder_white.svg',
                          height: 20,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SettingsScreen(
                                  mode: widget.mode,
                                  enabledTypes: _enabledTypesMap,
                                  settings: _settings,
                                  onToggleType: (typeId, enabled) {
                                    setState(() {
                                      _enabledTypesMap[typeId] = enabled;
                                      // Update display names
                                      final enabledTypeIds = _enabledTypesMap
                                          .entries
                                          .where((entry) => entry.value)
                                          .map((entry) => entry.key)
                                          .toList();
                                      _enabledBarcodeTypes =
                                          _getEnabledTypesDisplayNames(
                                            enabledTypeIds,
                                          );
                                    });
                                    _barkoder?.setBarcodeTypeEnabled(
                                      _getBarcodeTypeFromId(typeId),
                                      enabled,
                                    );
                                    _saveSettings();
                                  },
                                  onUpdateSetting: (key, value) {
                                    setState(() {
                                      _settings[key] = value;
                                    });
                                    _applySettingChange(key, value);
                                    _saveSettings();
                                  },
                                  onResetConfig: () {
                                    _resetConfig();
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Left side - Scanned items list (stacking from bottom-up)
          if (_scannedItems.length > 1)
            Positioned(
              left: 0,
              bottom: _scannedItems.isNotEmpty ? 200 : 80,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.only(left: 8, bottom: 8),
                  width: 120,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    reverse: true,
                    itemCount: _scannedItems.length - 1,
                    itemBuilder: (context, index) {
                      final item = _scannedItems[index + 1];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.text.length > 10
                                  ? '${item.text.substring(0, 10)}...'
                                  : item.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

          // Bottom card - Latest scan details
          if (_scannedItems.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with result count
                      Text(
                        '${_scannedItems.length} result${_scannedItems.length == 1 ? "" : "s"} found (${_scannedItems.length} total)',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Barcode details in green box
                      GestureDetector(
                        onTap: () {
                          context.push(
                            '/barcode-details',
                            extra: _scannedItems.first,
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4EDDA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _scannedItems.first.type,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6C757D),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _scannedItems.first.text,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.info_outline,
                                size: 20,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildActionButton(
                            svgPath: 'assets/icons/icon_copy.svg',
                            label: 'Copy',
                            onPressed: () =>
                                _copyToClipboard(_scannedItems.first.text),
                          ),
                          _buildActionButton(
                            svgPath: 'assets/icons/icon_csv.svg',
                            label: 'CSV',
                            onPressed: _exportToCSV,
                          ),
                          _buildActionButton(
                            svgPath: 'assets/icons/icon_search.svg',
                            label: 'Search',
                            onPressed: () =>
                                _searchBarcode(_scannedItems.first.text),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Bottom Controls (zoom, flash, camera switch) - only show when no scans
          if (_scannedItems.isEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Enabled barcode types text
                      if (_enabledBarcodeTypes.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                            bottom: 30,
                          ),
                          child: Text(
                            _enabledBarcodeTypes.join(', '),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      // Control buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildControlButtonSvg(
                            svgPath: _zoomLevel == 1.0
                                ? 'assets/icons/zoom_in.svg'
                                : 'assets/icons/zoom_out.svg',
                            onPressed: _toggleZoom,
                          ),
                          const SizedBox(width: 20),
                          _buildControlButtonSvg(
                            svgPath: _isFlashOn
                                ? 'assets/icons/flash_off.svg'
                                : 'assets/icons/flash_on.svg',
                            onPressed: _toggleFlash,
                          ),
                          const SizedBox(width: 20),
                          _buildControlButtonSvg(
                            svgPath: 'assets/icons/camera_switch.svg',
                            onPressed: _toggleCamera,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String svgPath,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            svgPath,
            width: 20,
            colorFilter: const ColorFilter.mode(
              Color(0xFFE52E4C),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtonSvg({
    required String svgPath,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE52E4C), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: SvgPicture.asset(
          svgPath,
          width: 28,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        onPressed: onPressed,
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  void dispose() {
    _barkoder?.stopScanning();
    super.dispose();
  }
}
