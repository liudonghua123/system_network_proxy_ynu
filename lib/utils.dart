import 'package:flutter/material.dart';

showMessageDialog(BuildContext context, String title, String content) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title, style: const TextStyle(color: Colors.blueAccent)),
        content: Text(content),
        actions: [
          TextButton(
            child: const Text("确定"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
