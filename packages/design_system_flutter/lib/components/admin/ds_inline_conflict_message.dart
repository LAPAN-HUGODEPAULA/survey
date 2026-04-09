import 'package:flutter/material.dart';

class DsInlineConflictMessage extends StatelessWidget {
  const DsInlineConflictMessage({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        message,
        style: Theme.of(
          context,
        )
            .textTheme
            .bodySmall
            ?.copyWith(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
