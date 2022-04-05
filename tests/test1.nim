import std/[options, unittest]
import nimident

test "test style checking":
  check "a".guessStyle() == Camel.some
  check "aB".guessStyle() == Camel.some
  check "aBC".guessStyle() == Camel.some
  check "aBbCc".guessStyle() == Camel.some
  check "A0A".guessStyle() == UpperCamel.some
  check "AaBb".guessStyle() == UpperCamel.some
  check "AaBb".guessStyle() == UpperCamel.some
  check "AAaa".guessStyle() == UpperCamel.some
  check "a_a".guessStyle() == Snake.some
  check "aa_aa".guessStyle() == Snake.some
  check "aa_aa_".guessStyle() != Snake.some
  check "_aa_aa".guessStyle() != Snake.some
  check "_aa_aa_".guessStyle() != Snake.some
  check "aa__aa".guessStyle() != Snake.some
  check "aa_aa_".guessStyle() == CSnake.some
  check "aa_aa__".guessStyle() == CSnake.some
  check "_aa_aa".guessStyle() == CSnake.some
  check "__aa_aa".guessStyle() == CSnake.some
  check "_aa_aa_".guessStyle() == CSnake.some
  check "__aa_aa__".guessStyle() == CSnake.some
  check "aa__aa".guessStyle() == CSnake.some
  check "__aa__aa__".guessStyle() == CSnake.some
  check "0a_aa".guessStyle() != Snake.some
  check "a_a0".guessStyle() == Snake.some
  check "A_0".guessStyle() == ScreamingSnake.some
  check "A_A".guessStyle() == ScreamingSnake.some
  check ")A_A".guessStyle() != ScreamingSnake.some
  check "_A_A".guessStyle() != ScreamingSnake.some
  check "A_A_".guessStyle() != ScreamingSnake.some
  check "A__A".guessStyle() != ScreamingSnake.some

test "test `to`":
  check "c_d".to(UpperCamel) == "CD".some
  check "_c_d".to(UpperCamel) == "CD".some
  check "Cd".to(UpperCamel) == "Cd".some
  check "cD".to(UpperCamel) == "CD".some
  check "c_D".to(UpperCamel) == none(string)
  check "cDdEe".to(Snake) == "c_dd_ee".some
  check "CDdEe".to(Snake) == "c_dd_ee".some
  check "cDdEe".to(ScreamingSnake) == "C_DD_EE".some
  check "CDdEe".to(ScreamingSnake) == "C_DD_EE".some
  check "CDdEe".to(CSnake, separator = "__", prefix = "__", suffix = "__") == "__c__dd__ee__".some
  check "CDdEe".to(CScreamingSnake, separator = "__", prefix = "__", suffix = "__") == "__C__DD__EE__".some
