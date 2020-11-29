import 'package:flutter/material.dart';

class BubbleChatWidget extends StatelessWidget {

  BubbleChatWidget({this.message, this.time, this.delivered, this.isMe});

  final String message, time;
  final delivered, isMe;

  @override
  Widget build(BuildContext context) {
    final mainAlign = isMe ? MainAxisAlignment.end : MainAxisAlignment.start;
    final crossAlign = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final textAlign = isMe ? TextAlign.right : TextAlign.left;
    final bg = isMe ?Color(0xFFFFD428): Color(0xFFF7F8F9) ;
    final icon = delivered ? Icons.done_all : Icons.done;
    final radius = isMe

        ? BorderRadius.only(
      topRight: Radius.circular(5.0),
      bottomLeft: Radius.circular(10.0),
      bottomRight: Radius.circular(5.0),
    )
        : BorderRadius.only(
      topLeft: Radius.circular(5.0),
      bottomLeft: Radius.circular(5.0),
      bottomRight: Radius.circular(10.0),
    );
    return Row(
        mainAxisAlignment: mainAlign,
        //this will determine if the message should be displayed left or right
        children: [
          Flexible(
            //Wrapping the container with flexible widget
            child: Container(
                padding: EdgeInsets.all(8.0),
                margin: EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.all(Radius.circular(8.0))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: crossAlign,
                  children: <Widget>[
                    Flexible(
                      //We only want to wrap the text message with flexible widget
                        child: Container(
                            child: Text(
                              message,
                              textAlign: textAlign,
                            ),
                        )
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: mainAlign,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 3.0),
                          child: Text(
                            time,
                            style: TextStyle(fontSize: 10.0, color: Colors.grey),
                          ),
                        ),
                        SizedBox(
                          width: 3.0,
                        ),
                        Icon(icon, color: Colors.grey, size: 15,)
                      ],
                    ),
                  ],
                )),

          )

        ]
    );
  }
}
