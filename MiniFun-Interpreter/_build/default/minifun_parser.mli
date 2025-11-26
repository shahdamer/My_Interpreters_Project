
(* The type of tokens. *)

type token = 
  | WITH
  | TIMES
  | THEN
  | RPAREN
  | PLUS
  | OUTPUT
  | OR
  | NOT
  | MOD
  | MINUS
  | MAIN
  | LPAREN
  | LETREC
  | LET
  | LESS
  | INT of (int)
  | INPUT
  | IN
  | IF
  | IDENT of (string)
  | GREATER
  | FUN
  | EQUAL
  | EOF
  | ELSE
  | DIV
  | DEF
  | BOOL of (bool)
  | AS
  | ARROW
  | AND

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val program: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Core.expression)
