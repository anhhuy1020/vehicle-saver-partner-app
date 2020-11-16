// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'demand.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Demand _$DemandFromJson(Map<String, dynamic> json) {
  return Demand()
    ..id = json['id'] as String
    ..vehicleType = json['vehicleType'] as String
    ..addressDetail = json['addressDetail'] as String
    ..problemDescription = json['problemDescription'] as String
    ..customer = Customer.fromJson(json['customer'] as Map<String, dynamic>)
    ..pickupLocation =
        Place.fromJson(json['pickupLocation'] as Map<String, dynamic>)
    ..status = _$enumDecode(_$DemandStatusEnumMap, json['status']);
}

Map<String, dynamic> _$DemandToJson(Demand instance) => <String, dynamic>{
      'id': instance.id,
      'vehicleType': instance.vehicleType,
      'addressDetail': instance.addressDetail,
      'problemDescription': instance.problemDescription,
      'customer': instance.customer,
      'pickupLocation': instance.pickupLocation,
      'status': _$DemandStatusEnumMap[instance.status],
    };

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

const _$DemandStatusEnumMap = {
  DemandStatus.SEARCHING_PARTNER: 'FINDING_PARTNER',
  DemandStatus.HANDLING: 'HANDLING',
  DemandStatus.PAYING: 'PAYING',
  DemandStatus.COMPLETED: 'COMPLETED',
};
