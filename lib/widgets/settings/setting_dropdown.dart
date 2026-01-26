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
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              title: Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              contentPadding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: options.map((option) {
                  final isSelected = value == option['value'];
                  return InkWell(
                    onTap: () {
                      onChanged(option['value']);
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      child: Row(
                        children: [
                          Radio<dynamic>(
                            value: option['value'],
                            // ignore: deprecated_member_use
                            groupValue: value,
                            activeColor: const Color(0xFFE52E4C),
                            // ignore: deprecated_member_use
                            onChanged: (val) {
                              onChanged(val);
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(width: 8),
                          Text(
                            option['label'],
                            style: TextStyle(
                              fontSize: 16,
                              color: isSelected
                                  ? Colors.black87
                                  : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(
                      color: Color(0xFFE52E4C),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
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
