import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../models/history_item.dart';
import '../../services/mrz_parser.dart';

class ScanResultCard extends StatelessWidget {
  final HistoryItem item;
  final int totalCount;
  final int totalSessionCount;
  final VoidCallback onCopy;
  final VoidCallback onExportCSV;
  final VoidCallback onSearch;

  const ScanResultCard({
    super.key,
    required this.item,
    required this.totalCount,
    required this.totalSessionCount,
    required this.onCopy,
    required this.onExportCSV,
    required this.onSearch,
  });

  String _getDisplayText(HistoryItem item) {
    if (MRZParser.isMRZ(item.type)) {
      final fields = MRZParser.parse(item.text);
      String? firstName;
      String? lastName;
      
      for (final field in fields) {
        if (field['id'] == 'first_name') {
          firstName = field['value'];
        } else if (field['id'] == 'last_name') {
          lastName = field['value'];
        }
      }
      
      if (firstName != null && lastName != null) {
        return '$firstName $lastName';
      } else if (firstName != null) {
        return firstName;
      } else if (lastName != null) {
        return lastName;
      }
    }
    return item.text;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: EdgeInsets.zero,
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
              Text(
                '$totalCount result${totalCount == 1 ? "" : "s"} found ($totalSessionCount total)',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => context.push('/barcode-details', extra: item),
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
                              item.type,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6C757D),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getDisplayText(item),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '×$totalCount',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6C757D),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ActionButton(
                    svgPath: 'assets/icons/icon_copy.svg',
                    label: 'Copy',
                    onPressed: onCopy,
                  ),
                  _ActionButton(
                    svgPath: 'assets/icons/icon_csv.svg',
                    label: 'CSV',
                    onPressed: onExportCSV,
                  ),
                  _ActionButton(
                    svgPath: 'assets/icons/icon_search.svg',
                    label: 'Search',
                    onPressed: onSearch,
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

class _ActionButton extends StatelessWidget {
  final String svgPath;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.svgPath,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
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
}
