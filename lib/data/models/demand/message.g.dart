// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) {
  return Message()
    ..content = json['content'] as String
    ..userId = json['userId'] as String
    ..time =
        json['time'] == null ? null : DateTime.fromMillisecondsSinceEpoch(json['time'] as int);
}

Map<String, dynamic> _$MessageToJson(Message instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('content', instance.content);
  writeNotNull('userId', instance.userId);
  writeNotNull('time', instance.time?.toIso8601String());
  return val;
}
