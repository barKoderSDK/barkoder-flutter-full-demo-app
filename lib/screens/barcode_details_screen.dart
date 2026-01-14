import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/history_item.dart';
import '../services/mrz_parser.dart';
import '../widgets/details/details_header.dart';
import '../widgets/details/details_image_card.dart';
import '../widgets/details/details_section_label.dart';
import '../widgets/details/details_data_field.dart';
import '../widgets/details/details_action_button.dart';

class BarcodeDetailsScreen extends StatelessWidget {
  final HistoryItem item;

  const BarcodeDetailsScreen({super.key, required this.item});

  void _handleCopy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: item.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Barcode copied to clipboard')),
    );
  }

  void _handleSearch() {
    final url =
        'https://www.google.com/search?q=${Uri.encodeComponent(item.text)}';
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
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
                DetailsHeader(onBack: () => context.pop()),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DetailsImageCard(imagePath: item.image),
                        const SizedBox(height: 32),
                        const DetailsSectionLabel(),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _buildDataFields(),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildActionBar(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            DetailsActionButton(
              iconPath: 'assets/icons/icon_copy.svg',
              label: 'Copy',
              onTap: () => _handleCopy(context),
            ),
            DetailsActionButton(
              iconPath: 'assets/icons/icon_search.svg',
              label: 'Search',
              onTap: _handleSearch,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataFields() {
    if (MRZParser.isMRZ(item.type)) {
      final mrzFields = MRZParser.parse(item.text);
      final children = <Widget>[];

      children.add(DetailsDataField(label: 'Barcode Type', value: item.type));

      for (var i = 0; i < mrzFields.length; i++) {
        final field = mrzFields[i];
        children.add(
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.shade200,
            indent: 16,
            endIndent: 16,
          ),
        );
        children.add(
          DetailsDataField(
            label: field['label'] ?? '',
            value: field['value'] ?? '',
          ),
        );
      }

      return Column(children: children);
    } else {
      return Column(
        children: [
          DetailsDataField(label: 'Barcode Type', value: item.type),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.shade200,
            indent: 16,
            endIndent: 16,
          ),
          DetailsDataField(label: 'Value', value: item.text),
        ],
      );
    }
  }
}
