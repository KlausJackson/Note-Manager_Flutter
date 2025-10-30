import 'package:flutter/material.dart';

class ShowDialogs {
  // dialog with title, message, ok button: error / info
  static Future<void> showInfoDialog({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onOkPressed,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
              if (onOkPressed != null) {
                onOkPressed();
              }
            },
          ),
        ],
      ),
    );
  }

  // dialog with cancel and confirmation action: delete
  static Future<void> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(confirmText),
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
          ),
        ],
      ),
    );
  }

  // dialog with input field and cancel/confirm actions: password confirmation, change tag name
  // returns the input text if confirmed, null if cancelled
  static Future<String?> showInputDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
  }) {
    final textController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                obscureText: true,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Input',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () =>
                  Navigator.of(ctx).pop(null), // Return null on cancel
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(confirmText),
              onPressed: () {
                Navigator.of(ctx).pop(textController.text.trim());
              }, // Return input text on confirm
            ),
          ],
        );
      },
    );
  }
}
