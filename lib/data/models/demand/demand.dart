import 'package:json_annotation/json_annotation.dart';
import 'package:vehicles_saver_partner/data/models/map/place_model.dart';

import 'customer.dart';

part'demand.g.dart';

@JsonSerializable(nullable: false, includeIfNull: false)
class Demand{
  String id;
  String vehicleType;
  String addressDetail;
  String problemDescription;
  Customer customer;
  Place pickupLocation;
  DemandStatus status;

  Demand();

  factory Demand.fromJson(Map<String, dynamic> json) => _$DemandFromJson(json);
  Map<String, dynamic> toJson() => _$DemandToJson(this);


}


enum DemandStatus {
  SEARCHING_PARTNER,
  HANDLING,
  PAYING,
  COMPLETED,
  CANCELED
}