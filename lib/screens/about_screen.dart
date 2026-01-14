import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String deviceId = '';

  @override
  void initState() {
    super.initState();
    _loadDeviceId();
  }

  Future<void> _loadDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    setState(() {
      deviceId = androidInfo.id;
    });
  }

  void _handleLinkPress(String url) {
    launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Background
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/BG.svg',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                /// Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.white,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: SvgPicture.asset(
                            'assets/icons/chevron.svg',
                            height: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SvgPicture.asset(
                        'assets/images/logo_barkoder.svg',
                        height: 18,
                      ),
                    ],
                  ),
                ),

                /// Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    children: [
                      /// Description Card
                      _Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Barcode Scanner SDK by barKoder',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),

                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.7,
                                  color: Color(0xFF333333),
                                ),
                                children: [
                                  _linkSpan(
                                    'Barcode Scanner Demo by barKoder',
                                    () => _handleLinkPress('https://barkoder.com/'),
                                  ),
                                  const TextSpan(
                                    text:
                                        ' showcases the enterprise-grade performance of the ',
                                  ),
                                  const TextSpan(
                                    text: 'barKoder Barcode Scanner SDK',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const TextSpan(
                                    text:
                                        ' along with most of its features in a wide variety of scanning scenarios.\n\n'
                                        'Whether from ',
                                  ),
                                  _linkSpan(
                                    'One-Dimensional',
                                    () => _handleLinkPress(
                                      'https://barkoder.com/barcode-types#1D-barcodes',
                                    ),
                                  ),
                                  const TextSpan(text: ' or '),
                                  _linkSpan(
                                    'Two-Dimensional',
                                    () => _handleLinkPress(
                                      'https://barkoder.com/barcode-types#2D-barcodes',
                                    ),
                                  ),
                                  const TextSpan(
                                    text:
                                        ' barcodes, the barKoder API can capture the data reliably, accurately and surprisingly fast, even under very challenging conditions and environments.\n\n'
                                        'You can test the barKoder Barcode Scanner SDK at your own convenience by signing up for a free trial:',
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            /// CTA Button
                            Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE52E4C),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 28,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                onPressed: () => _handleLinkPress('https://barkoder.com/trial'),
                                child: const Text(
                                  'Get a free trial demo',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// Info Card
                      _Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Info',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            _infoRow('Device ID', deviceId),
                            _divider(),
                            _infoRow(
                              'App Version',
                              '0.0.1',
                              valueColor: const Color(0xFFE52E4C),
                            ),
                            _divider(),
                            _infoRow('SDK Version', '1.5.1'),
                            _divider(),
                            _infoRow('Lib Version', '3.10.4'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                    
                      _Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Resources',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _LinkButton(
                              label: 'Official Website',
                              url: 'https://barkoder.com/',
                              onTap: _handleLinkPress,
                            ),
                            _LinkButton(
                              label: 'Documentation',
                              url: 'https://barkoder.com/docs/v1/home',
                              onTap: _handleLinkPress,
                            ),
                            _LinkButton(
                              label: 'Support',
                              url: 'https://barkoder.com/faq',
                              onTap: _handleLinkPress,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static TextSpan _linkSpan(String text, VoidCallback onTap) {
    return TextSpan(
      text: text,
      style: const TextStyle(
        color: Color(0xFFE52E4C),
        fontWeight: FontWeight.w600,
      ),
      recognizer: TapGestureRecognizer()..onTap = onTap,
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      color: const Color(0xFFF0F0F0),
    );
  }
}

/// Reusable Card Widget
class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class _LinkButton extends StatelessWidget {
  final String label;
  final String url;
  final Function(String) onTap;

  const _LinkButton({
    required this.label,
    required this.url,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(url),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFE52E4C),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Color(0xFFE52E4C),
            ),
          ],
        ),
      ),
    );
  }
}