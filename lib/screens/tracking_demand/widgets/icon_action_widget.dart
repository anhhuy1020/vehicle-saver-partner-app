import 'package:flutter/material.dart';
import 'package:vehicles_saver_partner/theme/style.dart';

class IconAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  IconAction({this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        elevation: 10.0,
        color: primaryColor,
        shape: CircleBorder(),
        child: Padding(
          padding: EdgeInsets.all(2.0),
          child: SizedBox(
              height: 65,
              width: 65,
              child: Icon(
                icon,
                size: 30,
                color: blackColor,
              )
          ),
        ),
      ),
    );
  }
}
