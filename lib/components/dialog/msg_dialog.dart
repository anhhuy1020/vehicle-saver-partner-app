import 'package:flutter/material.dart';

class MsgDialog {
  static int num = 0;

  static void showMsgDialog(BuildContext context, String title, String msg, Function callback) {
    num++;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          new FlatButton(
            child: Text("OK"),
            onPressed: () {
              hideMsgDialog(context);
              if(callback != null) callback();
            },
          ),
        ],
      ),
    );
  }

  static void showConfirmDialog(BuildContext context, String title, String msg,
      Function onConfirm, Function onCancel) {
    num++;
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
                hideMsgDialog(context);
                if(onConfirm != null) onConfirm();
              },
            ),
            FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  hideMsgDialog(context);
                  if(onCancel != null) onCancel();
                })
          ],
        )
    );
  }

  static hideMsgDialog(BuildContext context) {
    if(num <= 0) return;
    Navigator.of(context).pop();
    num--;
  }
}
