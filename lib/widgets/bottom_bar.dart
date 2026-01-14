import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  static const _textStyle = TextStyle(
    fontSize: 12,
    color: Colors.black87,
    fontWeight: FontWeight.normal,
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.only(
            left: 60,
            right: 60,
            top: 20,
            bottom: 16,
          ),
          decoration: BoxDecoration(color: Colors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Recent button
              InkWell(
                onTap: () => context.push('/history'),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/recent.svg',
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        Colors.black87,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Recent', style: _textStyle),
                  ],
                ),
              ),
              // About button
              InkWell(
                onTap: () => context.push('/about'),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/info.svg',
                      height: 22,
                      colorFilter: const ColorFilter.mode(
                        Colors.black87,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('About', style: _textStyle),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Anyscan button
        Positioned(
          bottom: 40,
          child: InkWell(
            onTap: () => context.push('/scanner', extra: {'mode': 'anyscan'}),
            child: Container(
              width: 60,
              height: 60,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE52E4C),
                borderRadius: BorderRadius.circular(18),
              ),
              child: SvgPicture.asset(
                'assets/icons/start.svg',
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          child: InkWell(
            onTap: () => context.push('/scanner', extra: {'mode': 'anyscan'}),
            child: const Text('Anyscan', style: _textStyle),
          ),
        ),
      ],
    );
  }
}
