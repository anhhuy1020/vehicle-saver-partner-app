import 'package:flutter/material.dart';
import 'package:vehicles_saver_partner/components/dialog/loading.dart';

class LoadingDialog {
  static int num = 0;
  static void showLoadingDialog(BuildContext context, String msg) {
    num++;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => new Dialog(
          backgroundColor: Colors.transparent,
          child: LoadingWidget(msg)
      ),
    );
  }

  static hideLoadingDialog(BuildContext context) {
    if(num <= 0) return;
    Navigator.of(context).pop(LoadingDialog);
    num--;
  }
}
