import 'package:flutter/cupertino.dart';
import 'package:vehicles_saver_partner/data/models/demand/customer.dart';
import 'package:vehicles_saver_partner/data/models/demand/demand.dart';
import 'package:vehicles_saver_partner/data/models/map/place_model.dart';
import 'package:vehicles_saver_partner/network/socket/socket_connector.dart';
import 'package:vehicles_saver_partner/network/socket/socket_error.dart';
import 'package:vehicles_saver_partner/network/socket/socket_event.dart';
class DemandBloc extends ChangeNotifier{
  Demand currentDemand;
  List<Demand> demandHistory = [];
  
  List<Demand> availableDemands = [];
  
  SocketConnector socket;

  bool initSocketConnect = false;

  DemandBloc();

  onConnectServer(SocketConnector socket){
    if(initSocketConnect) return;
    initSocketConnect = true;
    this.socket = socket;
    socket.listenUpdateCurrentDemand(updateCurrentDemand);
    socket.listenUpdateListDemand(updateListDemand);
    socket.fetchCurrentDemand();
  }

  void updateCurrentDemand(data){
    if(data["errorCode"] != SocketError.SUCCESS) return;
    if(data["body"] != null) {
      this.currentDemand = Demand.fromJson(data["body"]);
    } else{
      this.currentDemand = null;
    }
    print("updateCurrentDemand ${this.currentDemand}");

    notifyListeners();
  }

  void updateListDemand(data){
    print("updateCurrentDemand 1 $data");
    if(data["errorCode"] != SocketError.SUCCESS) return;
    if(data["body"] != null) {
      var list = data["body"];
      this.currentDemand = Demand.fromJson(data["body"]);
    } else{
      this.availableDemands = [];
    }
    print("updateCurrentDemand 2 ${this.availableDemands}");

    notifyListeners();
  }

  bool isHavingDemand(){
    return currentDemand != null;
  }

  void fetchListDemand(double latitude, double longitude) {
    Map req = {
      "latitude": latitude,
      "lontitude": longitude
    };
    socket.fetchListDemand(req);
  }


}