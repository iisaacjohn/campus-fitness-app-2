import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../utils/asset_helper.dart';

class LoadingAnimation extends StatelessWidget {
  final double size;
  
  const LoadingAnimation({
    Key? key,
    this.size = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Lottie.asset(
          AssetHelper.loadingAnimation,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
