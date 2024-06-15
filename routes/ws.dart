import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:rps/enums/rps_enums.dart';
import 'package:rps/models/join_user_request_model.dart';
import 'package:rps/models/player_input_request_model.dart';

Map<String, JoinUserRequestModel> players = {};

// JoinUserRequestModel selectWinner({
//   required JoinUserRequestModel player1,
//   required JoinUserRequestModel player2,
// }) {
//   if (player1.input == RPSEnum.rock && player2.input == RPSEnum.scissors) {
//     return player1;
//   }

//   if (player1.input == RPSEnum.scissors && player2.input == RPSEnum.paper) {
//     return player1;
//   }

//   if (player1.input == RPSEnum.paper && player2.input == RPSEnum.rock) {
//     return player1;
//   }

//   return player2;
// }

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
    final id = context.request.uri.queryParameters['id'] ?? '';
    final name = context.request.uri.queryParameters['name'] ?? '';

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
          var player = players[id]!;
          player = player.copyWith(input: playerInput.input);
          players[id] = player;

          final opponent = findOpponent(id);

          // if (player1.input == player2.input) {
          //   sendMessage(
          //     channel: player1.channel!,
          //     status: true,
          //     message: 'Tie againts ${player1.name}',
          //     type: WSResponseEnum.result,
          //   );
          //   sendMessage(
          //     channel: player2.channel!,
          //     status: true,
          //     message: 'Tie againts ${player2.name}',
          //     type: WSResponseEnum.result,
          //   );
          // } else {
          //   final winner = selectWinner(player1: player1, player2: player2);
          //   if (winner.hashcode == player1.hashcode) {
          //     sendMessage(
          //       channel: player1.channel!,
          //       status: true,
          //       message: 'You won. againts ${player2.name}',
          //       type: WSResponseEnum.result,
          //     );
          //     sendMessage(
          //       channel: player2.channel!,
          //       status: true,
          //       message: 'You lost. againts ${player1.name}',
          //       type: WSResponseEnum.result,
          //     );
          //   } else {
          //     sendMessage(
          //       channel: player1.channel!,
          //       status: true,
          //       message: 'You lost. againts ${player2.name}',
          //       type: WSResponseEnum.result,
          //     );
          //     sendMessage(
          //       channel: player2.channel!,
          //       status: true,
          //       message: 'You won. againts ${player1.name}',
          //       type: WSResponseEnum.result,
          //     );
          //   }
          // }

          // player1.channel!.sink.close();
          // player2.channel!.sink.close();
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
      },
      onError: (error) {},
    );
  });
  return handler(context);
}
