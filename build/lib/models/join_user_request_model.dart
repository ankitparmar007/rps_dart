// To parse this JSON data, do
//
//     final joinUserRequestModel = joinUserRequestModelFromJson(jsonString);

import 'dart:convert';

import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:rps/enums/rps_enums.dart';

JoinUserRequestModel joinUserRequestModelFromJson(String str) =>
    JoinUserRequestModel.fromJson(json.decode(str));

String joinUserRequestModelToJson(JoinUserRequestModel data) =>
    json.encode(data.toJson());

class JoinUserRequestModel {
  final String id;
  final String name;
  final WebSocketChannel channel;
  final RPSInputEnum? input;
  JoinUserRequestModel({
    required this.id,
    required this.name,
    required this.channel,
    this.input,
  });

  factory JoinUserRequestModel.fromJson(Map<String, dynamic> json) =>
      JoinUserRequestModel(
        id: json['id'],
        name: json['name'],
        channel: json['channel'],
        input: json['input'] == null
            ? null
            : RPSInputEnum.values
                .firstWhere((element) => element.value == json['input']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'channel': channel,
        'input': input?.value,
      };

  JoinUserRequestModel copyWith({
    String? name,
    WebSocketChannel? channel,
    String? id,
    RPSInputEnum? input,
  }) =>
      JoinUserRequestModel(
        name: name ?? this.name,
        channel: channel ?? this.channel,
        id: id ?? this.id,
        input: input ?? this.input,
      );
}
