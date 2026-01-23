import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../screens/settings_screen.dart';

class ScannerTopBar extends StatelessWidget {
  final String mode;
  final Map<String, bool> enabledTypes;
  final Map<String, dynamic> settings;
  final Function(String, bool) onToggleType;
  final Function(String, dynamic) onUpdateSetting;
  final VoidCallback onResetConfig;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onCloseSettings;

  const ScannerTopBar({
    super.key,
    required this.mode,
    required this.enabledTypes,
    required this.settings,
    required this.onToggleType,
    required this.onUpdateSetting,
    required this.onResetConfig,
    this.onOpenSettings,
    this.onCloseSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => context.pop(),
              ),
              SvgPicture.asset(
                'assets/images/logo_barkoder_white.svg',
                height: 20,
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                onPressed: () async {
                  onOpenSettings?.call();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(
                        mode: mode,
                        enabledTypes: enabledTypes,
                        settings: settings,
                        onToggleType: onToggleType,
                        onUpdateSetting: onUpdateSetting,
                        onResetConfig: onResetConfig,
                      ),
                    ),
                  );
                  onCloseSettings?.call();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
