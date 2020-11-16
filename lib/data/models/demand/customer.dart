import 'package:json_annotation/json_annotation.dart';

part 'customer.g.dart';
@JsonSerializable(nullable: false)
class Customer {
  @JsonKey(name: '_id')
  String id;
  String name;
  String email;
  String phone;
  String avatarUrl;

  Customer();

  static Customer fakeCustomer(  String id, String name, String email, String phone, String avatarUrl){
    return Customer()
      ..id = id
      ..name = name
      ..email = email
      ..phone = phone
      .. avatarUrl = avatarUrl
    ;
  }
  
  factory Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerToJson(this);
}