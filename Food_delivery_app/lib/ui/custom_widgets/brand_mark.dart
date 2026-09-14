import 'package:flutter/material.dart';
import 'package:khaanado/constants/asset_constants.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        AssetConstants.appIcon,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
