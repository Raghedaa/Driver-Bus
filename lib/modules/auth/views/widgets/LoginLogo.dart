import 'package:driver_bus_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

class LoginBackground extends StatelessWidget {
  final Widget child;

  const LoginBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(color: context.scaffoldBackgroundColor),
      child: child,
    );
  }
}
