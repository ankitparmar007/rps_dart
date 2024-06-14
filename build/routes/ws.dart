import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:rps/enums/rps_enums.dart';
import 'package:rps/models/join_user_request_model.dart';

List<JoinUserRequestModel> users = [];

JoinUserRequestModel selectWinner({
  required JoinUserRequestModel player1,
  required JoinUserRequestModel player2,
}) {
  if (player1.input == RPSEnum.rock && player2.input == RPSEnum.scissors) {
    return player1;
  }

  if (player1.input == RPSEnum.scissors && player2.input == RPSEnum.paper) {
    return player1;
  }

  if (player1.input == RPSEnum.paper && player2.input == RPSEnum.rock) {
    return player1;
  }

  return player2;
}

void sendMessage({
  required bool status,
  required String message,
  required WebSocketChannel channel,
}) {
  final response = {
    'status': status,
    'message': message,
  };
  channel.sink.add(jsonEncode(response));
}

Future<Response> onRequest(RequestContext context) async {
  final handler = webSocketHandler((channel, protocol) {
    final hashCode = channel.hashCode.toString();

    channel.stream.listen(
      (message) {
        try {
          var player1 = joinUserRequestModelFromJson(message);
          player1 = player1.copyWith(hashcode: hashCode, channel: channel);

          users.add(player1);

          if (users.length < 2) return;

          final player2 = users.first;
          users.removeWhere((element) => element.id == player2.id);

          if (player1.input == player2.input) {
            sendMessage(
              channel: player1.channel!,
              status: true,
              message: 'Tie againts ${player1.name}',
            );
            sendMessage(
              channel: player2.channel!,
              status: true,
              message: 'Tie againts ${player2.name}',
            );
          } else {
            final winner = selectWinner(player1: player1, player2: player2);
            if (winner.id == player1.id) {
              sendMessage(
                channel: player1.channel!,
                status: true,
                message: 'You won. againts ${player2.name}',
              );
              sendMessage(
                channel: player2.channel!,
                status: true,
                message: 'You lost. againts ${player1.name}',
              );
            } else {
              sendMessage(
                channel: player1.channel!,
                status: true,
                message: 'You lost. againts ${player2.name}',
              );
              sendMessage(
                channel: player2.channel!,
                status: true,
                message: 'You won. againts ${player1.name}',
              );
            }
          }

          player1.channel!.sink.close();
          player2.channel!.sink.close();
        } catch (e) {
          sendMessage(
            channel: channel,
            status: false,
            message: 'Invalid data. Please send a valid JSON object.',
          );
        }
      },
      onDone: () {
        users.removeWhere((element) => element.hashcode == hashCode);
      },
    );
  });
  return handler(context);
}
