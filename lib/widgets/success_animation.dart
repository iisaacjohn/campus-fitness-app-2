import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../utils/asset_helper.dart';

class SuccessAnimation extends StatelessWidget {
  final double size;
  final VoidCallback? onFinished;
  
  const SuccessAnimation({
    Key? key,
    this.size = 150,
    this.onFinished,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Lottie.asset(
          AssetHelper.successAnimation,
          fit: BoxFit.contain,
          repeat: false,
          onLoaded: (composition) {
            if (onFinished != null) {
              Future.delayed(composition.duration, onFinished!);
            }
          },
        ),
      ),
    );
  }
}
