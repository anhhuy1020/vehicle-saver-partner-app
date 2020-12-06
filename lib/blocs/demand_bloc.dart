import 'package:flutter/cupertino.dart';
import 'package:vehicles_saver_partner/data/models/bill/bill.dart';
import 'package:vehicles_saver_partner/data/models/bill/bill_item.dart';
import 'package:vehicles_saver_partner/data/models/demand/customer.dart';
import 'package:vehicles_saver_partner/data/models/demand/demand.dart';
import 'package:vehicles_saver_partner/data/models/map/place_model.dart';
import 'package:vehicles_saver_partner/network/socket/socket_connector.dart';
import 'package:vehicles_saver_partner/network/socket/socket_error.dart';
import 'package:vehicles_saver_partner/network/socket/socket_event.dart';

class DemandBloc extends ChangeNotifier {
  Demand currentDemand;
  List<Demand> demandHistory = [];

  List<Demand> availableDemands = [];

  Function onUpdateListDemand = (data) => print("onUpdateListDemand: $data");

  SocketConnector socket;

  bool initSocketConnect = false;

  DemandBloc(){
    socket = SocketConnector.getInstance();
    socket.listenLoginSuccess(onLoginSuccess);
    socket.listenUpdateCurrentDemand(updateCurrentDemand);
    socket.listenUpdateListDemand(updateListDemand);
  }

  listenUpdateListDemand(Function listener){
    this.onUpdateListDemand = listener;
  }

  void onLoginSuccess (data){
    try {
        if (data["currentDemand"] != null) {
          print('data["currentDemand"] = ${data["currentDemand"]}');
          this.currentDemand = Demand.fromJson(data["currentDemand"]);
        }
        if (data["history"] != null){
          print('onLoginSuccess data["history"] = ${data["history"]}');

          var list = <Demand>[];
          for (Map demand in data["history"]) {
            list.add(Demand.fromJson(demand));
          }
          this.demandHistory = list;
        }
      } catch (e) {
        print("onLoginSuccess exception: $e");

        this.currentDemand = null;
        this.demandHistory = [];
      }
    print("onLoginSuccess currentDemand ${this.currentDemand}");
    print("onLoginSuccess history ${this.demandHistory}");
  }

  void updateCurrentDemand(data) {
    if (data["errorCode"] != SocketError.SUCCESS) return;
    if (data["body"] != null) {
      try {
        this.currentDemand = Demand.fromJson(data["body"]);
      } catch (e) {
        print("updateCurrentDemand exception: $e");
      }
    } else {
      this.currentDemand = null;
    }
    if(currentDemand.status == DemandStatus.COMPLETED || currentDemand.status == DemandStatus.CANCELED){
      this.demandHistory.add(this.currentDemand);
      this.currentDemand = null;
    }
    print("updateCurrentDemand ${this.currentDemand}");

    notifyListeners();
  }

  void updateListDemand(data) async{
    print("updateListDemand 1 $data");
    if (data["errorCode"] != SocketError.SUCCESS) return;
    if (data["body"] != null) {
      try {
        var list = <Demand>[];
        for (Map demand in data["body"]) {
          list.add(Demand.fromJson(demand));
        }
        this.availableDemands = list;
      } catch (e) {
        print("updateListDemand exception: $e");
      }
    } else {
      this.availableDemands = [];
    }
    print("updateListDemand 2 ${this.availableDemands}");
    await onUpdateListDemand();
    notifyListeners();
  }

  bool isHavingDemand() {
    return currentDemand != null;
  }

  void fetchListDemand(double latitude, double longitude, range, Function callback) {
    Map req = {"latitude": latitude, "longitude": longitude, "range": range};
    print("fetchListDemand: $req");
    this.onUpdateListDemand = callback;
    socket.fetchListDemand(req);
  }

  void acceptDemand(String id, Function onSuccess, Function onError) {
    print("acceptDemand ");
    socket.acceptDemand(id, (data) {
      print("acceptDemand successsss");
      try {
        onSuccess();
        updateCurrentDemand(data);
      } catch (e) {
        onError(e);
      }
    }, (msg) {
      print("acceptDemand error: $msg");
      onError(msg);
    });
  }
  void sendMessage (String text, Function onSuccess, Function onError) {
    socket.sendMessage(text, () {
      print("sendMessage:");
      onSuccess();
    }, (msg) {
      print("create demand error: $msg");
      onError.call(msg);
    });
  }

  invoice(List<BillItem> billItems, Function onSuccess, Function onError) {
    socket.invoice(billItems, (data) {
      print("invoice success: $data");
      try {
        onSuccess();
        updateCurrentDemand(data);
      } catch (e) {
        onError(e);
      }
    }, (msg) {
      print("acceptDemand error: $msg");
      onError(msg);
    });
  }

  bool isStatus(DemandStatus status) {
    return isHavingDemand() && currentDemand.status == status;
  }

  cleanUp() {
    this.currentDemand = null;
    this.demandHistory = [];
  }
}
