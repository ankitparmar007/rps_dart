// To parse this JSON data, do
//
//     final joinUserRequestModel = joinUserRequestModelFromJson(jsonString);

import 'dart:convert';

import 'package:rps/enums/rps_enums.dart';

PlayerInputRequestModel playerInputRequestModelFromJson(String str) =>
    PlayerInputRequestModel.fromJson(json.decode(str));

String playerInputRequestModelToJson(PlayerInputRequestModel data) =>
    json.encode(data.toJson());

class PlayerInputRequestModel {
  final RPSInputEnum input;

  PlayerInputRequestModel({
    required this.input,
  });

  factory PlayerInputRequestModel.fromJson(Map<String, dynamic> json) =>
      PlayerInputRequestModel(
        input: RPSInputEnum.values
            .firstWhere((element) => element.value == json['input']),
      );

  Map<String, dynamic> toJson() => {
        'input': input.value,
      };
}
