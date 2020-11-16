import 'package:flutter/cupertino.dart';
import 'package:vehicles_saver_partner/data/models/demand/customer.dart';
import 'package:vehicles_saver_partner/data/models/demand/demand.dart';
import 'package:vehicles_saver_partner/data/models/map/place_model.dart';
import 'package:vehicles_saver_partner/network/socket/socket_connector.dart';
import 'package:vehicles_saver_partner/network/socket/socket_event.dart';
class DemandBloc extends ChangeNotifier{
  Demand currentDemand;
  List<Demand> demandHistory = <Demand>[
      Demand()
      ..id = "1"
      ..customer=Customer.fakeCustomer("1", "11", "111@111.111", "111111111", "https://source.unsplash.com/300x300/?portrait")
      ..vehicleType="11"
      ..addressDetail="a"
      ..problemDescription="âa"
      ..status = DemandStatus.SEARCHING_PARTNER
      ..pickupLocation = Place(name: "aaa", formattedAddress: "aaaaaa aa aaaa", lat: 39.170655, lng:-95.449974),
     Demand()
      ..id = "2"
       ..customer=Customer.fakeCustomer("2", "22", "222@222.222", "222222222", "https://source.unsplash.com/300x300/?portrait")
      ..vehicleType="22"
      ..addressDetail="b"
      ..problemDescription="âb"
      ..status = DemandStatus.SEARCHING_PARTNER
      ..pickupLocation = Place(name: "bbb", formattedAddress: "bbbbbb bb bbbb", lat: 39.165576, lng: -95.457672),
     Demand()
      ..id = "3"
       ..customer=Customer.fakeCustomer("3", "33", "333@333.333", "333333333", "https://source.unsplash.com/300x300/?portrait")
      ..vehicleType="33"
      ..addressDetail="c"
      ..problemDescription="âc"
      ..status = DemandStatus.SEARCHING_PARTNER
      ..pickupLocation = Place(name: "ccc", formattedAddress: "cccccc cc cccc", lat: 39.155726, lng: -95.429189),
     Demand()
      ..id = "4"
       ..customer=Customer.fakeCustomer("4", "44", "444@444.444", "444444444", "https://source.unsplash.com/300x300/?portrait")
      ..vehicleType="44"
      ..addressDetail="d"
      ..problemDescription="dd"
      ..status = DemandStatus.SEARCHING_PARTNER
      ..pickupLocation = Place(name: "ddd", formattedAddress: "dddd dddd ddd ddd ddddd dddd dddd", lat: 39.183142, lng: -95.438454),
     Demand()
      ..id = "5"
       ..customer=Customer.fakeCustomer("5", "55", "555@555.555", "555555555", "https://source.unsplash.com/300x300/?portrait")
      ..vehicleType="55"
      ..addressDetail="e"
      ..problemDescription="ee"
      ..status = DemandStatus.SEARCHING_PARTNER
      ..pickupLocation = Place(name: "eee", formattedAddress: "eeee eeee eee eee eeeee eeee eeee", lat: 39.153597, lng: -95.385606),
     Demand()
      ..id = "6"
       ..customer=Customer.fakeCustomer("6", "66", "666@666.666", "666666666", "https://source.unsplash.com/300x300/?portrait")
      ..vehicleType="66"
      ..addressDetail="z"
      ..problemDescription="zz"
      ..status = DemandStatus.SEARCHING_PARTNER
      ..pickupLocation = Place(name: "zzz", formattedAddress: "zzzz zzzz zzz zzz zzzzz zzzz zzzz", lat: 39.179682, lng: -95.606882),
    Demand()
      ..id = "7"
      ..customer=Customer.fakeCustomer("7", "77", "777@777.777", "777777777", "https://source.unsplash.com/300x300/?portrait")
      ..vehicleType="77"
      ..addressDetail="x"
      ..problemDescription="xx"
      ..status = DemandStatus.SEARCHING_PARTNER
      ..pickupLocation = Place(name: "xxx", formattedAddress: "xxxx xxxx xxx xxx xxxxx xxxx xxxx", lat: 39.150934, lng: -95.524604),
  ];
  
