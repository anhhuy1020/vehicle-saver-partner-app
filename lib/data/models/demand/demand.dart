import 'package:json_annotation/json_annotation.dart';
import 'package:vehicles_saver_partner/data/models/bill/bill.dart';
import 'package:vehicles_saver_partner/data/models/demand/message.dart';
import 'package:vehicles_saver_partner/data/models/map/place_model.dart';

import 'customer.dart';

part'demand.g.dart';

@JsonSerializable(nullable: true, includeIfNull: false)
class Demand{
  @JsonKey(name: "_id")
  String id;
  String vehicleType;
  String addressDetail;
  String problemDescription;
  Customer customer;
  double pickupLatitude;
  double pickupLongitude;
  DemandStatus status;
  List<Message> messages = [];
  Bill bill;
  DateTime createdDate;
  DateTime completedDate;

  Demand();

  double calTotalCost(){
    if(bill == null){
      return 0;
    }
    double total = 0;
    for (int i = 0; i< bill.items.length; i++){
      total += bill.items[i].cost;
    }
    total += bill.fee;
    return total;
  }

  factory Demand.fromJson(Map<String, dynamic> json) => _$DemandFromJson(json);
  Map<String, dynamic> toJson() => _$DemandToJson(this);

  @override
  String toString() {
    return 'Demand{id: $id, vehicleType: $vehicleType, addressDetail: $addressDetail, problemDescription: $problemDescription, customer: $customer, pickupLatitude: $pickupLatitude, pickupLongitude: $pickupLongitude, status: $status, messages: $messages, bill: $bill, createdDate: $createdDate, completedDate: $completedDate}';
  }
}


enum DemandStatus {
  SEARCHING_PARTNER,
  HANDLING,
  PAYING,
  COMPLETED,
  CANCELED
}