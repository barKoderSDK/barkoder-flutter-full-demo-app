import 'package:flutter/material.dart';

class SettingDropdown extends StatelessWidget {
  final String label;
  final dynamic value;
  final List<Map<String, dynamic>> options;
  final Function(dynamic) onChanged;

  const SettingDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  String _getLabel() {
    final option = options.firstWhere(
      (opt) => opt['value'] == value,
      orElse: () => options.first,
    );
    return option['label'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
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
                  _getLabel(),
                  style: const TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 20, color: Colors.black54),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
