import 'package:flutter/material.dart';
import 'package:timebrew/settings.dart';

class AppBarMenuButton extends StatelessWidget {
  const AppBarMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const Settings(),
          ),
        );
      },
      icon: const Icon(Icons.more_vert_rounded),
    );
  }
}
