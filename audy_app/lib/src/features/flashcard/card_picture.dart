import 'dart:convert';

import 'package:flutter/material.dart';

class CardPicture extends StatelessWidget {
  const CardPicture(this.source, {super.key, this.size = 100});
  final String? source;
  final double size;
  @override
  Widget build(BuildContext context) {
    Widget fallback() => Icon(Icons.style_outlined, size: size / 2);
    final value = source;
    if (value == null || value.isEmpty) {
      return SizedBox(width: size, height: size, child: fallback());
    }
    if (value.startsWith('emoji:')) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            value.substring(6),
            style: TextStyle(fontSize: size * .5),
          ),
        ),
      );
    }
    if (value.startsWith('data:image/')) {
      try {
        return Image.memory(
          base64Decode(value.split(',').last),
          width: size,
          height: size,
          cacheWidth: 400,
          fit: BoxFit.contain,
          errorBuilder: (_, e, s) => fallback(),
        );
      } catch (_) {
        return fallback();
      }
    }
    if (value.startsWith('assets/')) {
      return Image.asset(
        value,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, e, s) => fallback(),
      );
    }
    return fallback();
  }
}
