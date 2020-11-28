import 'package:json_annotation/json_annotation.dart';
import 'package:vehicles_saver_partner/data/models/bill/bill_item.dart';

part 'bill.g.dart';
@JsonSerializable(nullable: true)
class Bill {
  List<BillItem> items = [];
  double fee = 0.0;

  Bill();

  double calTotalCost(){
    double total = 0;
    for (int i = 0; i< items.length; i++){
      total += items[i].cost;
    }
    return total;
  }

  factory Bill.fromJson(Map<String, dynamic> json) =>
      _$BillFromJson(json);

  Map<String, dynamic> toJson() => _$BillToJson(this);

  @override
  String toString() {
    return 'Bill{items: $items, fee: $fee}';
  }
}