enum RPSEnum {
  rock('Rock', 1),
  paper('Paper', 2),
  scissors('Scissors', 3);

  const RPSEnum(this.name, this.value);
  final String name;
  final int value;
}
