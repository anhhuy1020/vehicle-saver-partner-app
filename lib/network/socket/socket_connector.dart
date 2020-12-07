import 'dart:async';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:vehicles_saver_partner/config.dart';
import 'package:vehicles_saver_partner/data/models/auth/user_login.dart';
import 'package:vehicles_saver_partner/data/models/bill/bill.dart';
import 'package:vehicles_saver_partner/data/models/bill/bill_item.dart';
import 'package:vehicles_saver_partner/network/socket/socket_error.dart';
import 'package:vehicles_saver_partner/network/socket/socket_event.dart';

class SocketConnector{
  SocketIOManager manager = SocketIOManager();
  SocketIO socket;
  ConnectionStatus status;
  Function onLogin;
  Function onAcceptDemand;
  Function onCancelDemand;
  Function onChat;
  Function onLoginSuccess = (data) {print ("onLoginSuccess $data");};
  Function onUpdateListDemand = (data) {print ("onUpdateListDemand $data");};
  Function onUpdateCurrentDemand = (data) {print ("onUpdateCurrentDemand $data");};
  Function onUpdateProfileSuccess = (data) {print ("onUpdateProfile success $data");};
  Function onUpdateProfile = (msg) {print ("onUpdateProfileError $msg");};
  Function onInvoice;
  String token;


  SocketConnector();

  static final SocketConnector _instance = SocketConnector();

  static SocketConnector getInstance(){
    return _instance;
  }

  createSocketConnection(Function onConnected, Function onError) async {
    print("createSocketConnection...");

    socket = await manager.createInstance(SocketOptions(
      //Socket IO server URI
        Config.SERVICE_URI,
        nameSpace: "/partners",
        //Query params - can be used for authentication
        query: {
          "auth": ''
        },
        //Enable or disable platform channel logging
        enableLogging: false,
        transports: [
          Transports.WEB_SOCKET /*, Transports.POLLING*/
        ] //Enable required transport
    ));

    socket.onConnect((data){
      status = ConnectionStatus.CONNECTED;
      print("connected... $data");
      onConnected();
    });

    socket.onConnectError((data){
      status = ConnectionStatus.DISCONNECTED;
      print("Connection Error $data");
      onError("Không thể kết nối tới server");
      socket.off(SocketIO.CONNECT_ERROR);
      socket.onConnectError((data){
        status = ConnectionStatus.DISCONNECTED;
        print("Connection Error $data");
      });
    });

    socket.onConnectTimeout((data){
      status = ConnectionStatus.DISCONNECTED;
      print("Connection Timed Out $data");
      onError("Không thể kết nối tới server");
    });

    socket.onDisconnect((data) {
      status = null;
      print("Disconnect $data");
    });

    socket.on(SocketEvent.FETCH_LIST_DEMAND, onUpdateListDemand);

    socket.on(SocketEvent.FETCH_CURRENT_DEMAND, onUpdateCurrentDemand);

    socket.connect();
  }

  addServerListener(String eventName, Function listener){
    socket.isConnected().then((check) {
      if(check) {
        socket.on(eventName, listener);
      }
    });
  }

  listenUpdateProfile(Function listener){
    onUpdateProfileSuccess = listener;
  }

  listenUpdateCurrentDemand(Function listener){
    onUpdateCurrentDemand = listener;
  }

  listenLoginSuccess(Function listener){
    onLoginSuccess = listener;
  }

  listenUpdateListDemand(Function listener){
    onUpdateListDemand = listener;
  }

  fetchCurrentDemand () async {
    print("fetchCurrentDemand!");
    checkConnection(() {
      socket.emit(SocketEvent.FETCH_CURRENT_DEMAND, [token]);
    },  (msg) => print("fetchCurrentDemand: $msg")
    );
  }

  fetchListDemand (req) async {
    checkConnection(() {
      socket.emit(SocketEvent.FETCH_LIST_DEMAND, [req, token]);
    },  (msg) => print("fetchCurrentDemand: $msg")
    );
  }

  updateLocation (req) async {
    checkConnection(() {
      socket.emit(SocketEvent.UPDATE_LOCATION, [req, token]);
    },  (msg) => print("updateLocation: $msg")
    );
  }
  
