import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:rps/enums/rps_enums.dart';
import 'package:rps/models/join_user_request_model.dart';
import 'package:rps/models/player_input_request_model.dart';

Map<String, JoinUserRequestModel> players = {};

JoinUserRequestModel selectWinner({
  required JoinUserRequestModel player1,
  required JoinUserRequestModel player2,
}) {
  if (player1.input == RPSInputEnum.rock &&
      player2.input == RPSInputEnum.scissors) {
    return player1;
  }

  if (player1.input == RPSInputEnum.scissors &&
      player2.input == RPSInputEnum.paper) {
    return player1;
  }

  if (player1.input == RPSInputEnum.paper &&
      player2.input == RPSInputEnum.rock) {
    return player1;
  }

  return player2;
}

void sendMessage({
  required bool status,
  required String message,
  required WebSocketChannel channel,
  required WSResponseEnum type,
}) {
  final response = {
    'status': status,
    'message': message,
    'type': type.value,
  };
  channel.sink.add(jsonEncode(response));
}

void sendUserCounts() {
  for (final user in players.values.toList()) {
    sendMessage(
      channel: user.channel,
      status: true,
      message: 'Connected ${players.length}',
      type: WSResponseEnum.playerCount,
    );
  }
}

JoinUserRequestModel? findOpponent(String id) {
  for (final user in players.values.toList()) {
    if (user.id != id && user.input != null) {
      return user;
    }
  }
  return null;
}

Future<Response> onRequest(RequestContext context) async {
  final handler = webSocketHandler((channel, protocol) {
    // final id = context.request.uri.queryParameters['id'] ?? '';
    final name = context.request.uri.queryParameters['name'] ?? '';
    final id = channel.hashCode.toString();

    print("id $id");

    if (name.isEmpty) {
      sendMessage(
        channel: channel,
        status: false,
        message: 'name is required in query parameters.',
        type: WSResponseEnum.error,
      );
      channel.sink.close();
      return;
    }

    if (players.containsKey(id)) {
      sendMessage(
        channel: channel,
        status: false,
        message: 'id already exists. Please use a different id.',
        type: WSResponseEnum.error,
      );
      channel.sink.close();
      return;
    }

    final user = JoinUserRequestModel(
      id: id,
      name: name,
      channel: channel,
    );
    players[id] = user;
    sendUserCounts();

    channel.stream.listen(
      (message) {
        try {
          final playerInput = playerInputRequestModelFromJson(message);
          var player1 = players[id]!;
          player1 = player1.copyWith(input: playerInput.input);
          players[id] = player1;

          final player2 = findOpponent(id);

          if (player2 == null) return;

          if (player1.input == player2.input) {
            sendMessage(
              channel: player1.channel,
              status: true,
              message: 'Tie againts ${player2.name}',
              type: WSResponseEnum.result,
            );
            sendMessage(
              channel: player2.channel,
              status: true,
              message: 'Tie againts ${player1.name}',
              type: WSResponseEnum.result,
            );
          } else {
            final winner = selectWinner(player1: player1, player2: player2);
            if (winner.id == player1.id) {
              sendMessage(
                channel: player1.channel,
                status: true,
                message: 'You won. againts ${player2.name}',
                type: WSResponseEnum.result,
              );
              sendMessage(
                channel: player2.channel,
                status: true,
                message: 'You lost. againts ${player1.name}',
                type: WSResponseEnum.result,
              );
            } else {
              sendMessage(
                channel: player1.channel,
                status: true,
                message: 'You lost. againts ${player2.name}',
                type: WSResponseEnum.result,
              );
              sendMessage(
                channel: player2.channel,
                status: true,
                message: 'You won. againts ${player1.name}',
                type: WSResponseEnum.result,
              );
            }
          }

          ///reseting inputs
          final player1Reset = JoinUserRequestModel(
            id: player1.id,
            name: player1.name,
            channel: player1.channel,
          );
          players[player1.id] = player1Reset;
          // print('player1Reset: ${players[player1Reset.id]?.toJson()}');

          final player2Reset = JoinUserRequestModel(
            id: player2.id,
            name: player2.name,
            channel: player2.channel,
          );
          players[player2.id] = player2Reset;
          // print('player2Reset: ${players[player2Reset.id]?.toJson()}');
        } catch (e) {
          sendMessage(
            channel: channel,
            status: false,
            message: 'Invalid data. Please send a valid JSON object.',
            type: WSResponseEnum.error,
          );
        }
      },
      onDone: () {
        players.remove(id);
        sendUserCounts();
        print("onDone ${id}");
      },
      onError: (error) {
        print("onError ${error.toString()}");
      },
    );
  });
  return handler(context);
}
