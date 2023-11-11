import 'package:flutter/material.dart';
import 'package:timebrew/utils.dart';

class NoDataEmoji extends StatelessWidget {
  const NoDataEmoji({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            getRandom404Emoji(),
            style: const TextStyle(
              fontSize: 40,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text('Nothing to show')
        ],
      ),
    );
  }
}
