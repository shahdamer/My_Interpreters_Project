{
(* MiniFun Lexer
   This module defines lexical rules for tokenizing MiniFun programs.
   It reads a stream of characters and produces a list of tokens.
*)

open Minifun_parser  (* Import token definitions from the parser *)

(* Exception raised for invalid tokens *)
exception LexingError of string  
}

(* Regular expressions for token components *)
let digit = ['0'-'9']  (* Digits for integer literals *)
let alpha = ['a'-'z' 'A'-'Z']  (* Letters for identifiers *)
let ident = alpha (alpha | digit | '_')*  (* Identifiers: variables, function names *)
let whitespace = [' ' '\t' '\n' '\r']  (* Whitespace characters *)

(* Lexer rules *)
rule read = parse
  | whitespace { read lexbuf }  (* Ignore whitespace and continue scanning *)
  | "let" { LET }  (* Keyword: let binding *)
  | "letrec" { LETREC }  (* Keyword: recursive let binding *)
  | "letfun" { LETREC } 
  | "in" { IN }  (* Keyword: in *)
  | "if" { IF }  (* Keyword: if condition *)
  | "then" { THEN }  (* Keyword: then branch *)
  | "else" { ELSE }  (* Keyword: else branch *)
  | "fun" { FUN }  (* Keyword: function definition *)
  | "true" { BOOL(true) }  (* Boolean literal: true *)
  | "false" { BOOL(false) }  (* Boolean literal: false *)
  | "+" { PLUS }  (* Addition operator *)
  | "-" { MINUS }  (* Subtraction operator *)
  | "*" { TIMES }  (* Multiplication operator *)
  | "/" { DIV }  (* Division operator *)
  | "mod" { MOD }  (* Modulo operator *)
  | "<" { LESS }  (* Less-than comparison operator *)
  | ">" { GREATER }  (* Greater-than comparison operator *)
  | "not" { NOT }  (* Logical NOT operator *)
  | "and" { AND }  (* Logical AND operator *)
  | "or" { OR }  (* Logical OR operator *)
  | "=" { EQUAL }  (* Equal operator *)
  | "=>" { ARROW }  (* Arrow operator for functions *)
  | "(" { LPAREN }  (* Left parenthesis *)
  | ")" { RPAREN }  (* Right parenthesis *)
  | "def" { DEF }  (* Keyword: program definition *)
  | "main" { MAIN }  (* Keyword: main function *)
  | "with" { WITH }  (* Keyword: with *)
  | "input" { INPUT }  (* Keyword: input variable *)
  | "output" { OUTPUT }  (* Keyword: output variable *)
  | "as" { AS }  (* Keyword: as *)
  | ident as id { IDENT(id) }  (* Identifier matched as a variable *)
  | digit+ as num { INT(int_of_string num) }  (* Convert numeric literals to integers *)
  | eof { EOF }  (* End of file token *)
  | _ { raise (LexingError (Lexing.lexeme lexbuf)) }  (* Raise error for unexpected characters *)