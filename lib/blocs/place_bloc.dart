import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:vehicles_saver_partner/config.dart';
import 'package:vehicles_saver_partner/data/models/map/place_model.dart';

class PlaceBloc with ChangeNotifier {
  StreamController<Place> locationController = StreamController<Place>.broadcast();
  Place pickupLocation;
  Place partnerLocation;
  List<Place> listPlace;

  Stream get placeStream => locationController.stream;

  Future<List<Place>> search(String query) async {
    String url = "https://maps.googleapis.com/maps/api/place/textsearch/json?key=${Config.API_KEY}&language=${Config.LANGUAGE}&region=${Config.REGION}&query="+Uri.encodeQueryComponent(query);//Uri.encodeQueryComponent(query)
    print(url);
    Response response = await Dio().get(url);
    print(Place.parseLocationList(response.data));
    listPlace = Place.parseLocationList(response.data);
    notifyListeners();
    return listPlace;
  }

  void locationSelected(Place location) {
    locationController.sink.add(location);
  }

  Future<void> selectLocation(Place location) async {
    notifyListeners();
    pickupLocation = location;
  }

  Future<void> getCurrentLocation() async {
    return pickupLocation;
  }

  Future<void> updatePartnerLocation(Place location) async {
    notifyListeners();
    partnerLocation = location;
  }

  Future<void> getPartnerLocation() async {
    return partnerLocation;
  }

  @override
  void dispose() {
    locationController.close();
    super.dispose();
  }
}