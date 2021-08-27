import 'package:flutter/material.dart';

class AddDialog extends StatefulWidget {
  final Function(String) addCallback;

  const AddDialog(this.addCallback);

  @override
  _AddDialogState createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Enter exercise name:"),
      content: TextField(
        controller: controller,
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("CANCEL"),
        ),
        OutlinedButton(
          onPressed: () {
            widget.addCallback(controller.text);
            controller.clear();
            Navigator.pop(context);
          },
          child: const Text("OK"),
        ),
      ],
      elevation: 24.0,
    );
  }
}
