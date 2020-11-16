
import 'package:json_annotation/json_annotation.dart';

part 'user_login.g.dart';
@JsonSerializable(nullable: false)
class UserLogin{
  String email;
  String password;

  UserLogin();

  factory UserLogin.fromJson(Map<String, dynamic> json) => _$UserLoginFromJson(json);
  Map<String, dynamic> toJson() => _$UserLoginToJson(this);

}