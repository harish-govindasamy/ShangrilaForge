import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String message;
  final bool showBackground;

  const LoadingIndicator({
    super.key,
    this.message = 'Loading...',
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: showBackground ? Colors.white : Colors.transparent,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
