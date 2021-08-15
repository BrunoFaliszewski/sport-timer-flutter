import 'package:flutter/material.dart';

class SaveDialog extends StatefulWidget {
  final Function(String) saveCallback;

  const SaveDialog(this.saveCallback);

  @override
  _SaveDialogState createState() => _SaveDialogState();
}

class _SaveDialogState extends State<SaveDialog> {
  final controller = TextEditingController();

  void okClicked() {
    widget.saveCallback(controller.text);
    controller.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Enter set name:"),
      content: TextField(
        controller: controller,
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("CANCEL"),
        ),
        OutlinedButton(
          onPressed: okClicked,
          child: const Text("OK"),
        ),
      ],
      elevation: 24.0,
    );
  }
}
