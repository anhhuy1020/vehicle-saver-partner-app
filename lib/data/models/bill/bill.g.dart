// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bill _$BillFromJson(Map<String, dynamic> json) {
  return Bill()
    ..items = (json['items'] as List)
        ?.map((e) =>
            e == null ? null : BillItem.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..fee = (json['fee'] as num)?.toDouble();
}

Map<String, dynamic> _$BillToJson(Bill instance) => <String, dynamic>{
      'items': instance.items,
      'fee': instance.fee,
    };
