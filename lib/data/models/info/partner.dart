import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'partner.g.dart';

@JsonSerializable(nullable: false)
class Partner extends ChangeNotifier {
  @JsonKey(name: '_id')
  String id;
  String name;
  String email;
  String phone;
  String address;
  String token;


  Partner(
      {this.id,
        this.name,
        this.email,
        this.token,
        this.phone,
        this.address});

  factory Partner.fromJson(Map<String, dynamic> json) => _$PartnerFromJson(json);
  Map<String, dynamic> toJson() => _$PartnerToJson(this);

  @override
  String toString() {
    return 'Customer{_id: $id, name: $name, email: $email, phone: $phone, address: $address, token: $token}';
  }
}