  Future<bool> checkConnection(Function callback, Function onError) async {
    if(status == null){
       createSocketConnection(callback, onError);
    } else{
      callback();
    }
  }
  
  login (UserLogin loginData, Function onSuccess, Function onError) async {
    checkConnection(() {
      this.onLogin = (res) {
        print(res);
        if (res['errorCode'] == SocketError.SUCCESS) {
          token = res['body']['token'];
          onLoginSuccess(res['body']);
          onSuccess(res['body']['partner']);
        } else {
          onError(res['body']["errorMessage"]);
        }
        socket.off(SocketEvent.LOGIN, onLogin);

      };
      socket.off(SocketEvent.LOGIN);
      socket.on(SocketEvent.LOGIN, onLogin);
      socket.emit(SocketEvent.LOGIN, [loginData.toJson()]);
    },  onError
    );
  }

  updateProfile (Map req, Function onSuccess, Function onError) async {
    print("update profile: $req");
    checkConnection(() {
      onUpdateProfile = (res) {
        print("onUpdateProfile profile: $res");
        if (res['errorCode'] == SocketError.SUCCESS) {
          this.onUpdateProfileSuccess(res['body']);
          onSuccess();
        } else {
          onError(res['body']["errorMessage"]);
        }
      };
      socket.off(SocketEvent.UPDATE_PROFILE);
      socket.on(SocketEvent.UPDATE_PROFILE, onUpdateProfile);
      socket.emit(SocketEvent.UPDATE_PROFILE, [req, token]);
    },  onError
    );
  }


  acceptDemand (String demandId, Function onSuccess, Function onError) async {
    checkConnection(() {
      this.onAcceptDemand = (res) {
        print(res);
        if (res['errorCode'] == SocketError.SUCCESS) {
          onSuccess(res);
        } else {
          onError(res['body']["errorMessage"]);
        }
        socket.off(SocketEvent.ACCEPT_DEMAND, onAcceptDemand);
      };
      socket.off(SocketEvent.ACCEPT_DEMAND);
      socket.on(SocketEvent.ACCEPT_DEMAND, onAcceptDemand);
      socket.emit(SocketEvent.ACCEPT_DEMAND, [{"demandId": demandId}, token]);
    },  onError
    );
  }

  invoice (List<BillItem> billItems, Function onSuccess, Function onError) async {
    checkConnection(() {
      this.onInvoice = (res) {
        print("invoice res = $res");
        if (res['errorCode'] == SocketError.SUCCESS) {
          onSuccess(res);
        } else {
          onError(res['body']["errorMessage"]);
        }
        socket.off(SocketEvent.INVOICE, onInvoice);
      };

      List<Map> req = [];
      for (int i = 0; i < billItems.length; i++){
        req.add(billItems[i].toJson());
      }
      print("req == $req");

      socket.off(SocketEvent.INVOICE);
      socket.on(SocketEvent.INVOICE, onAcceptDemand);
      socket.emit(SocketEvent.INVOICE, [req, token]);
    },  onError
    );
  }
  sendMessage (String text, Function onSuccess, Function onError) {
    checkConnection(() {
      onChat = (res) {
        print("onChat");
        print(res);
        if (res['errorCode'] == SocketError.SUCCESS) {
          onSuccess();
        } else {
          onError(res['body']["errorMessage"]);
        }
      };
      socket.off(SocketEvent.CHAT);
      socket.on(SocketEvent.CHAT, onChat);
      socket.emit(SocketEvent.CHAT, [text, token]);
    },  onError
    );
  }

  cancelDemand (String reason, Function onSuccess, Function onError) {
    checkConnection(() {
      onCancelDemand = (res) {
        print("onCancelDemand");
        print(res);
        if (res['errorCode'] == SocketError.SUCCESS) {
          onSuccess();
        } else {
          onError(res['body']["errorMessage"]);
        }
      };
      socket.off(SocketEvent.CANCEL_DEMAND);
      socket.on(SocketEvent.CANCEL_DEMAND, onCancelDemand);
      socket.emit(SocketEvent.CANCEL_DEMAND, [{"reason":reason},token]);
    },  onError
    );
  }
}

enum ConnectionStatus{
  CONNECTED,
  DISCONNECTED
}