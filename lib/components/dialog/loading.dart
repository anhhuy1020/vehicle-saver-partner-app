import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingWidget extends StatelessWidget {
  final String msg;

  LoadingWidget(this.msg);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xffffffff),
      height: 100,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: new Text(
              msg,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}