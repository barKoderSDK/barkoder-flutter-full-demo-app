import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:barkoder_flutter/barkoder_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/barcode_types.dart';
import '../constants/modes.dart';

class SettingsScreen extends StatefulWidget {
  final String mode;
  final Map<String, bool> enabledTypes;
  final Map<String, dynamic> settings;
  final Function(String typeId, bool enabled) onToggleType;
  final Function(String key, dynamic value) onUpdateSetting;
  final Function() onResetConfig;

  const SettingsScreen({
    super.key,
    required this.mode,
    required this.enabledTypes,
    required this.settings,
    required this.onToggleType,
    required this.onUpdateSetting,
    required this.onResetConfig,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background SVG
          Positioned.fill(
            child: SvgPicture.asset('assets/images/BG.svg', fit: BoxFit.cover),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: SvgPicture.asset(
                          'assets/icons/chevron.svg',
                          height: 18,
                        ),
                        onPressed: () => context.pop(),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildGeneralSettings(),
                      const SizedBox(height: 24),
                      _buildDecodingSettings(),
                      const SizedBox(height: 24),
                      _buildBarcodeTypeSettings(),
                      const SizedBox(height: 32),
                      // Reset button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            widget.onResetConfig();
                            context.pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE52E4C),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Reset to Default',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'General Settings',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE52E4C),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(children: _getGeneralSettingsItems()),
        ),
      ],
    );
  }

  Widget _buildDecodingSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Decoding Settings',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE52E4C),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(children: _getDecodingSettingsItems()),
        ),
      ],
    );
  }

  Widget _buildBarcodeTypeSettings() {
    final is1D = widget.mode == ScannerModes.mode1D;
    final is2D = widget.mode == ScannerModes.mode2D;
    final isDpm = widget.mode == ScannerModes.dpm;
    final isVin = widget.mode == ScannerModes.vin;
    final isMrz = widget.mode == ScannerModes.mrz;
    final isDeblur = widget.mode == ScannerModes.deblur;
    final isDotCode = widget.mode == ScannerModes.dotcode;
    final isArMode = widget.mode == ScannerModes.arMode;

    // Show barcode type settings for specific modes
    final showBarcodeTypes =
        is1D ||
        is2D ||
        widget.mode == ScannerModes.continuous ||
        widget.mode == ScannerModes.multiscan ||
        widget.mode == 'anyscan' ||
        isDpm ||
        isVin ||
        isMrz ||
        isDeblur ||
        isDotCode ||
        isArMode;

    if (!showBarcodeTypes) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // For modes with specific barcode types, show custom list
        if (isDpm)
          _buildModeSpecificBarcodes('DPM Barcodes', [
            {'id': 'qr', 'label': 'QR'},
            {'id': 'qrMicro', 'label': 'QR Micro'},
            {'id': 'datamatrix', 'label': 'Data Matrix'},
          ]),
        if (isVin)
          _buildModeSpecificBarcodes('VIN Barcodes', [
            {'id': 'code39', 'label': 'Code 39'},
            {'id': 'code128', 'label': 'Code 128'},
            {'id': 'qr', 'label': 'QR'},
            {'id': 'datamatrix', 'label': 'Data Matrix'},
          ]),
        if (isMrz)
          _buildModeSpecificBarcodes('MRZ Barcodes', [
            {'id': 'idDocument', 'label': 'ID Document'},
          ]),
        if (isDeblur)
          _buildModeSpecificBarcodes('Deblur Barcodes', [
            {'id': 'upcA', 'label': 'UPC-A'},
            {'id': 'upcE', 'label': 'UPC-E'},
            {'id': 'ean13', 'label': 'EAN-13'},
            {'id': 'ean8', 'label': 'EAN-8'},
          ]),
        if (isDotCode)
          _buildModeSpecificBarcodes('DotCode Barcodes', [
            {'id': 'dotcode', 'label': 'DotCode'},
          ]),
        if (isArMode)
          _buildModeSpecificBarcodes('AR Mode Barcodes', [
            {'id': 'qr', 'label': 'QR'},
            {'id': 'code128', 'label': 'Code 128'},
            {'id': 'code39', 'label': 'Code 39'},
            {'id': 'upcA', 'label': 'UPC-A'},
            {'id': 'upcE', 'label': 'UPC-E'},
            {'id': 'ean13', 'label': 'EAN-13'},
            {'id': 'ean8', 'label': 'EAN-8'},
          ]),
        // For 1D/2D/continuous/multiscan/anyscan, show full lists
        if (is1D ||
            widget.mode == ScannerModes.continuous ||
            widget.mode == ScannerModes.multiscan ||
            widget.mode == 'anyscan')
          _build1DBarcodes(),
        if (is2D ||
            widget.mode == ScannerModes.continuous ||
            widget.mode == ScannerModes.multiscan ||
            widget.mode == 'anyscan')
          _build2DBarcodes(),
      ],
    );
  }

  Widget _build1DBarcodes() {
    // Check if all 1D barcodes are enabled
    final allEnabled = barcodeTypes1D.every(
      (type) => widget.enabledTypes[type['id']!] ?? false,
    );

    final items = <Widget>[
      _buildSettingSwitch('Enable All', allEnabled, (value) {
        for (final type in barcodeTypes1D) {
          widget.onToggleType(type['id']!, value);
        }
        setState(() {});
      }),
    ];
    items.addAll(
      barcodeTypes1D.map((type) {
        final typeId = type['id']!;
        final isEnabled = widget.enabledTypes[typeId] ?? false;
        return _buildSettingSwitch(type['label']!, isEnabled, (value) {
          widget.onToggleType(typeId, value);
          setState(() {});
        });
      }).toList(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            '1D Barcodes',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE52E4C),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(children: items),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _build2DBarcodes() {
    // Check if all 2D barcodes are enabled
    final allEnabled = barcodeTypes2D.every(
      (type) => widget.enabledTypes[type['id']!] ?? false,
    );

    final items = <Widget>[
      _buildSettingSwitch('Enable All', allEnabled, (value) {
        for (final type in barcodeTypes2D) {
          widget.onToggleType(type['id']!, value);
        }
        setState(() {});
      }),
    ];
    items.addAll(
      barcodeTypes2D.map((type) {
        final typeId = type['id']!;
        final isEnabled = widget.enabledTypes[typeId] ?? false;
        return _buildSettingSwitch(type['label']!, isEnabled, (value) {
          widget.onToggleType(typeId, value);
          setState(() {});
        });
      }).toList(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            '2D Barcodes',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE52E4C),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildModeSpecificBarcodes(
    String title,
    List<Map<String, String>> barcodeTypesList,
  ) {
    // Check if all barcodes are enabled
    final allEnabled = barcodeTypesList.every(
      (type) => widget.enabledTypes[type['id']!] ?? false,
    );

    final items = <Widget>[];

    // Only show "Enable All" if there are multiple barcode types
    if (barcodeTypesList.length > 1) {
      items.add(
        _buildSettingSwitch('Enable All', allEnabled, (value) {
          for (final type in barcodeTypesList) {
            widget.onToggleType(type['id']!, value);
          }
          setState(() {});
        }),
      );
    }

    items.addAll(
      barcodeTypesList.map((type) {
        final typeId = type['id']!;
        final isEnabled = widget.enabledTypes[typeId] ?? false;
        return _buildSettingSwitch(type['label']!, isEnabled, (value) {
          widget.onToggleType(typeId, value);
          setState(() {});
        });
      }).toList(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE52E4C),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(children: items),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  List<Widget> _getGeneralSettingsItems() {
    final items = <Widget>[];
    final mode = widget.mode;
    final isDpmMode = mode == ScannerModes.dpm;
    final isARMode = mode == ScannerModes.arMode;
    final isMultiScanMode = mode == ScannerModes.multiscan;
    final isVinMode = mode == ScannerModes.vin;
    final isMrzMode = mode == ScannerModes.mrz;
    final isDotCodeMode = mode == ScannerModes.dotcode;

    if (!isDpmMode &&
        !isARMode &&
        !isMultiScanMode &&
        !isVinMode &&
        !isMrzMode &&
        !isDotCodeMode) {
      items.add(
        _buildSettingSwitch(
          'Composite Mode',
          widget.settings['compositeMode'] ?? false,
          (value) {
            widget.onUpdateSetting('compositeMode', value);
            setState(() {});
          },
        ),
      );
    }

    items.add(
      _buildSettingSwitch(
        'Allow Pinch to Zoom',
        widget.settings['pinchToZoom'] ?? true,
        (value) {
          widget.onUpdateSetting('pinchToZoom', value);
          setState(() {});
        },
      ),
    );

    if (!isDpmMode && !isARMode && !isVinMode && !isMrzMode) {
      items.add(
        _buildSettingSwitch(
          'Location in Preview',
          widget.settings['locationInPreview'] ?? true,
          (value) {
            widget.onUpdateSetting('locationInPreview', value);
            setState(() {});
          },
        ),
      );
    }

    if (!isDpmMode && !isARMode && !isMrzMode) {
      items.add(
        _buildSettingSwitch(
          isVinMode ? 'Narrow Viewfinder' : 'Region of Interest',
          widget.settings['regionOfInterest'] ?? false,
          (value) {
            widget.onUpdateSetting('regionOfInterest', value);
            setState(() {});
          },
        ),
      );
    }

    items.add(
      _buildSettingSwitch(
        'Beep on Success',
        widget.settings['beepOnSuccess'] ?? true,
        (value) {
          widget.onUpdateSetting('beepOnSuccess', value);
          setState(() {});
        },
      ),
    );

    items.add(
      _buildSettingSwitch(
        'Vibrate on Success',
        widget.settings['vibrateOnSuccess'] ?? true,
        (value) {
          widget.onUpdateSetting('vibrateOnSuccess', value);
          setState(() {});
        },
      ),
    );

    if (!isDpmMode && !isARMode && !isVinMode && !isMrzMode && !isDotCodeMode) {
      items.add(
        _buildSettingSwitch(
          'Scan Blurred UPC/EAN',
          widget.settings['scanBlurred'] ?? false,
          (value) {
            widget.onUpdateSetting('scanBlurred', value);
            setState(() {});
          },
        ),
      );
    }

    if (!isDpmMode && !isARMode && !isMrzMode && !isDotCodeMode) {
      items.add(
        _buildSettingSwitch(
          'Scan Deformed Codes',
          widget.settings['scanDeformed'] ?? false,
          (value) {
            widget.onUpdateSetting('scanDeformed', value);
            setState(() {});
          },
        ),
      );
    }

    if (!isARMode) {
      items.add(
        _buildSettingSwitch(
          'Continuous Scanning',
          widget.settings['continuousScanning'] ?? false,
          (value) {
            widget.onUpdateSetting('continuousScanning', value);
            setState(() {});
          },
        ),
      );

      // Show threshold dropdown only when continuous scanning is enabled
      if (widget.settings['continuousScanning'] == true) {
        items.add(
          _buildSettingDropdown(
            'Duplicate Delay',
            widget.settings['continuousThreshold'] ?? 5,
            [
              {'label': '0', 'value': 0},
              {'label': '1', 'value': 1},
              {'label': '2', 'value': 2},
              {'label': '3', 'value': 3},
              {'label': '4', 'value': 4},
              {'label': '5', 'value': 5},
              {'label': '6', 'value': 6},
              {'label': '7', 'value': 7},
              {'label': '8', 'value': 8},
              {'label': '9', 'value': 9},
              {'label': '10', 'value': 10},
              {'label': 'Unlimited', 'value': -1},
            ],
            (value) {
              widget.onUpdateSetting('continuousThreshold', value);
              setState(() {});
            },
          ),
        );
      }
    }

    return items;
  }

  List<Widget> _getDecodingSettingsItems() {
    final items = <Widget>[];
    final mode = widget.mode;
    final isDpmMode = mode == ScannerModes.dpm;
    final isARMode = mode == ScannerModes.arMode;
    final isVinMode = mode == ScannerModes.vin;
    final isMrzMode = mode == ScannerModes.mrz;
    final isDotCodeMode = mode == ScannerModes.dotcode;

    if (!isDpmMode && !isARMode && !isVinMode && !isMrzMode && !isDotCodeMode) {
      items.add(
        _buildSettingDropdown(
          'Decoding Speed',
          widget.settings['decodingSpeed'] ?? DecodingSpeed.normal,
          [
            {'label': 'Fast', 'value': DecodingSpeed.fast},
            {'label': 'Normal', 'value': DecodingSpeed.normal},
            {'label': 'Slow', 'value': DecodingSpeed.slow},
          ],
          (value) {
            widget.onUpdateSetting('decodingSpeed', value);
            setState(() {});
          },
        ),
      );
    }

    items.add(
      _buildSettingDropdown(
        'Resolution',
        widget.settings['resolution'] ?? BarkoderResolution.HD,
        [
          {'label': 'FHD', 'value': BarkoderResolution.FHD},
          {'label': 'HD', 'value': BarkoderResolution.HD},
          {'label': 'UHD', 'value': BarkoderResolution.UHD},
        ],
        (value) {
          widget.onUpdateSetting('resolution', value);
          setState(() {});
        },
      ),
    );

    return items;
  }

  Widget _buildSettingSwitch(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: const Color(0xFFE52E4C),
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey.shade300,
        ),
      ],
    );
  }

  Widget _buildSettingDropdown(
    String label,
    dynamic value,
    List<Map<String, dynamic>> options,
    Function(dynamic) onChanged,
  ) {
    String getLabel() {
      final option = options.firstWhere(
        (opt) => opt['value'] == value,
        orElse: () => options.first,
      );
      return option['label'] ?? '';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...options.map((option) {
                    return ListTile(
                      title: Text(option['label']),
                      trailing: value == option['value']
                          ? const Icon(Icons.check, color: Color(0xFFE52E4C))
                          : null,
                      onTap: () {
                        onChanged(option['value']);
                        Navigator.pop(context);
                      },
                    );
                  }),
                ],
              ),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            Row(
              children: [
                Text(
                  getLabel(),
                  style: const TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Colors.black54,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
