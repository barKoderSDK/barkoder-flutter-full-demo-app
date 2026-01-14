import 'package:flutter/material.dart';

class SettingSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool) onChanged;

  const SettingSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
          inactiveTrackColor: Colors.grey,
        ),
      ],
    );
  }
}
