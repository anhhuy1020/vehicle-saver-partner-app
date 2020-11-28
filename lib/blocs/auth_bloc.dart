import 'package:flutter/cupertino.dart';
import 'package:vehicles_saver_partner/data/models/auth/user_login.dart';
import 'package:vehicles_saver_partner/data/models/info/partner.dart';
import 'package:vehicles_saver_partner/network/socket/socket_connector.dart';

class AuthBloc extends ChangeNotifier{
  Partner myInfo = Partner();
  SocketConnector socket = SocketConnector.getInstance();

  AuthBloc();

  login(UserLogin userLogin, Function onSuccess, Function(String) onError) {
    socket.login(userLogin, (data) {
      print("successsss");
      try {
        myInfo = Partner.fromJson(data);
        onSuccess();
      } catch (e){
        onError(e);
      }
    }, (msg) {
      print("Login error: $msg");
      onError(msg);
    });
  }
  cleanUp(){
    this.myInfo = null;
    this.socket.token = "";
  }
}