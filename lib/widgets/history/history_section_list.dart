import 'package:flutter/material.dart';
import '../../models/history_item.dart';
import 'history_date_section.dart';
import 'history_item_card.dart';

class HistorySectionList extends StatelessWidget {
  final List<Map<String, dynamic>> sections;
  final Function(HistoryItem) onItemTap;

  const HistorySectionList({
    super.key,
    required this.sections,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        final items = section['data'] as List<HistoryItem>;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HistoryDateSection(dateLabel: section['title']),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  for (int i = 0; i < items.length; i++)
                    Column(
                      children: [
                        HistoryItemCard(
                          item: items[i],
                          onTap: () => onItemTap(items[i]),
                        ),
                        if (i < items.length - 1)
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey.shade200,
                            indent: 12,
                            endIndent: 12,
                          ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
