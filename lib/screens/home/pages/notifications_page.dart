import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NotificationsPageState();
}
class _NotificationsPageState extends State<NotificationsPage>{
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("Notifications page"),
      ),
    );
  }
}