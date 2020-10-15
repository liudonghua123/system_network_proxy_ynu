import 'package:flutter/material.dart';

showMessageDialog(BuildContext context, String title, String content) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title, style: TextStyle(color: Colors.blueAccent)),
        content: Text(content),
        actions: [
          FlatButton(
            child: Text("确定"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
