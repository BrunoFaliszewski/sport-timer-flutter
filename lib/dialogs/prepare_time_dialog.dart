import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrepareDialog extends StatefulWidget {
  final Function getPrefsCallback;

  const PrepareDialog(this.getPrefsCallback);
  
  @override
  _PrepareDialogState createState() => _PrepareDialogState();
}

class _PrepareDialogState extends State<PrepareDialog> {
  int _prepareMinutes = 0;
  int _prepareSeconds = 0;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 5, 0, 20),
            child: Text(
              "Prepare Time",
              style: TextStyle(fontSize: 25),
            )
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Text(
                    "Minutes",
                    style: TextStyle(fontSize: 12),
                  ),
                  NumberPicker(
                    value: _prepareMinutes,
                    minValue: 0,
                    maxValue: 100,
                    onChanged: (value) => setState(() => _prepareMinutes = value),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black26),
                    )
                  )
                ]
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Text(
                  ":",
                  style: TextStyle(fontSize: 25),
                )
              ),
              Column(
                children: [
                  const Text(
                    "Seconds",
                    style: TextStyle(fontSize: 12),
                  ),
                  NumberPicker(
                    value: _prepareSeconds,
                    minValue: 0,
                    maxValue: 59,
                    onChanged: (value) => setState(() => _prepareSeconds = value),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black26),
                    )
                  )
                ]
              )
            ]
          )
        ]
      ),
      actions: [
        OutlinedButton(
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            prefs.setInt('prepareTime', _prepareMinutes * 60 + _prepareSeconds);
            widget.getPrefsCallback();
            Navigator.pop(context);
          },
          child: const Text("OK")
        )
      ],
    );
  }
}