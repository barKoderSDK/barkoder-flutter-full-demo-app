import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barkoder_flutter/barkoder_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/history_service.dart';
import '../services/barcode_config_service.dart';
import '../models/history_item.dart';
import '../constants/modes.dart';
import '../widgets/scanner/scanner_top_bar.dart';
import '../widgets/scanner/scanner_overlay.dart';
import '../widgets/scanner/scan_result_card.dart';
import '../widgets/scanner/scanner_controls.dart';
import '../widgets/scanner/continue_scanning_banner.dart';

class ScannerScreen extends StatefulWidget {
  final String mode;

  const ScannerScreen({super.key, required this.mode});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  Barkoder? _barkoder;
  // ignore: prefer_final_fields
  List<HistoryItem> _scannedItems = [];
  bool _isFlashOn = false;
  bool _isScanningPaused = false;
  bool _isSheetVisible = true;
  double _zoomLevel = 1.0;
  bool _isFrontCamera = false;
  List<String> _enabledBarcodeTypes = [];
  Map<String, bool> _enabledTypesMap = {};
  Map<String, dynamic> _settings = {};
  Uint8List? _fullCameraImageBytes;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _barkoder?.stopScanning();
    super.dispose();
  }

  void _onBarkoderViewCreated(Barkoder barkoder) async {
    _barkoder = barkoder;
    await _loadSavedSettings();
    _configureBarkoderView();
  }

  void _configureBarkoderView() {
    if (_barkoder == null) return;

    if (_enabledTypesMap.isEmpty) {
      final enabledTypes = BarcodeConfigService.getEnabledTypesForMode(
        widget.mode,
      );
      _enabledTypesMap = {for (var id in enabledTypes) id: true};
      _settings = {
        'compositeMode': false,
        'pinchToZoom': true,
        'locationInPreview': true,
        'regionOfInterest': false,
        'beepOnSuccess': true,
        'vibrateOnSuccess': false,
        'scanBlurred': widget.mode == ScannerModes.deblur,
        'scanDeformed': widget.mode == ScannerModes.vin,
        'continuousScanning': BarcodeConfigService.isContinuousMode(
          widget.mode,
          _settings,
        ),
        'continuousThreshold': 5,
        'decodingSpeed': DecodingSpeed.normal,
        'resolution': BarkoderResolution.HD,
        'showResultSheet': true,
        // AR Mode specific settings
        'arMode': BarkoderARMode.interactiveEnabled,
        'arLocationType': BarkoderARLocationType.boundingBox,
        'arHeaderShowMode': BarkoderARHeaderShowMode.onSelected,
        'arOverlayRefresh': BarkoderAROverlayRefresh.normal,
        'arDoubleTapToFreeze': true,
      };
    }

    final enabledTypeIds = _enabledTypesMap.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    setState(() {
      _enabledBarcodeTypes = BarcodeConfigService.getEnabledTypesDisplayNames(
        enabledTypeIds,
      );
    });

    final isContinuous = BarcodeConfigService.isContinuousMode(
      widget.mode,
      _settings,
    );

    _barkoder!.setRegionOfInterestVisible(
      _settings['regionOfInterest'] ?? false,
    );
    _barkoder!.setPinchToZoomEnabled(_settings['pinchToZoom'] ?? true);
    _barkoder!.setLocationInPreviewEnabled(
      _settings['locationInPreview'] ?? true,
    );
    _barkoder!.setBeepOnSuccessEnabled(_settings['beepOnSuccess'] ?? true);
    _barkoder!.setVibrateOnSuccessEnabled(
      _settings['vibrateOnSuccess'] ?? true,
    );
    _barkoder!.setCloseSessionOnResultEnabled(!isContinuous);
    _barkoder!.setImageResultEnabled(true);
    _barkoder!.setBarcodeThumbnailOnResultEnabled(true);
    _barkoder!.setLocationInImageResultEnabled(!isContinuous);
    _barkoder!.setMaximumResultsCount(200);

    if (_settings['regionOfInterest'] == true) {
      _barkoder!.setRegionOfInterest(5, 15, 90, 70);
    }

    _barkoder!.setEnableComposite(_settings['compositeMode'] == true ? 1 : 0);

    if (_settings['scanBlurred'] == true) {
      _barkoder!.setUpcEanDeblurEnabled(true);
    }
    if (_settings['scanDeformed'] == true) {
      _barkoder!.setEnableMisshaped1DEnabled(true);
    }

    for (final typeId in enabledTypeIds) {
      final type = BarcodeConfigService.getBarcodeTypeFromId(typeId);
      _barkoder!.setBarcodeTypeEnabled(type, true);
      if (widget.mode == ScannerModes.vin && typeId == 'ocrText') {
        _barkoder!.setCustomOption('enable_ocr_functionality', 1);
      }
    }

    BarcodeConfigService.applyModeSpecificSettings(
      _barkoder!,
      widget.mode,
      _settings,
    );

    if (isContinuous) {
      final threshold = _settings['continuousThreshold'] as int? ?? 5;
      _barkoder!.setThresholdBetweenDuplicatesScans(threshold);
    }

    if (!_isScanningPaused) {
      _startScanning();
    }
  }

  void _startScanning() {
    _barkoder?.startScanning((result) => _handleScanResult(result));
  }

  void _handleScanResult(BarkoderResult result) {
    if (result.decoderResults.isEmpty) return;

    final decoderResult = result.decoderResults.first;
    final String text = decoderResult.textualData;
    final String type = decoderResult.barcodeTypeName;
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    if (!BarcodeConfigService.isContinuousMode(widget.mode, _settings)) {
      _barkoder?.pauseScanning();
    }

    final item = HistoryItem(
      text: text,
      type: type,
      image: null,
      timestamp: timestamp,
      count: result.decoderResults.length,
    );

    setState(() {
      _scannedItems.insert(0, item);
      _isSheetVisible = _settings['showResultSheet'] ?? true;
      if (!BarcodeConfigService.isContinuousMode(widget.mode, _settings)) {
        _isScanningPaused = true;
        _fullCameraImageBytes = result.resultImage;
      }
    });

    _saveResultImagesAsync(result, timestamp, text, type);
  }

  void _saveResultImagesAsync(
    BarkoderResult result,
    int timestamp,
    String text,
    String type,
  ) async {
    String? imagePath;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final directoryPath = directory.path;

      if (widget.mode == ScannerModes.mrz) {
        if (result.resultThumbnails != null &&
            result.resultThumbnails!.isNotEmpty) {
          final fileName = 'scan_$timestamp.jpg';
          final filePath = '$directoryPath/$fileName';
          await File(filePath).writeAsBytes(result.resultThumbnails![0]);
          imagePath = filePath;
        }
      } else {
        final futures = <Future>[];

        if (!BarcodeConfigService.isContinuousMode(widget.mode, _settings) &&
            result.resultImage != null) {
          final fullFileName = 'full_$timestamp.jpg';
          final fullFilePath = '$directoryPath/$fullFileName';
          futures.add(File(fullFilePath).writeAsBytes(result.resultImage!));
        }

        if (result.resultThumbnails != null &&
            result.resultThumbnails!.isNotEmpty) {
          final thumbnailFileName = 'scan_$timestamp.jpg';
          final thumbnailFilePath = '$directoryPath/$thumbnailFileName';
          futures.add(
            File(
              thumbnailFilePath,
            ).writeAsBytes(result.resultThumbnails![0]).then((_) {
              imagePath = thumbnailFilePath;
            }),
          );
        }

        if (futures.isNotEmpty) {
          await Future.wait(futures);
        }
      }

      if (imagePath != null && _scannedItems.isNotEmpty) {
        setState(() {
          _scannedItems[0] = HistoryItem(
            text: _scannedItems[0].text,
            type: _scannedItems[0].type,
            image: imagePath,
            timestamp: _scannedItems[0].timestamp,
            count: _scannedItems[0].count,
          );
        });
      }

      HistoryService.addScan(text: text, type: type, image: imagePath);
    } catch (e) {
      // Ignore errors in saving images
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
      final csvContent = StringBuffer();
      csvContent.writeln('Type,Value,Timestamp');

      for (final item in _scannedItems) {
        final timestamp = DateTime.fromMillisecondsSinceEpoch(
          item.timestamp,
        ).toIso8601String();
        csvContent.writeln('${item.type},"${item.text}",$timestamp');
      }

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/barcodes_$timestamp.csv';
      await File(filePath).writeAsString(csvContent.toString());

      await Share.shareXFiles([
        XFile(filePath),
      ], subject: 'Barcode Scan Results');
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
    setState(() => _isFlashOn = !_isFlashOn);
    _barkoder?.setFlashEnabled(_isFlashOn);
  }

  void _toggleZoom() {
    setState(() => _zoomLevel = _zoomLevel == 1.0 ? 1.5 : 1.0);
    _barkoder?.setZoomFactor(_zoomLevel);
  }

  void _toggleCamera() {
    setState(() => _isFrontCamera = !_isFrontCamera);
    _barkoder?.setCamera(
      _isFrontCamera
          ? BarkoderCameraPosition.FRONT
          : BarkoderCameraPosition.BACK,
    );
  }

  void _applySettingChange(String key, dynamic value) {
    if (_barkoder == null) return;

    switch (key) {
      case 'compositeMode':
        _barkoder!.setEnableComposite(value ? 1 : 0);
        break;
      case 'pinchToZoom':
        _barkoder!.setPinchToZoomEnabled(value);
        break;
      case 'locationInPreview':
        _barkoder!.setLocationInPreviewEnabled(value);
        break;
      case 'regionOfInterest':
        _barkoder!.stopScanning();

        if (value) {
          if (widget.mode == ScannerModes.vin) {
            _barkoder!.setRegionOfInterest(0, 35, 100, 30);
          } else if (widget.mode == ScannerModes.dpm) {
            _barkoder!.setRegionOfInterest(40, 40, 20, 10);
          } else if (widget.mode == ScannerModes.dotcode) {
            _barkoder!.setRegionOfInterest(30, 40, 40, 9);
          } else if (widget.mode == ScannerModes.anyscan ||
              widget.mode == ScannerModes.mode1D ||
              widget.mode == ScannerModes.mode2D ||
              widget.mode == ScannerModes.continuous ||
              widget.mode == ScannerModes.multiscan) {
            _barkoder!.setRegionOfInterest(3, 20, 94, 60);
          } else {
            _barkoder!.setRegionOfInterest(3, 20, 94, 60);
          }
          _barkoder!.setRegionOfInterestVisible(true);
        } else {
          _barkoder!.setRegionOfInterestVisible(false);
        }

        _startScanning();
        break;
      case 'beepOnSuccess':
        _barkoder!.setBeepOnSuccessEnabled(value);
        break;
      case 'vibrateOnSuccess':
        _barkoder!.setVibrateOnSuccessEnabled(value);
        break;
      case 'scanBlurred':
        _barkoder!.setUpcEanDeblurEnabled(value);
        break;
      case 'scanDeformed':
        _barkoder!.setEnableMisshaped1DEnabled(value);
        break;
      case 'continuousScanning':
        _barkoder!.setCloseSessionOnResultEnabled(!value);
        if (value) {
          final threshold = _settings['continuousThreshold'] as int? ?? 5;
          _barkoder!.setThresholdBetweenDuplicatesScans(threshold);
          _barkoder!.stopScanning();
          _startScanning();
        }
        break;
      case 'continuousThreshold':
        _barkoder!.setThresholdBetweenDuplicatesScans(value as int);
        break;
      case 'decodingSpeed':
        _barkoder!.setDecodingSpeed(value);
        break;
      case 'resolution':
        _barkoder!.setBarkoderResolution(value);
        break;
      case 'arMode':
        _barkoder!.setARMode(value);
        break;
      case 'arLocationType':
        _barkoder!.setARLocationType(value);
        break;
      case 'arHeaderShowMode':
        _barkoder!.setARHeaderShowMode(value);
        break;
      case 'arOverlayRefresh':
        _barkoder!.setAROverlayRefresh(value);
        break;
      case 'arDoubleTapToFreeze':
        _barkoder!.setARDoubleTapToFreezeEnabled(value);
        break;
    }
  }

  void _resetConfig() {
    final enabledTypes = BarcodeConfigService.getEnabledTypesForMode(
      widget.mode,
    );
    setState(() {
      _enabledTypesMap = {for (var id in enabledTypes) id: true};
      _settings = {
        'compositeMode': false,
        'pinchToZoom': true,
        'locationInPreview': true,
        'regionOfInterest': false,
        'beepOnSuccess': true,
        'vibrateOnSuccess': false,
        'scanBlurred': widget.mode == ScannerModes.deblur,
        'scanDeformed': widget.mode == ScannerModes.vin,
        'continuousScanning': BarcodeConfigService.isContinuousMode(
          widget.mode,
          _settings,
        ),
        'continuousThreshold': 5,
        'decodingSpeed': DecodingSpeed.normal,
        'resolution': BarkoderResolution.HD,
        'showResultSheet': true,
        // AR Mode specific settings
        'arMode': BarkoderARMode.interactiveEnabled,
        'arLocationType': BarkoderARLocationType.boundingBox,
        'arHeaderShowMode': BarkoderARHeaderShowMode.onSelected,
        'arOverlayRefresh': BarkoderAROverlayRefresh.normal,
        'arDoubleTapToFreeze': true,
      };
      _enabledBarcodeTypes = BarcodeConfigService.getEnabledTypesDisplayNames(
        enabledTypes,
      );
    });

    _configureBarkoderView();
    _saveSettings();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'scanner_settings_${widget.mode}';

    final data = {
      'enabledTypes': _enabledTypesMap,
      'settings': _settings.map((k, v) {
        if (v is DecodingSpeed) {
          return MapEntry(k, 'DecodingSpeed.${v.toString().split('.').last}');
        } else if (v is BarkoderResolution) {
          return MapEntry(
            k,
            'BarkoderResolution.${v.toString().split('.').last}',
          );
        } else if (v is BarkoderARMode) {
          return MapEntry(k, 'BarkoderARMode.${v.toString().split('.').last}');
        } else if (v is BarkoderARLocationType) {
          return MapEntry(
            k,
            'BarkoderARLocationType.${v.toString().split('.').last}',
          );
        } else if (v is BarkoderARHeaderShowMode) {
          return MapEntry(
            k,
            'BarkoderARHeaderShowMode.${v.toString().split('.').last}',
          );
        } else if (v is BarkoderAROverlayRefresh) {
          return MapEntry(
            k,
            'BarkoderAROverlayRefresh.${v.toString().split('.').last}',
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
        final Map<String, dynamic>
        settings = (data['settings'] as Map<String, dynamic>).map((k, v) {
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
          } else if (v is String && v.startsWith('BarkoderARMode.')) {
            final enumValue = v.split('.').last;
            return MapEntry(
              k,
              BarkoderARMode.values.firstWhere(
                (e) => e.toString().split('.').last == enumValue,
                orElse: () => BarkoderARMode.interactiveEnabled,
              ),
            );
          } else if (v is String && v.startsWith('BarkoderARLocationType.')) {
            final enumValue = v.split('.').last;
            return MapEntry(
              k,
              BarkoderARLocationType.values.firstWhere(
                (e) => e.toString().split('.').last == enumValue,
                orElse: () => BarkoderARLocationType.boundingBox,
              ),
            );
          } else if (v is String && v.startsWith('BarkoderARHeaderShowMode.')) {
            final enumValue = v.split('.').last;
            return MapEntry(
              k,
              BarkoderARHeaderShowMode.values.firstWhere(
                (e) => e.toString().split('.').last == enumValue,
                orElse: () => BarkoderARHeaderShowMode.onSelected,
              ),
            );
          } else if (v is String && v.startsWith('BarkoderAROverlayRefresh.')) {
            final enumValue = v.split('.').last;
            return MapEntry(
              k,
              BarkoderAROverlayRefresh.values.firstWhere(
                (e) => e.toString().split('.').last == enumValue,
                orElse: () => BarkoderAROverlayRefresh.normal,
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
        final enabledTypes = BarcodeConfigService.getEnabledTypesForMode(
          widget.mode,
        );
        setState(() {
          _enabledTypesMap = {for (var id in enabledTypes) id: true};
          _settings = {
            'compositeMode': false,
            'pinchToZoom': true,
            'locationInPreview': true,
            'regionOfInterest': false,
            'beepOnSuccess': true,
            'vibrateOnSuccess': false,
            'scanBlurred': widget.mode == ScannerModes.deblur,
            'scanDeformed': widget.mode == ScannerModes.vin,
            'continuousScanning': BarcodeConfigService.isContinuousMode(
              widget.mode,
              _settings,
            ),
            'continuousThreshold': 5,
            'decodingSpeed': DecodingSpeed.normal,
            'resolution': BarkoderResolution.HD,
            'showResultSheet': true,
            'arMode': BarkoderARMode.interactiveEnabled,
            'arLocationType': BarkoderARLocationType.boundingBox,
            'arHeaderShowMode': BarkoderARHeaderShowMode.onSelected,
            'arOverlayRefresh': BarkoderAROverlayRefresh.normal,
            'arDoubleTapToFreeze': true,
          };
        });
      }
    }
  }

  void _continueScanning() {
    setState(() {
      _isScanningPaused = false;
      _fullCameraImageBytes = null;
      _isSheetVisible = false;
    });
    _barkoder?.startScanning((result) => _handleScanResult(result));
  }

  void _pauseScanningForSettings() {
    _barkoder?.stopScanning();
  }

  void _resumeScanningFromSettings() {
    if (!_isScanningPaused) {
      _barkoder?.startScanning((result) => _handleScanResult(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isContinuous = BarcodeConfigService.isContinuousMode(
      widget.mode,
      _settings,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          BarkoderView(
            licenseKey: dotenv.env['BARKODER_LICENSE_KEY'] ?? '',
            onBarkoderViewCreated: _onBarkoderViewCreated,
          ),
          if (_isScanningPaused && !isContinuous)
            ScannerOverlay(
              imageBytes: _fullCameraImageBytes,
              onTap: _continueScanning,
            ),
          if (_isScanningPaused &&
              !isContinuous &&
              _scannedItems.isNotEmpty &&
              !_isSheetVisible)
            ContinueScanningBanner(onTap: _continueScanning),
          ScannerTopBar(
            mode: widget.mode,
            enabledTypes: _enabledTypesMap,
            settings: _settings,
            onOpenSettings: _pauseScanningForSettings,
            onCloseSettings: _resumeScanningFromSettings,
            onToggleType: (typeId, enabled) {
              setState(() {
                _enabledTypesMap[typeId] = enabled;
                final enabledTypeIds = _enabledTypesMap.entries
                    .where((entry) => entry.value)
                    .map((entry) => entry.key)
                    .toList();
                _enabledBarcodeTypes =
                    BarcodeConfigService.getEnabledTypesDisplayNames(
                      enabledTypeIds,
                    );
              });
              _barkoder?.setBarcodeTypeEnabled(
                BarcodeConfigService.getBarcodeTypeFromId(typeId),
                enabled,
              );
              if (widget.mode == ScannerModes.vin && typeId == 'ocrText') {
                _barkoder?.setCustomOption(
                  'enable_ocr_functionality',
                  enabled ? 1 : 0,
                );
              }
              _saveSettings();
            },
            onUpdateSetting: (key, value) {
              setState(() => _settings[key] = value);
              _applySettingChange(key, value);
              _saveSettings();
            },
            onResetConfig: _resetConfig,
          ),
          if (_scannedItems.isNotEmpty &&
              _isSheetVisible &&
              widget.mode != ScannerModes.arMode)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Dismissible(
                key: ValueKey(_scannedItems.first.timestamp),
                direction: DismissDirection.down,
                onDismissed: (direction) {
                  setState(() {
                    _isSheetVisible = false;
                  });
                },
                child: ScanResultCard(
                  scannedItems: _scannedItems,
                  decoderResultsCount: _scannedItems.first.count,
                  onCopy: () => _copyToClipboard(_scannedItems.first.text),
                  onExportCSV: _exportToCSV,
                  onSearch: () => _searchBarcode(_scannedItems.first.text),
                  isDismissible: true,
                  showContinueBanner: _isScanningPaused && !isContinuous,
                  onContinueTap: _continueScanning,
                ),
              ),
            ),
          if (_scannedItems.isNotEmpty &&
              _isSheetVisible &&
              isContinuous &&
              widget.mode != ScannerModes.arMode)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 200,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isSheetVisible = false;
                  });
                },
                child: Container(color: Colors.transparent),
              ),
            ),
          if ((_scannedItems.isEmpty || !_isSheetVisible) &&
              widget.mode != ScannerModes.arMode)
            ScannerControls(
              enabledBarcodeTypes: _enabledBarcodeTypes,
              zoomLevel: _zoomLevel,
              isFlashOn: _isFlashOn,
              onToggleZoom: _toggleZoom,
              onToggleFlash: _toggleFlash,
              onToggleCamera: _toggleCamera,
            ),
        ],
      ),
    );
  }
}
