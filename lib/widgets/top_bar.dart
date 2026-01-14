import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TopBar extends StatelessWidget {
  final String logoPosition;
  final bool transparent;
  final VoidCallback? onMenuPress;
  final VoidCallback? onClose;

  const TopBar({
    super.key,
    this.logoPosition = 'center',
    this.transparent = false,
    this.onMenuPress,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: transparent ? Colors.transparent : Colors.transparent,
      child: Row(
        mainAxisAlignment: logoPosition == 'left' ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          if (onClose != null)
            IconButton(
              icon: Icon(
                Icons.close,
                color: transparent ? Colors.white : Colors.black,
              ),
              onPressed: onClose,
            ),
          
          if (logoPosition == 'center' || logoPosition == 'left')
            SvgPicture.asset(
              'assets/images/logo_barkoder.svg',
              height: 22,
            ),
        ],
      ),
    );
  }
}
