import 'package:flutter/material.dart';

class Conditional extends StatelessWidget {
  final bool condition;
  final Widget? ifTrue;
  final Widget? ifFalse;
  const Conditional({
    super.key,
    required this.condition,
    this.ifTrue,
    this.ifFalse,
  });

  @override
  Widget build(BuildContext context) {
    if (condition) {
      return ifTrue ?? Container();
    } else {
      return ifFalse ?? Container();
    }
  }
}
