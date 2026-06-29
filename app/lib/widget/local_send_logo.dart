import 'package:flutter/material.dart';
import 'package:gravitysend_app/gen/assets.gen.dart';

class LocalSendLogo extends StatelessWidget {
  final bool withText;

  const LocalSendLogo({required this.withText});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // In dark mode: show white variant for contrast. In light mode: show full-color Google logo.
    final logo = isDark
        ? Assets.img.logo512White.image(width: 120, height: 120)
        : Assets.img.logo512.image(width: 120, height: 120);

    if (withText) {
      return Column(
        children: [
          logo,
          const Text(
            'Gravity Send',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      return logo;
    }
  }
}
