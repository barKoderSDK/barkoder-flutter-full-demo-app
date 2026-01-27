import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../models/history_item.dart';
import '../../services/mrz_parser.dart';

class ScanResultCard extends StatelessWidget {
  final List<HistoryItem> scannedItems;
  final int decoderResultsCount;
  final VoidCallback onCopy;
  final VoidCallback onExportCSV;
  final VoidCallback onSearch;
  final bool isDismissible;
  final bool showContinueBanner;
  final VoidCallback? onContinueTap;
  static const int _collapsedMaxItems = 3;
  static const double _itemHeight = 50;
  static const double _itemSpacing = 6;

  const ScanResultCard({
    super.key,
    required this.scannedItems,
    required this.decoderResultsCount,
    required this.onCopy,
    required this.onExportCSV,
    required this.onSearch,
    this.isDismissible = false,
    this.showContinueBanner = false,
    this.onContinueTap,
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

  int _getItemCount(String text) {
    return scannedItems.where((item) => item.text == text).length;
  }

  List<HistoryItem> _getUniqueItems() {
    final uniqueTexts = <String>{};
    final uniqueItems = <HistoryItem>[];
    
    for (final item in scannedItems) {
      if (uniqueTexts.add(item.text)) {
        uniqueItems.add(item);
      }
    }
    
    return uniqueItems;
  }

  double _collapsedListHeight(int itemCount) {
    if (itemCount <= 0) return 0;
    final visibleCount =
        itemCount < _collapsedMaxItems ? itemCount : _collapsedMaxItems;
    return (_itemHeight * visibleCount) +
        (_itemSpacing * (visibleCount - 1));
  }

  Color _itemBackgroundColor(int index) {
    if (index == 0) {
      return const Color(0xFFDFF2D8);
    }
    return const Color(0xFFF2F3F5);
  }

  Widget _buildResultItem(BuildContext context, HistoryItem item, int index) {
    final count = _getItemCount(item.text);
    return GestureDetector(
      onTap: () => context.push('/barcode-details', extra: item),
      child: Container(
        height: _itemHeight,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: _itemBackgroundColor(index),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.type,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6C757D),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getDisplayText(item),
                    style: const TextStyle(
                      fontSize: 13,
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
                if (count > 1)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '($count)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6C757D),
                      ),
                    ),
                  ),
                SvgPicture.asset(
                  'assets/icons/info.svg',
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                    Colors.black54,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueBanner(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 60),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/touch_icon.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Tap anywhere to continue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExpandedView(BuildContext context) {
    final uniqueItems = _getUniqueItems();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.78,
        minChildSize: 0.55,
        maxChildSize: 0.85,
        builder: (context, scrollController) => Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$decoderResultsCount result${decoderResultsCount == 1 ? "" : "s"} found (${scannedItems.length} total)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: uniqueItems.length,
                      itemBuilder: (context, index) {
                        final item = uniqueItems[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildResultItem(context, item, index),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _ActionButton(
                                svgPath: 'assets/icons/icon_copy.svg',
                                label: 'Copy',
                                onPressed: () {
                                  Navigator.pop(context);
                                  onCopy();
                                },
                              ),
                              _ActionButton(
                                svgPath: 'assets/icons/icon_csv.svg',
                                label: 'CSV',
                                onPressed: () {
                                  Navigator.pop(context);
                                  onExportCSV();
                                },
                              ),
                              _ActionButton(
                                svgPath: 'assets/icons/icon_expand.svg',
                                label: 'Collapse',
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (showContinueBanner && onContinueTap != null)
              Positioned(
                top: -44,
                left: 0,
                right: 0,
                child: Center(
                  child: _buildContinueBanner(() {
                    Navigator.pop(context);
                    onContinueTap?.call();
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalSessionCount = scannedItems.length;
    final uniqueItems = _getUniqueItems();
    final listHeight = _collapsedListHeight(uniqueItems.length);
    
    final cardContent = Container(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
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
                '$decoderResultsCount result${decoderResultsCount == 1 ? "" : "s"} found ($totalSessionCount total)',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: listHeight,
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: uniqueItems.length,
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = uniqueItems[index];
                    return _buildResultItem(context, item, index);
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: _itemSpacing);
                  },
                ),
              ),
              const SizedBox(height: 12),
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
                    svgPath: 'assets/icons/icon_expand.svg',
                    label: 'Expand',
                    onPressed: () => _showExpandedView(context),
                  ),
                ],
              ),
          ],
        ),
      ),
    );

    final cardWithBanner = Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        cardContent,
        if (showContinueBanner && onContinueTap != null)
          Positioned(
            top: -44,
            left: 0,
            right: 0,
            child: Center(
              child: _buildContinueBanner(onContinueTap!),
            ),
          ),
      ],
    );

    if (isDismissible) {
      return cardWithBanner;
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: cardWithBanner,
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
      behavior: HitTestBehavior.opaque,
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
