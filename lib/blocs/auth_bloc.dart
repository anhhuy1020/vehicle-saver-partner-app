import 'package:flutter/cupertino.dart';
import 'package:vehicles_saver_partner/data/models/auth/user_login.dart';
import 'package:vehicles_saver_partner/data/models/info/partner.dart';
import 'package:vehicles_saver_partner/network/socket/socket_connector.dart';

class AuthBloc extends ChangeNotifier{
  Partner myInfo = Partner();
  SocketConnector socket = SocketConnector.getInstance();

  AuthBloc(){
    socket.listenUpdateProfile(onUpdateProfile);
  }

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

  onUpdateProfile(data){
    try {
      if(data['name'] != null) myInfo.name = data['name'];
      if(data['_id'] != null) myInfo.id = data['_id'];
      if(data['email'] != null) myInfo.email = data['email'];
      if(data['address'] != null) myInfo.address = data['address'];
      if(data['phone'] != null) myInfo.phone = data['phone'];
      if(data['avatarUrl'] != null) myInfo.avatarUrl = data['avatarUrl'];
      notifyListeners();
    } catch (e) {
      print("updateProfile exception $e");
    }
  }

  updateProfile(Map req, Function onSuccess, Function onError){
    socket.updateProfile(req, onSuccess, onError);
  }

  cleanUp(){
    this.myInfo = null;
    this.socket.token = "";
  }
}