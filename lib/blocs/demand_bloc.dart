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

  SocketConnector socket;

  bool initSocketConnect = false;

  DemandBloc(){
    socket = SocketConnector.getInstance();
    socket.listenLoginSuccess(onLoginSuccess);
    socket.listenUpdateCurrentDemand(updateCurrentDemand);
    socket.listenUpdateListDemand(updateListDemand);
  }

  void onLoginSuccess (data){
    try {
        if (data["currentDemand"] != null) {
          print('data["currentDemand"] = ${data["currentDemand"]}');
          this.currentDemand = Demand.fromJson(data["currentDemand"]);
        }
        if (data["demandHistory"] != null){
          print('data["demandHistory"] = ${data["demandHistory"]}');

          var list = <Demand>[];
          for (Map demand in data["demandHistory"]) {
            list.add(Demand.fromJson(demand));
          }
          this.demandHistory = list;
        }
      } catch (e) {
        print("updateCurrentDemand exception: $e");

        this.currentDemand = null;
        this.demandHistory = [];
      }
    print("updateCurrentDemand end ${this.currentDemand}");
    print("updateCurrentDemand end ${this.demandHistory}");
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

  void updateListDemand(data) {
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

    notifyListeners();
  }

  bool isHavingDemand() {
    return currentDemand != null;
  }

  void fetchListDemand(double latitude, double longitude) {
    Map req = {"latitude": latitude, "longitude": longitude};
    print("fetchListDemand: $req");
    socket.fetchListDemand(req);
  }

  void acceptDemand(String id, Function onSuccess, Function onError) {
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
