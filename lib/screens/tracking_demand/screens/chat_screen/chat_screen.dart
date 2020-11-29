import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:vehicles_saver_partner/app_router.dart';
import 'package:vehicles_saver_partner/blocs/auth_bloc.dart';
import 'package:vehicles_saver_partner/blocs/demand_bloc.dart';
import 'package:vehicles_saver_partner/components/dialog/msg_dialog.dart';
import 'package:vehicles_saver_partner/theme/style.dart';

import 'bubble_chat_widget.dart';



class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  DemandBloc demandBloc;
  AuthBloc authBloc;
  void _handleSubmitted(String text) {
    _textController.clear();

    demandBloc.sendMessage(text, (){
      print("sendMessage success");
    }, (msg){
      MsgDialog.showMsgDialog(context, "Nhắn tin", msg, null);
    }
    );
  }

  Widget _buildTextComposer() {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
            children: <Widget>[
              Flexible(
                child: TextField(
                  controller: _textController,
                  autofocus: true,
                  textInputAction: TextInputAction.unspecified,
                  decoration: InputDecoration.collapsed(
                      hintText: "Aa"),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                child: IconButton(
                    icon: Icon(
                      Icons.send,
                      color: primaryColor,
                    ),
                    onPressed: () => _handleSubmitted(_textController.text)),
              ),
            ]
        )
    );
  }

  Widget build(BuildContext context) {
    demandBloc = Provider.of<DemandBloc>(context);
    authBloc = Provider.of<AuthBloc>(context);
    if(!demandBloc.isHavingDemand()){
      Future.microtask(() =>  Navigator.of(context).pushNamedAndRemoveUntil(AppRoute.homeScreen, (Route<dynamic> route) => false));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Tin nhắn"),
        leading: IconButton(
          icon: Icon(Icons.clear,color: whiteColor,
          ),
          onPressed: (){
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
            children: <Widget>[
              Flexible(
                child: demandBloc?.currentDemand?.messages?.isNotEmpty?
                GestureDetector(
                    onHorizontalDragDown: (_){
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.all(8.0),
                      reverse: true,
                      itemCount: demandBloc?.currentDemand?.messages?.length,
                      itemBuilder: (_, int index) => Container(
                        child:  Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            BubbleChatWidget(
                              message: demandBloc?.currentDemand?.messages[demandBloc.currentDemand.messages.length - 1 - index]?.content,
                              time: demandBloc?.currentDemand?.messages[demandBloc.currentDemand.messages.length  - 1- index]?.parseTime(),
                              delivered: true,
                              isMe: demandBloc?.currentDemand?.messages[demandBloc.currentDemand.messages.length  - 1- index].userId == authBloc?.myInfo?.id,
                            ),
                          ],
                        ),
                      ),
                    )
                ) : Center(
                  child: Container(
                    child: SvgPicture.asset(
                        'assets/image/svg/no_message.svg',
                        color: disabledColor,
                        semanticsLabel: 'Acme Logo'
                    ),
                  ),
                ),
              ),
              Divider(height: 1.0),
              SafeArea(
                child: _buildTextComposer(),
              )
            ]
        ),
      ),
    );
  }
}


