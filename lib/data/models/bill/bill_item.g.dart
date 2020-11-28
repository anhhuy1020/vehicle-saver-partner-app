// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillItem _$BillItemFromJson(Map<String, dynamic> json) {
  return BillItem(
    json['service'] as String,
    (json['cost'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$BillItemToJson(BillItem instance) => <String, dynamic>{
      'service': instance.service,
      'cost': instance.cost,
    };
