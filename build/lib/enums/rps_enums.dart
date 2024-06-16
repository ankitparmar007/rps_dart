enum RPSInputEnum {
  rock('Rock', 1),
  paper('Paper', 2),
  scissors('Scissors', 3);

  const RPSInputEnum(this.name, this.value);
  final String name;
  final int value;
}

enum WSResponseEnum {
  playerCount('Player Count', 1),
  result('Result', 2),
  error('Error', 3);

  const WSResponseEnum(this.name, this.value);
  final String name;
  final int value;
}
