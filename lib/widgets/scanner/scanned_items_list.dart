import 'package:flutter/material.dart';
import '../../models/history_item.dart';

class ScannedItemsList extends StatelessWidget {
  final List<HistoryItem> items;

  const ScannedItemsList({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.length <= 1) return const SizedBox.shrink();

    return Positioned(
      left: 0,
      bottom: items.isNotEmpty ? 200 : 80,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          width: 120,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            reverse: true,
            itemCount: items.length - 1,
            itemBuilder: (context, index) {
              final item = items[index + 1];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.text.length > 10
                      ? '${item.text.substring(0, 10)}...'
                      : item.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
