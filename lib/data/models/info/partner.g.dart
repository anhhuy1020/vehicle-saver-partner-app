// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Partner _$PartnerFromJson(Map<String, dynamic> json) {
  return Partner(
    id: json['_id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    avatarUrl: json['avatarUrl'] as String,
    address: json['address'] as String,
  )
    ..rating = (json['rating'] as num).toDouble()
    ..nRating = json['nRating'] as int;
}

Map<String, dynamic> _$PartnerToJson(Partner instance) => <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'address': instance.address,
      'avatarUrl': instance.avatarUrl,
      'rating': instance.rating,
      'nRating': instance.nRating,
    };
