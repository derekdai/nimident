import std/[options, strutils, sugar]
export options
import regex

type
  IdentStyle* = enum
    Camel,           ## aaBbCc
    UpperCamel,      ## AaBbCc
    Snake,           ## aa_bb_cc
    CSnake,          ## _aa__bb_cc__
    ScreamingSnake,  ## AA_BB_CC
    CScreamingSnake, ## _AA__BB_CC__

const patterns: array[IdentStyle, Regex] = [
  re"\A([a-z][0-9a-z]*)([0-9A-Z][0-9a-z]*)*\z",
  re"\A([A-Z][0-9a-z]*)([0-9A-Z][0-9a-z]*)*\z",
  re"\A([a-z][0-9a-z]*)(?:_([0-9a-z][0-9a-z]*))*\z",
  re"\A(_*)([a-z][0-9a-z]*)((_+)([0-9a-z][0-9a-z]*))*(_*)\z",
  re"\A([A-Z][0-9A-Z]*)(?:_([0-9A-Z][0-9A-Z]*))*\z",
  re"\A(_*)([A-Z][0-9A-Z]*)((_+)([0-9A-Z][0-9A-Z]*))*(_*)\z",
]

proc guessStyle(s: string; m: var RegexMatch): Option[IdentStyle] =
  if s.match(patterns[Camel], m):
    Camel.some
  elif s.match(patterns[UpperCamel], m):
    UpperCamel.some
  elif s.match(patterns[Snake], m):
    Snake.some
  elif s.match(patterns[ScreamingSnake], m):
    ScreamingSnake.some
  elif s.match(patterns[CSnake], m):
    CSnake.some
  elif s.match(patterns[CScreamingSnake], m):
    CScreamingSnake.some
  else:
    none[IdentStyle]()

proc guessStyle*(s: string): Option[IdentStyle] =
  runnableExamples:
    assert "a".guessStyle() == Camel.some
    assert "aB".guessStyle() == Camel.some
    assert "aBC".guessStyle() == Camel.some
    assert "aBbCc".guessStyle() == Camel.some
  var m: RegexMatch
  guessStyle(s, m)

iterator pairs(self: RegexMatch; s, separator: string): (int, string) =
  var i = 0
  for capt in self.captures:
    for sli in capt:
      let seg = s[sli]
      if seg == "" or seg.startsWith(separator): continue
      yield (i, seg)
      i.inc

proc join(self: RegexMatch; s, separator: string; p: proc(i: int;
    s: string): string): string =
  for i, seg in self.pairs(s, separator):
    result.add p(i, seg)

proc to*(s: string; style: IdentStyle; srcStyle = none[IdentStyle]();
    separator = "_"; prefix, suffix = ""): Option[string] =
  ## `separator`, `prefix` and `suffix` are used to generate C style snake case
  runnableExamples:
    assert "c_d".to(UpperCamel) == "CD".some
    assert "_c_d".to(UpperCamel) == "CD".some
    assert "Cd".to(UpperCamel) == "Cd".some
    assert "cD".to(UpperCamel) == "CD".some
    assert "c_D".to(UpperCamel) == none(string)
    assert "cDdEe".to(Snake) == "c_dd_ee".some
    assert "CDdEe".to(Snake) == "c_dd_ee".some
  var capts: RegexMatch
  let sty =
    if srcStyle.isSome and s.match(patterns[srcStyle.unsafeGet], capts):
      srcStyle
    else:
      s.guessStyle(capts)

  if sty.isNone:
    return
  elif style == sty.unsafeGet:
    return s.some

  case style:
  of Camel:
    result = capts.join(s, "_", proc(i: int; s: string): string =
      let s = s.toLowerAscii
      if i > 0: s.capitalizeAscii else: s
    ).some
  of UpperCamel:
    result = capts.join(s, "_", (i, s) => s.toLowerAscii.capitalizeAscii).some
  of Snake:
    result = capts.join(s, "_", proc(i: int; s: string): string =
      (if i == 0: "" else: "_") & s.toLowerAscii
    ).some
  of ScreamingSnake:
    result = capts.join(s, "_", proc(i: int; s: string): string =
      (if i == 0: "" else: "_") & s.toUpperAscii
    ).some
  of CSnake:
    result = (prefix & capts.join(s, "_", proc(i: int; s: string): string =
      (if i == 0: "" else: separator) & s.toLowerAscii
    ) & suffix).some
  of CScreamingSnake:
    result = (prefix & capts.join(s, "_", proc(i: int; s: string): string =
      (if i == 0: "" else: separator) & s.toUpperAscii
    ) & suffix).some
