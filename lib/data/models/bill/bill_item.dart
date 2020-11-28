
import 'package:json_annotation/json_annotation.dart';

part 'bill_item.g.dart';
@JsonSerializable(nullable: true)
class BillItem{
  String service;
  double cost;

  BillItem(this.service, this.cost);

  factory BillItem.fromJson(Map<String, dynamic> json) =>
      _$BillItemFromJson(json);

  Map<String, dynamic> toJson() => _$BillItemToJson(this);

  @override
  String toString() {
    return 'BillItem{service: $service, cost: $cost}';
  }
}