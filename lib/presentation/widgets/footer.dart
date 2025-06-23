import 'package:flutter/material.dart';

Widget buildFooter({
  required BuildContext context,
  required String statusMessage,
  required bool isLoading,
  required VoidCallback refreshAll,
}) {
  return Row(
    children: [
      Expanded(
        child: Text(
          statusMessage,
          style: Theme.of(context).textTheme.bodySmall,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      const SizedBox(width: 16),
      if (isLoading)
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      const SizedBox(width: 16),
      FilledButton.icon(
        onPressed: isLoading ? null : refreshAll,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Refresh'),
      ),
    ],
  );
}
