import 'package:flutter/material.dart';
import 'package:vehicles_saver_partner/components/dialog/loading.dart';

class LoadingDialog {
  static void showLoadingDialog(BuildContext context, String msg) {
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
    Navigator.of(context).pop(LoadingDialog);
  }
}
