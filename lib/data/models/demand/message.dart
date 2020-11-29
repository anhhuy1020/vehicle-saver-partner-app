import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';
@JsonSerializable(nullable: true, includeIfNull: false)
class Message {
  String content;
  String userId;
  DateTime time;

  Message();

  String parseTime(){
    DateFormat formatter;
    if(time != null){
      DateTime now = DateTime.now();
      if(now.year == time.year){
        if(now.day == time.day){
          formatter = DateFormat('HH:mm');
        } else {
          formatter = DateFormat('HH:mm dd-MM');
        }
      } else {
        formatter = DateFormat('HH:mm dd-MM-yyyy');
      }
    }
    if(formatter != null){
      return formatter.format(time);
    }
    return "Unknown";
  }


  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  @override
  String toString() {
    return 'Message{content: $content, userId: $userId}';
  }
}