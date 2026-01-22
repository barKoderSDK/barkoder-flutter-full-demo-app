import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:barkoder_flutter/barkoder_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/home_sections.dart';
import '../widgets/top_bar.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/home_grid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../models/history_item.dart';
import '../services/history_service.dart';
import 'barcode_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Barkoder? _barkoder;
  bool _isLoading = false;

  void _onBarkoderViewCreated(Barkoder barkoder) {
    _barkoder = barkoder;
    _configureBarkoder();
  }

  void _configureBarkoder() async {
    if (_barkoder == null) return;

    try {
      // Configure barkoder with all barcode types enabled
      _barkoder!.setBarcodeTypeEnabled(BarcodeType.aztec, true);
      _barkoder!.setBarcodeTypeEnabled(BarcodeType.aztecCompact, true);
      _barkoder!.setBarcodeTypeEnabled(BarcodeType.qr, true);
      _barkoder!.setBarcodeTypeEnabled(BarcodeType.qrMicro, true);
      _barkoder!.setBarcodeTypeEnabled(BarcodeType.code128, true);
      _barkoder!.setBarcodeTypeEnabled(BarcodeType.code93, true);
      _barkoder!.setBarcodeTypeEnabled(BarcodeType.code39, true);
      _barkoder!.setBarcodeTypeEnabled(BarcodeType.codabar, true);
      _barkoder!.setBarcodeTypeEnabled(BarcodeType.code11, true);
      _barkoder!.setBarcodeTypeEnabled(BarcodeType.msi, true);
      _barkoder!.setBarcodeTypeEnabled(BarcodeType.upcA, true);
      _barkoder!.setBarcodeTypeEnabled(BarcodeType.upcE, true);
      _barkoder!.setBarcodeTypeEnabled(BarcodeType.ean13, true);
      _barkoder!.setBarcodeTypeEnabled(BarcodeType.ean8, true);
      _barkoder!.setBarcodeTypeEnabled(BarcodeType.pdf417, true);
      _barkoder!.setBarcodeTypeEnabled(BarcodeType.pdf417Micro, true);
      _barkoder!.setBarcodeTypeEnabled(BarcodeType.datamatrix, true);
      _barkoder!.setBarcodeTypeEnabled(BarcodeType.code25, true);
      _barkoder!.setBarcodeTypeEnabled(BarcodeType.interleaved25, true);
      _barkoder!.setBarcodeTypeEnabled(BarcodeType.itf14, true);
      _barkoder!.setBarcodeTypeEnabled(BarcodeType.iata25, true);
      _barkoder!.setBarcodeTypeEnabled(BarcodeType.matrix25, true);
      _barkoder!.setBarcodeTypeEnabled(BarcodeType.coop25, true);
      _barkoder!.setBarcodeTypeEnabled(BarcodeType.code32, true);
      _barkoder!.setBarcodeTypeEnabled(BarcodeType.telepen, true);
      _barkoder!.setBarcodeTypeEnabled(BarcodeType.dotcode, true);
      _barkoder!.setBarcodeTypeEnabled(BarcodeType.idDocument, true);

      // Enable image result for gallery scanning
      _barkoder!.setImageResultEnabled(true);
    } catch (e) {
      debugPrint('Error configuring barkoder: $e');
    }
  }

  Future<void> _handleGalleryScan(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    try {
      // Pick image from gallery
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) {
        return;
      }

      if (!mounted) return;

      // Show loading after image is selected
      setState(() => _isLoading = true);

      // Read the file and convert it to base64
      final bytes = await image.readAsBytes();
      String base64Image = base64Encode(bytes);

      if (!mounted) return;

      // Scan the image directly using the barkoder instance
      if (_barkoder == null) {
        setState(() => _isLoading = false);
        if (mounted) {
          _showResultDialog(
            context,
            success: false,
            text: 'Scanner not initialized. Please try again.',
          );
        }
        return;
      }

      _barkoder!.scanImage((BarkoderResult result) {
        setState(() => _isLoading = false);

        if (!mounted) return;

        final results = result.decoderResults;

        if (results.isNotEmpty) {
          final decoderResult = results.first;

          // Create a data URI for the image
          final imageDataUri = 'data:image/jpeg;base64,$base64Image';

          // Save to history
          HistoryService.addScan(
            text: decoderResult.textualData,
            type: decoderResult.barcodeTypeName,
            image: imageDataUri,
          );

          // Create HistoryItem with the scanned data
          final historyItem = HistoryItem(
            text: decoderResult.textualData,
            type: decoderResult.barcodeTypeName,
            image: imageDataUri,
            timestamp: DateTime.now().millisecondsSinceEpoch,
          );

          // Navigate to BarcodeDetailsScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BarcodeDetailsScreen(item: historyItem),
            ),
          );
        } else {
          _showNoBarcodeDialog(context);
        }
      }, base64Image);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showResultDialog(
          context,
          success: false,
          text: 'Error scanning image: $e',
        );
      }
    }
  }

  void _showNoBarcodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          'No barcodes or MRZ detected :(',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: const Text(
          'Please ensure the image you\'ve selected contains at least one barcode. Try a different image.\n\nAlso verify the barcode type you\'re trying to scan is enabled in the settings.',
          style: TextStyle(color: Colors.black54, fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'DISMISS',
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
  }

  void _showResultDialog(
    BuildContext context, {
    required bool success,
    required String text,
    String? type,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.red,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              success ? 'Scan Successful' : 'Scan Failed',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (type != null) ...[
              const Text(
                'Type:',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                type,
                style: const TextStyle(
                  color: Color(0xFFE52E4C),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Text(
              'Result:',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 4),
            SelectableText(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFFE52E4C)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleItemPress(BuildContext context, HomeGridItem item) async {
    if (item.id == 'gallery') {
      await _handleGalleryScan(context);
    } else if (item.action == 'url' && item.url != null) {
      launchUrl(Uri.parse(item.url!));
    } else if (item.mode != null) {
      context.push('/scanner', extra: {'mode': item.mode});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset('assets/images/BG.svg', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                const TopBar(logoPosition: 'left'),
                Expanded(
                  child: HomeGrid(
                    sections: homeSections,
                    onItemPress: (item) => _handleItemPress(context, item),
                  ),
                ),
                const BottomBar(),
              ],
            ),
          ),
          // Hidden BarkoderView for background initialization and gallery scanning
          Positioned(
            left: -1,
            top: -1,
            child: SizedBox(
              width: 1,
              height: 1,
              child: BarkoderView(
                licenseKey: dotenv.env['BARKODER_LICENSE_KEY'] ?? '',
                onBarkoderViewCreated: _onBarkoderViewCreated,
              ),
            ),
          ),
          // Loading overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircularProgressIndicator(color: Color(0xFFE52E4C)),
                        SizedBox(height: 16),
                        Text(
                          'Processing image...',
                          style: TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
