(* MiniFun Core
   This module defines the core structures and evaluation logic
   for the MiniFun language, a simple functional programming language.
*)

(* Abstract syntax tree (AST) for MiniFun *)

(* Define the types of expressions in the language *)
type expression = 
  | Num of int               (* Integer literals *)
  | Bool of bool             (* Boolean literals *)
  | Var of string            (* Variable references *)
  | Op of expression * operator * expression  (* Binary operations *)
  | If of expression * expression * expression  (* If-then-else statement *)
  | Let of string * expression * expression    (* Let binding *)
  | Fun of string * expression          (* Function definition *)
  | LetRec of string * string * expression * expression  (* Recursive let binding *)
  | App of expression * expression      (* Function application *)

(* Define the operators supported in the language *)
and operator = 
  | Add       (* Addition *)
  | Subtract  (* Subtraction *)
  | Multiply  (* Multiplication *)
  | Divide    (* Division *)
  | Modulo    (* Modulo operation *)
  | Less      (* Less-than comparison *)
  | Greater   (* Greater-than comparison *)
  | Not       (* Logical NOT operation *)
  | And       (* Logical AND operation *)
  | Or        (* Logical OR operation *)

(* Define the types of values that can be stored in the environment *)
type value = 
  | IntVal of int            (* Integer value *)
  | BoolVal of bool          (* Boolean value *)
  | Closure of string * expression * value environment  (* Function closure *)
  | RecClosure of string * string * expression * value environment  (* Recursive closure *)

(* Define the environment as a list of variable bindings *)
and 'a environment = (string * 'a) list

(* Look up a variable in the environment *)
let lookup env x = 
  try List.assoc x env with Not_found -> failwith ("Unbound variable: " ^ x)

(* Add or update a variable in the environment *)
let update env x v = (x, v) :: env

(* Evaluate an expression in the given environment *)
let rec eval env = function
  | Num i -> IntVal i  (* Evaluate integer literals *)
  | Bool b -> BoolVal b  (* Evaluate boolean literals *)
  | Var x -> lookup env x  (* Look up variable in the environment *)

  | Op (e1, op, e2) ->  (* Evaluate binary operations *)
      let v1 = eval env e1 in
      let v2 = eval env e2 in
      (match op, v1, v2 with
        | Add, IntVal n1, IntVal n2 -> IntVal (n1 + n2)  (* Addition *)
        | Subtract, IntVal n1, IntVal n2 -> IntVal (n1 - n2)  (* Subtraction *)
        | Multiply, IntVal n1, IntVal n2 -> IntVal (n1 * n2)  (* Multiplication *)
        | Divide, IntVal n1, IntVal n2 ->  (* Division *)
            if n2 = 0 then failwith "Division by zero" else IntVal (n1 / n2)
        | Modulo, IntVal n1, IntVal n2 ->  (* Modulo *)
            if n2 = 0 then failwith "Modulo by zero" else IntVal (n1 mod n2)
        | Less, IntVal n1, IntVal n2 -> BoolVal (n1 < n2)  (* Less-than comparison *)
        | Greater, IntVal n1, IntVal n2 -> BoolVal (n1 > n2)  (* Greater-than comparison *)
        | And, BoolVal b1, BoolVal b2 -> BoolVal (b1 && b2)  (* Logical AND *)
        | Or, BoolVal b1, BoolVal b2 -> BoolVal (b1 || b2)  (* Logical OR *)
        | Not, BoolVal b, _ -> BoolVal (not b)  (* Logical NOT *)
        | _ -> failwith "Invalid operation")  (* Invalid operation *)

  | If (cond, thenExpr, elseExpr) ->  (* Evaluate if-then-else expressions *)
      let v = eval env cond in
      (match v with
        | BoolVal true -> eval env thenExpr  (* Evaluate then branch *)
        | BoolVal false -> eval env elseExpr  (* Evaluate else branch *)
        | _ -> failwith "Condition must be a boolean")  (* Invalid condition *)


  | Let (var, e1, e2) ->  (* Evaluate let bindings *)
      let v1 = eval env e1 in
      eval (update env var v1) e2

  | Fun (param, body) -> Closure (param, body, env)  (* Create a function closure *)

  | LetRec (func, param, body, expr) ->  (* Evaluate recursive let bindings *)
      let closure = RecClosure (func, param, body, env) in
      eval (update env func closure) expr

  | App (funcExpr, argExpr) ->  (* Evaluate function applications *)
      match eval env funcExpr with
        | Closure (param, body, closureEnv) ->  (* Non-recursive function *)
            eval (update closureEnv param (eval env argExpr)) body
        | RecClosure (func, param, body, closureEnv) ->  (* Recursive function *)
            let env' = update closureEnv func (RecClosure (func, param, body, closureEnv)) in
            eval (update env' param (eval env argExpr)) body
        | _ -> failwith "Application to non-function"  (* Invalid function application *)

(* Convert an expression to a string for debugging *)
(*let rec string_of_expr = function
  | Num i -> string_of_int i  (* Convert integer to string *)
  | Bool b -> string_of_bool b  (* Convert boolean to string *)
  | Var x -> x  (* Return variable name *)
  | Op (e1, op, e2) ->  (* Convert binary operation to string *)
      let op_str = match op with
        | Add -> "+"
        | Subtract -> "-"
        | Multiply -> "*"
        | Divide -> "/"
        | Modulo -> "mod"
        | Less -> "<"
        | Greater -> ">"
        | Not -> "not"
        | And -> "and"
        | Or -> "or"
      in
      Printf.sprintf "(%s %s %s)" (string_of_expr e1) op_str (string_of_expr e2)
  | If (cond, thenExpr, elseExpr) ->  (* Convert if-then-else to string *)
      Printf.sprintf "if %s then %s else %s" (string_of_expr cond) (string_of_expr thenExpr) (string_of_expr elseExpr)
  | Fun (x, e) -> Printf.sprintf "fun %s => %s" x (string_of_expr e)  (* Convert function to string *)
  | Let (x, e1, e2) -> Printf.sprintf "let %s = %s in %s" x (string_of_expr e1) (string_of_expr e2)  (* Convert let binding to string *)
  | LetRec (f, x, e1, e2) -> Printf.sprintf "letrec %s %s = %s in %s" f x (string_of_expr e1) (string_of_expr e2)  (* Convert recursive let binding to string *)
  | App (e1, e2) -> Printf.sprintf "(%s %s)" (string_of_expr e1) (string_of_expr e2)  (* Convert function application to string *)
  
  *)