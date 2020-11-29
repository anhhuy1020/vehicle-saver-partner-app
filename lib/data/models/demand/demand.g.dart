// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'demand.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Demand _$DemandFromJson(Map<String, dynamic> json) {
  return Demand()
    ..id = json['_id'] as String
    ..vehicleType = json['vehicleType'] as String
    ..addressDetail = json['addressDetail'] as String
    ..problemDescription = json['problemDescription'] as String
    ..customer = json['customer'] == null
        ? null
        : Customer.fromJson(json['customer'] as Map<String, dynamic>)
    ..pickupLatitude = (json['pickupLatitude'] as num)?.toDouble()
    ..pickupLongitude = (json['pickupLongitude'] as num)?.toDouble()
    ..status = _$enumDecodeNullable(_$DemandStatusEnumMap, json['status'])
    ..messages = (json['messages'] as List)
        ?.map((e) =>
            e == null ? null : Message.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..bill = json['bill'] == null
        ? null
        : Bill.fromJson(json['bill'] as Map<String, dynamic>);
}

Map<String, dynamic> _$DemandToJson(Demand instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('_id', instance.id);
  writeNotNull('vehicleType', instance.vehicleType);
  writeNotNull('addressDetail', instance.addressDetail);
  writeNotNull('problemDescription', instance.problemDescription);
  writeNotNull('customer', instance.customer);
  writeNotNull('pickupLatitude', instance.pickupLatitude);
  writeNotNull('pickupLongitude', instance.pickupLongitude);
  writeNotNull('status', _$DemandStatusEnumMap[instance.status]);
  writeNotNull('messages', instance.messages);
  writeNotNull('bill', instance.bill);
  return val;
}

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$DemandStatusEnumMap = {
  DemandStatus.SEARCHING_PARTNER: 'SEARCHING_PARTNER',
  DemandStatus.HANDLING: 'HANDLING',
  DemandStatus.PAYING: 'PAYING',
  DemandStatus.COMPLETED: 'COMPLETED',
  DemandStatus.CANCELED: 'CANCELED',
};
