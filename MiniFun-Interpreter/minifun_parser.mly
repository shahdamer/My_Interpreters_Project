/* MiniFun Parser
   This file defines the grammar rules for parsing MiniFun programs.
   It converts a sequence of tokens from the lexer into an abstract syntax tree (AST).
*/

%{
  open Core  (* Import AST definitions from the Core module *)
%}

/* Token Definitions with Associated Types */
%token <int> INT        (* Integer literals *)
%token <bool> BOOL      (* Boolean literals *)
%token <string> IDENT   (* Variable identifiers *)
%token LET LETREC IN IF THEN ELSE FUN  (* Keywords for program structure *)
%token PLUS MINUS TIMES DIV MOD        (* Arithmetic operators *)
%token LESS GREATER NOT AND OR         (* Boolean operators *)
%token EQUAL ARROW LPAREN RPAREN       (* Other syntax tokens *)
%token DEF MAIN WITH INPUT OUTPUT AS   (* Program structure keywords *)
%token EOF                             (* End of file token *)

/* Operator Precedence and Associativity */


%nonassoc IN    (* IN keyword in let bindings *)
%nonassoc ELSE  (* ELSE keyword in if-then-else expressions *)

%right ARROW    (* Function arrow (=>) *)

%left PLUS MINUS  (* Addition and subtraction *)
%left TIMES DIV MOD  (* Multiplication, division, and modulo *)

%left AND OR  (* Logical AND and OR *)
%left LESS GREATER  (* Less-than and greater-than comparisons *)


/* Start symbol and its type */
%start <expression> program

%%
/* Grammar Rules */

/* Program Structure */
program:
  | DEF MAIN WITH INPUT x = IDENT OUTPUT y = IDENT AS e = expr EOF { 
      Let(x, Var "input", e)  (* Bind input variable and return the expression *)
    }

/* Expressions */
expr:
  | fun_expr { $1 }  (* Function expression *)
  | let_expr { $1 }  (* Let expression *)
  | if_expr { $1 }  (* If expression *)
  | op_expr { $1 }  (* Operator expression *)
  | app_expr { $1 }  (* Application expression *)

/* Function Definition */
fun_expr:
  | FUN x = IDENT ARROW e = expr { Fun(x, e) }  (* Function definition *)

/* Let Bindings */
let_expr:
  | LET x = IDENT EQUAL t1 = expr IN t2 = expr { Let(x, t1, t2) }  (* Let binding *)
  | LETREC f = IDENT x = IDENT EQUAL t1 = expr IN t2 = expr { LetRec(f, x, t1, t2) }  (* Recursive let binding *)

/* If-Then-Else Expression */
if_expr:
  | IF e1 = expr THEN e2 = expr ELSE e3 = expr { If(e1, e2, e3) }  (* If-then-else expression *)

/* Binary Operations */
op_expr:
  | e1 = expr op = opr e2 = expr { Op(e1, op, e2) }  (* Binary operation *)

/* Function Application */
app_expr:
  | app_expr atomic_expr { App($1, $2) }  (* Function application *)
  | atomic_expr { $1 }  (* Atomic expression *)

/* Atomic Expressions */
atomic_expr:
  | i = INT { Num(i) }  (* Integer literal *)
  | b = BOOL { Bool(b) }  (* Boolean literal *)
  | x = IDENT { Var(x) }  (* Variable reference *)
  | NOT e = atomic_expr { Op(e, Not, e) }  (* Logical NOT *)
  | LPAREN e = expr RPAREN { e }  (* Parenthesized expression *)

/* Operators */
opr:
  | PLUS { Add }  (* Addition operator *)
  | MINUS { Subtract }  (* Subtraction operator *)
  | TIMES { Multiply }  (* Multiplication operator *)
  | DIV { Divide }  (* Division operator *)
  | MOD { Modulo }  (* Modulo operator *)
  | LESS { Less }  (* Less-than operator *)
  | GREATER { Greater }  (* Greater-than operator *)
  | AND { And }  (* Logical AND operator *)
  | OR { Or }  (* Logical OR operator *)