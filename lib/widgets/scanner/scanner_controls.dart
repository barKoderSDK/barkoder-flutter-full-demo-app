import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ScannerControls extends StatelessWidget {
  final List<String> enabledBarcodeTypes;
  final double zoomLevel;
  final bool isFlashOn;
  final VoidCallback onToggleZoom;
  final VoidCallback onToggleFlash;
  final VoidCallback onToggleCamera;

  const ScannerControls({
    super.key,
    required this.enabledBarcodeTypes,
    required this.zoomLevel,
    required this.isFlashOn,
    required this.onToggleZoom,
    required this.onToggleFlash,
    required this.onToggleCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (enabledBarcodeTypes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, bottom: 30),
                  child: Text(
                    enabledBarcodeTypes.join(', '),
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ControlButton(
                    svgPath: zoomLevel == 1.0
                        ? 'assets/icons/zoom_in.svg'
                        : 'assets/icons/zoom_out.svg',
                    onPressed: onToggleZoom,
                  ),
                  const SizedBox(width: 20),
                  _ControlButton(
                    svgPath: isFlashOn
                        ? 'assets/icons/flash_off.svg'
                        : 'assets/icons/flash_on.svg',
                    onPressed: onToggleFlash,
                  ),
                  const SizedBox(width: 20),
                  _ControlButton(
                    svgPath: 'assets/icons/camera_switch.svg',
                    onPressed: onToggleCamera,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final String svgPath;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.svgPath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE52E4C), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: SvgPicture.asset(
          svgPath,
          width: 28,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
