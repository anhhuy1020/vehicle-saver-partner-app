import 'dart:async';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:vehicles_saver_partner/config.dart';
import 'package:vehicles_saver_partner/data/models/auth/user_login.dart';
import 'package:vehicles_saver_partner/network/socket/socket_error.dart';
import 'package:vehicles_saver_partner/network/socket/socket_event.dart';

class SocketConnector{
  SocketIOManager manager = SocketIOManager();
  SocketIO socket;
  ConnectionStatus status;


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

    socket.connect();
  }

  addServerListener(String eventName, Function listener){
    socket.isConnected().then((check) {
      if(check) {
        socket.on(eventName, listener);
      }
    });
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
        socket.emit(SocketEvent.LOGIN, [loginData.toJson()]);
        socket.on(SocketEvent.LOGIN, (res) {
          print(res);
          if (res['errorCode'] == SocketError.SUCCESS) {
            onSuccess(res['body']);
          } else {
            onError(res['body']["errorMessage"]);
          }
          socket.off(SocketEvent.LOGIN);
        });
      },  onError
    );
  }
}

enum ConnectionStatus{
  CONNECTED,
  DISCONNECTED
}