  List<Demand> availableDemands = <Demand>[
      Demand()
      ..id = "1"
      ..customer=Customer.fakeCustomer("1", "11", "111@111.111", "111111111", "https://source.unsplash.com/300x300/?portrait")
      ..vehicleType="11"
      ..addressDetail="a"
      ..problemDescription="âa"
      ..status = DemandStatus.SEARCHING_PARTNER
      ..pickupLocation = Place(name: "aaa", formattedAddress: "aaaaaa aa aaaa", lat: 39.170655, lng:-95.449974),
     Demand()
      ..id = "2"
       ..customer=Customer.fakeCustomer("2", "22", "222@222.222", "222222222", "https://source.unsplash.com/300x300/?portrait")
      ..vehicleType="22"
      ..addressDetail="b"
      ..problemDescription="âb"
      ..status = DemandStatus.SEARCHING_PARTNER
      ..pickupLocation = Place(name: "bbb", formattedAddress: "bbbbbb bb bbbb", lat: 39.165576, lng: -95.457672),
     Demand()
      ..id = "3"
       ..customer=Customer.fakeCustomer("3", "33", "333@333.333", "333333333", "https://source.unsplash.com/300x300/?portrait")
      ..vehicleType="33"
      ..addressDetail="c"
      ..problemDescription="âc"
      ..status = DemandStatus.SEARCHING_PARTNER
      ..pickupLocation = Place(name: "ccc", formattedAddress: "cccccc cc cccc", lat: 39.155726, lng: -95.429189),
     Demand()
      ..id = "4"
       ..customer=Customer.fakeCustomer("4", "44", "444@444.444", "444444444", "https://source.unsplash.com/300x300/?portrait")
      ..vehicleType="44"
      ..addressDetail="d"
      ..problemDescription="dd"
      ..status = DemandStatus.SEARCHING_PARTNER
      ..pickupLocation = Place(name: "ddd", formattedAddress: "dddd dddd ddd ddd ddddd dddd dddd", lat: 39.183142, lng: -95.438454),
     Demand()
      ..id = "5"
       ..customer=Customer.fakeCustomer("5", "55", "555@555.555", "555555555", "https://source.unsplash.com/300x300/?portrait")
      ..vehicleType="55"
      ..addressDetail="e"
      ..problemDescription="ee"
      ..status = DemandStatus.SEARCHING_PARTNER
      ..pickupLocation = Place(name: "eee", formattedAddress: "eeee eeee eee eee eeeee eeee eeee", lat: 39.153597, lng: -95.385606),
     Demand()
      ..id = "6"
       ..customer=Customer.fakeCustomer("6", "66", "666@666.666", "666666666", "https://source.unsplash.com/300x300/?portrait")
      ..vehicleType="66"
      ..addressDetail="z"
      ..problemDescription="zz"
      ..status = DemandStatus.SEARCHING_PARTNER
      ..pickupLocation = Place(name: "zzz", formattedAddress: "zzzz zzzz zzz zzz zzzzz zzzz zzzz", lat: 39.179682, lng: -95.606882),
    Demand()
      ..id = "7"
      ..customer=Customer.fakeCustomer("7", "77", "777@777.777", "777777777", "https://source.unsplash.com/300x300/?portrait")
      ..vehicleType="77"
      ..addressDetail="x"
      ..problemDescription="xx"
      ..status = DemandStatus.SEARCHING_PARTNER
      ..pickupLocation = Place(name: "xxx", formattedAddress: "xxxx xxxx xxx xxx xxxxx xxxx xxxx", lat: 39.150934, lng: -95.524604),
  ];
  
  SocketConnector socket;

  DemandBloc();

  onConnectServer(SocketConnector socket){
    this.socket = socket;
    socket.addServerListener(SocketEvent.UPDATE_CURRENT_DEMAND, updateCurrentDemand);

  }

  updateCurrentDemand(Map data){
    Map currentDemand = data["currentDemand"];
    if(currentDemand != null) {
      this.currentDemand = Demand.fromJson(currentDemand);
    } else{
      this.currentDemand = null;
    }
    notifyListeners();
  }

  bool isHavingDemand(){
    return currentDemand != null;
  }


}