import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:barkoder_flutter/barkoder_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/barcode_types.dart';
import '../constants/modes.dart';
import '../services/settings_helper.dart';
import '../widgets/settings/settings_header.dart';
import '../widgets/settings/settings_section_header.dart';
import '../widgets/settings/settings_card.dart';
import '../widgets/settings/setting_switch.dart';
import '../widgets/settings/setting_dropdown.dart';

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
          Positioned.fill(
            child: SvgPicture.asset('assets/images/BG.svg', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                const SettingsHeader(),
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
                      _buildResetButton(),
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

  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          widget.onResetConfig();
          context.pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE52E4C),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    );
  }

  Widget _buildGeneralSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(title: 'General Settings'),
        SettingsCard(children: _getGeneralSettingsItems()),
      ],
    );
  }

  Widget _buildDecodingSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(title: 'Decoding Settings'),
        SettingsCard(children: _getDecodingSettingsItems()),
      ],
    );
  }

  Widget _buildBarcodeTypeSettings() {
    if (!SettingsHelper.shouldShowBarcodeTypes(widget.mode)) {
      return const SizedBox.shrink();
    }

    final modeTypes = SettingsHelper.getBarcodeTypesForMode(widget.mode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (modeTypes.isNotEmpty)
          _buildModeSpecificBarcodes(_getModeTypeTitle(widget.mode), modeTypes),
        if (SettingsHelper.shouldShow1DBarcodes(widget.mode))
          _build1DBarcodes(),
        if (SettingsHelper.shouldShow2DBarcodes(widget.mode))
          _build2DBarcodes(),
      ],
    );
  }

  String _getModeTypeTitle(String mode) {
    switch (mode) {
      case ScannerModes.dpm:
        return 'DPM Barcodes';
      case ScannerModes.vin:
        return 'VIN Barcodes';
      case ScannerModes.mrz:
        return 'MRZ Barcodes';
      case ScannerModes.deblur:
        return 'Deblur Barcodes';
      case ScannerModes.dotcode:
        return 'DotCode Barcodes';
      case ScannerModes.arMode:
        return 'AR Mode Barcodes';
      default:
        return 'Barcodes';
    }
  }

  Widget _build1DBarcodes() {
    final allEnabled = barcodeTypes1D.every(
      (type) => widget.enabledTypes[type['id']!] ?? false,
    );

    final items = <Widget>[
      SettingSwitch(
        label: 'Enable All',
        value: allEnabled,
        onChanged: (value) {
          for (final type in barcodeTypes1D) {
            widget.onToggleType(type['id']!, value);
          }
          setState(() {});
        },
      ),
      ...barcodeTypes1D.map((type) {
        final typeId = type['id']!;
        final isEnabled = widget.enabledTypes[typeId] ?? false;
        return SettingSwitch(
          label: type['label']!,
          value: isEnabled,
          onChanged: (value) {
            widget.onToggleType(typeId, value);
            setState(() {});
          },
        );
      }),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(title: '1D Barcodes'),
        SettingsCard(children: items),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _build2DBarcodes() {
    final allEnabled = barcodeTypes2D.every(
      (type) => widget.enabledTypes[type['id']!] ?? false,
    );

    final items = <Widget>[
      SettingSwitch(
        label: 'Enable All',
        value: allEnabled,
        onChanged: (value) {
          for (final type in barcodeTypes2D) {
            widget.onToggleType(type['id']!, value);
          }
          setState(() {});
        },
      ),
      ...barcodeTypes2D.map((type) {
        final typeId = type['id']!;
        final isEnabled = widget.enabledTypes[typeId] ?? false;
        return SettingSwitch(
          label: type['label']!,
          value: isEnabled,
          onChanged: (value) {
            widget.onToggleType(typeId, value);
            setState(() {});
          },
        );
      }),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(title: '2D Barcodes'),
        SettingsCard(children: items),
      ],
    );
  }

  Widget _buildModeSpecificBarcodes(
    String title,
    List<Map<String, String>> barcodeTypesList,
  ) {
    final allEnabled = barcodeTypesList.every(
      (type) => widget.enabledTypes[type['id']!] ?? false,
    );

    final items = <Widget>[];

    if (barcodeTypesList.length > 1) {
      items.add(
        SettingSwitch(
          label: 'Enable All',
          value: allEnabled,
          onChanged: (value) {
            for (final type in barcodeTypesList) {
              widget.onToggleType(type['id']!, value);
            }
            setState(() {});
          },
        ),
      );
    }

    items.addAll(
      barcodeTypesList.map((type) {
        final typeId = type['id']!;
        final isEnabled = widget.enabledTypes[typeId] ?? false;
        return SettingSwitch(
          label: type['label']!,
          value: isEnabled,
          onChanged: (value) {
            widget.onToggleType(typeId, value);
            setState(() {});
          },
        );
      }),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(title: title),
        SettingsCard(children: items),
        const SizedBox(height: 24),
      ],
    );
  }

  List<Widget> _getGeneralSettingsItems() {
    final items = <Widget>[];
    final mode = widget.mode;

    if (mode == ScannerModes.anyscan) {
      items.add(_buildCompositeModeSetting());
    }

    items.add(_buildPinchToZoomSetting());

    if (!_isSpecialModeExcluding(['locationInPreview'])) {
      items.add(_buildLocationInPreviewSetting());
    }

    if (!_isSpecialModeExcluding(['regionOfInterest'])) {
      items.add(_buildRegionOfInterestSetting());
    }

    items.addAll([
      _buildBeepOnSuccessSetting(),
      _buildVibrateOnSuccessSetting(),
      _buildShowResultSheetSetting(),
    ]);

    if (!_isSpecialModeExcluding(['scanBlurred'])) {
      items.add(_buildScanBlurredSetting());
    }

    if (!_isSpecialModeExcluding(['scanDeformed'])) {
      items.add(_buildScanDeformedSetting());
    }

    if (mode != ScannerModes.arMode) {
      items.add(_buildContinuousScanSetting());

      if (widget.settings['continuousScanning'] == true) {
        items.add(_buildDuplicateDelaySetting());
      }
    }

    if (mode == ScannerModes.arMode) {
      items.addAll([
        _buildARModeSetting(),
        _buildARLocationTypeSetting(),
        _buildARHeaderShowModeSetting(),
        _buildAROverlayRefreshSetting(),
        _buildARDoubleTapToFreezeSetting(),
      ]);
    }

    return items;
  }

  bool _isSpecialModeExcluding(List<String> excluded) {
    final mode = widget.mode;
    final specialModes = {
      ScannerModes.dpm: [
        'locationInPreview',
        'regionOfInterest',
        'scanBlurred',
        'scanDeformed',
      ],
      ScannerModes.arMode: [
        'locationInPreview',
        'regionOfInterest',
        'scanBlurred',
        'scanDeformed',
      ],
      ScannerModes.vin: ['locationInPreview', 'scanBlurred'],
      ScannerModes.mrz: [
        'locationInPreview',
        'regionOfInterest',
        'scanBlurred',
        'scanDeformed',
      ],
      ScannerModes.dotcode: ['scanBlurred', 'scanDeformed'],
    };

    for (final entry in specialModes.entries) {
      if (mode == entry.key) {
        return entry.value.any((setting) => excluded.contains(setting));
      }
    }
    return false;
  }

  Widget _buildCompositeModeSetting() {
    return SettingSwitch(
      label: 'Composite Mode',
      value: widget.settings['compositeMode'] ?? false,
      onChanged: (value) {
        widget.onUpdateSetting('compositeMode', value);
        setState(() {});
      },
    );
  }

  Widget _buildPinchToZoomSetting() {
    return SettingSwitch(
      label: 'Allow Pinch to Zoom',
      value: widget.settings['pinchToZoom'] ?? true,
      onChanged: (value) {
        widget.onUpdateSetting('pinchToZoom', value);
        setState(() {});
      },
    );
  }

  Widget _buildLocationInPreviewSetting() {
    return SettingSwitch(
      label: 'Location in Preview',
      value: widget.settings['locationInPreview'] ?? true,
      onChanged: (value) {
        widget.onUpdateSetting('locationInPreview', value);
        setState(() {});
      },
    );
  }

  Widget _buildRegionOfInterestSetting() {
    final label = widget.mode == ScannerModes.vin
        ? 'Narrow Viewfinder'
        : 'Region of Interest';
    return SettingSwitch(
      label: label,
      value: widget.settings['regionOfInterest'] ?? false,
      onChanged: (value) {
        widget.onUpdateSetting('regionOfInterest', value);
        setState(() {});
      },
    );
  }

  Widget _buildBeepOnSuccessSetting() {
    return SettingSwitch(
      label: 'Beep on Success',
      value: widget.settings['beepOnSuccess'] ?? true,
      onChanged: (value) {
        widget.onUpdateSetting('beepOnSuccess', value);
        setState(() {});
      },
    );
  }

  Widget _buildVibrateOnSuccessSetting() {
    return SettingSwitch(
      label: 'Vibrate on Success',
      value: widget.settings['vibrateOnSuccess'] ?? true,
      onChanged: (value) {
        widget.onUpdateSetting('vibrateOnSuccess', value);
        setState(() {});
      },
    );
  }

  Widget _buildShowResultSheetSetting() {
    return SettingSwitch(
      label: 'Show Result Sheet',
      value: widget.settings['showResultSheet'] ?? true,
      onChanged: (value) {
        widget.onUpdateSetting('showResultSheet', value);
        setState(() {});
      },
    );
  }

  Widget _buildScanBlurredSetting() {
    return SettingSwitch(
      label: 'Scan Blurred UPC/EAN',
      value: widget.settings['scanBlurred'] ?? false,
      onChanged: (value) {
        widget.onUpdateSetting('scanBlurred', value);
        setState(() {});
      },
    );
  }

  Widget _buildScanDeformedSetting() {
    return SettingSwitch(
      label: 'Scan Deformed Codes',
      value: widget.settings['scanDeformed'] ?? false,
      onChanged: (value) {
        widget.onUpdateSetting('scanDeformed', value);
        setState(() {});
      },
    );
  }

  Widget _buildContinuousScanSetting() {
    return SettingSwitch(
      label: 'Continuous Scanning',
      value: widget.settings['continuousScanning'] ?? false,
      onChanged: (value) {
        widget.onUpdateSetting('continuousScanning', value);
        setState(() {});
      },
    );
  }

  Widget _buildDuplicateDelaySetting() {
    return SettingDropdown(
      label: 'Duplicate Delay',
      value: widget.settings['continuousThreshold'] ?? 5,
      options: [
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
      onChanged: (value) {
        widget.onUpdateSetting('continuousThreshold', value);
        setState(() {});
      },
    );
  }

  List<Widget> _getDecodingSettingsItems() {
    final items = <Widget>[];
    final mode = widget.mode;

    if (mode != ScannerModes.dpm &&
        mode != ScannerModes.arMode &&
        mode != ScannerModes.vin &&
        mode != ScannerModes.mrz &&
        mode != ScannerModes.dotcode) {
      items.add(
        SettingDropdown(
          label: 'Decoding Speed',
          value: widget.settings['decodingSpeed'] ?? DecodingSpeed.normal,
          options: [
            {'label': 'Fast', 'value': DecodingSpeed.fast},
            {'label': 'Normal', 'value': DecodingSpeed.normal},
            {'label': 'Slow', 'value': DecodingSpeed.slow},
          ],
          onChanged: (value) {
            widget.onUpdateSetting('decodingSpeed', value);
            setState(() {});
          },
        ),
      );
    }

    items.add(
      SettingDropdown(
        label: 'Resolution',
        value: widget.settings['resolution'] ?? BarkoderResolution.HD,
        options: [
          {'label': 'FHD', 'value': BarkoderResolution.FHD},
          {'label': 'HD', 'value': BarkoderResolution.HD},
          {'label': 'UHD', 'value': BarkoderResolution.UHD},
        ],
        onChanged: (value) {
          widget.onUpdateSetting('resolution', value);
          setState(() {});
        },
      ),
    );

    return items;
  }

  Widget _buildARModeSetting() {
    return SettingDropdown(
      label: 'AR Mode',
      value: widget.settings['arMode'] ?? BarkoderARMode.interactiveEnabled,
      options: [
        {'label': 'Off', 'value': BarkoderARMode.off},
        {
          'label': 'Interactive Disabled',
          'value': BarkoderARMode.interactiveDisabled,
        },
        {
          'label': 'Interactive Enabled',
          'value': BarkoderARMode.interactiveEnabled,
        },
        {'label': 'Non-Interactive', 'value': BarkoderARMode.nonInteractive},
      ],
      onChanged: (value) {
        widget.onUpdateSetting('arMode', value);
        setState(() {});
      },
    );
  }

  Widget _buildARLocationTypeSetting() {
    return SettingDropdown(
      label: 'Location Type',
      value:
          widget.settings['arLocationType'] ??
          BarkoderARLocationType.boundingBox,
      options: [
        {'label': 'None', 'value': BarkoderARLocationType.none},
        {'label': 'Tight', 'value': BarkoderARLocationType.tight},
        {'label': 'Bounding Box', 'value': BarkoderARLocationType.boundingBox},
      ],
      onChanged: (value) {
        widget.onUpdateSetting('arLocationType', value);
        setState(() {});
      },
    );
  }

  Widget _buildARHeaderShowModeSetting() {
    return SettingDropdown(
      label: 'Header Show Mode',
      value:
          widget.settings['arHeaderShowMode'] ??
          BarkoderARHeaderShowMode.onSelected,
      options: [
        {'label': 'Never', 'value': BarkoderARHeaderShowMode.never},
        {'label': 'Always', 'value': BarkoderARHeaderShowMode.always},
        {'label': 'On Selected', 'value': BarkoderARHeaderShowMode.onSelected},
      ],
      onChanged: (value) {
        widget.onUpdateSetting('arHeaderShowMode', value);
        setState(() {});
      },
    );
  }

  Widget _buildAROverlayRefreshSetting() {
    return SettingDropdown(
      label: 'Overlay Refresh',
      value:
          widget.settings['arOverlayRefresh'] ??
          BarkoderAROverlayRefresh.normal,
      options: [
        {'label': 'Smooth', 'value': BarkoderAROverlayRefresh.smooth},
        {'label': 'Normal', 'value': BarkoderAROverlayRefresh.normal},
      ],
      onChanged: (value) {
        widget.onUpdateSetting('arOverlayRefresh', value);
        setState(() {});
      },
    );
  }

  Widget _buildARDoubleTapToFreezeSetting() {
    return SettingSwitch(
      label: 'Double Tap to Freeze',
      value: widget.settings['arDoubleTapToFreeze'] ?? true,
      onChanged: (value) {
        widget.onUpdateSetting('arDoubleTapToFreeze', value);
        setState(() {});
      },
    );
  }
}
