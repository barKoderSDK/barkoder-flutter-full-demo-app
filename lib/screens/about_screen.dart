import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../widgets/about/about_header.dart';
import '../widgets/about/about_card.dart';
import '../widgets/about/about_info_row.dart';
import '../widgets/about/about_divider.dart';
import '../widgets/about/about_link_button.dart';

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
          Positioned.fill(
            child: SvgPicture.asset('assets/images/BG.svg', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                const AboutHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    children: [
                      _buildDescriptionCard(),
                      const SizedBox(height: 16),
                      _buildInfoCard(),
                      const SizedBox(height: 16),
                      _buildResourcesCard(),
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

  Widget _buildDescriptionCard() {
    return AboutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Barcode Scanner SDK by barKoder',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
                  text: ' showcases the enterprise-grade performance of the ',
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
    );
  }

  Widget _buildInfoCard() {
    return AboutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Info',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          AboutInfoRow(label: 'Device ID', value: deviceId),
          const AboutDivider(),
          const AboutInfoRow(
            label: 'App Version',
            value: '0.0.1',
            valueColor: Color(0xFFE52E4C),
          ),
          const AboutDivider(),
          const AboutInfoRow(label: 'SDK Version', value: '1.5.1'),
          const AboutDivider(),
          const AboutInfoRow(label: 'Lib Version', value: '3.10.4'),
        ],
      ),
    );
  }

  Widget _buildResourcesCard() {
    return AboutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resources',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          AboutLinkButton(
            label: 'Official Website',
            url: 'https://barkoder.com/',
            onTap: _handleLinkPress,
          ),
          AboutLinkButton(
            label: 'Documentation',
            url: 'https://barkoder.com/docs/v1/home',
            onTap: _handleLinkPress,
          ),
          AboutLinkButton(
            label: 'Support',
            url: 'https://barkoder.com/faq',
            onTap: _handleLinkPress,
          ),
        ],
      ),
    );
  }

  TextSpan _linkSpan(String text, VoidCallback onTap) {
    return TextSpan(
      text: text,
      style: const TextStyle(
        color: Color(0xFFE52E4C),
        fontWeight: FontWeight.w600,
      ),
      recognizer: TapGestureRecognizer()..onTap = onTap,
    );
  }
}
