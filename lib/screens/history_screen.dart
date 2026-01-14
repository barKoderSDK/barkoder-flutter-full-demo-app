import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../services/history_service.dart';
import '../models/history_item.dart';
import '../widgets/history/history_header.dart';
import '../widgets/history/history_loading_state.dart';
import '../widgets/history/history_empty_state.dart';
import '../widgets/history/history_section_list.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _sections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await HistoryService.getHistory();
      final Map<String, List<HistoryItem>> grouped = {};

      for (final item in history) {
        final date = DateFormat(
          'dd/MM/yyyy',
        ).format(DateTime.fromMillisecondsSinceEpoch(item.timestamp));
        grouped.putIfAbsent(date, () => []).add(item);
      }

      final sections = grouped.entries.map((entry) {
        return {'title': entry.key, 'data': entry.value};
      }).toList();

      setState(() {
        _sections = sections;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _handleItemTap(HistoryItem item) {
    context.push('/barcode-details', extra: item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset('assets/images/BG.svg', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                HistoryHeader(onBack: () => context.pop()),
                Expanded(
                  child: _isLoading
                      ? const HistoryLoadingState()
                      : _sections.isEmpty
                      ? const HistoryEmptyState()
                      : HistorySectionList(
                          sections: _sections,
                          onItemTap: _handleItemTap,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
