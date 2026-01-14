import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/home_sections.dart';
import '../widgets/top_bar.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/home_grid.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _handleItemPress(BuildContext context, HomeGridItem item) {
    if (item.id == 'gallery') {
      // Navigate to scanner with gallery mode
      context.push('/scanner', extra: {'mode': item.mode});
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
          // Background SVG
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/BG.svg',
              fit: BoxFit.cover,
            ),
          ),
          // Content
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
        ],
      ),
    );
  }
}
