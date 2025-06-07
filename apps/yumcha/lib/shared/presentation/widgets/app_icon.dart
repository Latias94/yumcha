import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  final double? size;
  final Color? color;

  const AppIcon({super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chat_bubble_outline,
      size: size ?? 24,
      color: color ?? Theme.of(context).colorScheme.primary,
    );
  }
}
