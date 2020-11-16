import 'package:flutter/material.dart';

class MsgDialog {
  static void showMsgDialog(BuildContext context, String title, String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(msg),
            actions: [
              new FlatButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop(MsgDialog);
                },
              ),
            ],
          ),
    );
  }

  static void showConfirmDialog(BuildContext context, String title, String msg,
      Function onConfirm, Function onCancel) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)),
          content: Text(msg),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(MsgDialog);
                onConfirm();
              },
            ),
            FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(MsgDialog);
                  onCancel();
                })
          ],
        )
    );
  }
}
