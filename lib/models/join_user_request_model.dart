// To parse this JSON data, do
//
//     final joinUserRequestModel = joinUserRequestModelFromJson(jsonString);

import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

import '../enums/rps_enums.dart';

JoinUserRequestModel joinUserRequestModelFromJson(String str) =>
    JoinUserRequestModel.fromJson(json.decode(str));

String joinUserRequestModelToJson(JoinUserRequestModel data) =>
    json.encode(data.toJson());

class JoinUserRequestModel {
  final String id;
  final String name;
  final RPSEnum input;
  final WebSocketChannel? channel;
  final String? hashcode;

  JoinUserRequestModel({
    required this.id,
    required this.name,
    required this.input,
     this.channel,
    this.hashcode,
  });

  factory JoinUserRequestModel.fromJson(Map<String, dynamic> json) =>
      JoinUserRequestModel(
        id: json['id'],
        name: json['name'],
        input: RPSEnum.values
            .firstWhere((element) => element.value == json['input']),
        channel: json['channel'],
        hashcode: json['hashcode'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'input': input,
        'channel': channel,
        'hashcode': hashcode,
      };

  JoinUserRequestModel copyWith({
    String? id,
    String? name,
    RPSEnum? input,
    WebSocketChannel? channel,
    String? hashcode,
  }) =>
      JoinUserRequestModel(
        id: id ?? this.id,
        name: name ?? this.name,
        input: input ?? this.input,
        channel: channel ?? this.channel,
        hashcode: hashcode ?? this.hashcode,
      );
}
