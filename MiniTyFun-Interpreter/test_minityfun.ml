(* Types in the language *)
type ty =
  | TyInt
  | TyBool
  | TyArrow of ty * ty  (* Function type: argument type -> return type *)

(* Abstract syntax tree for MiniTyFun *)
and ident = string

and expr = 
  | IntLit of int
  | BoolLit of bool
  | Var of ident
  | Op of expr * op * expr
  | If of expr * expr * expr
  | Fun of ident * ty * expr  (* Function: argument name, type, body *)
  | Let of ident * ty * expr * expr  (* Let binding: variable name, type, value, body *)
  | Letfun of ident * ident * ty * expr * expr  (* Recursive function *)
  | App of expr * expr  (* Function application *)

and op = 
  | Plus       (* Addition *)
  | Minus      (* Subtraction *)
  | Times      (* Multiplication *)
  | Minor      (* Less than *)
  | Not        (* Logical NOT *)
  | And        (* Logical AND *)
  | Or         (* Logical OR *)
  | Div        (* Division *)

(* Type environment *)
type ty_env = (ident * ty) list

(* Value environment *)
type value_env = (ident * value) list

(* Values in the language *)
and value =
  | IntVal of int
  | BoolVal of bool
  | Closure of ident * expr * value_env  (* Closure: argument name, body, environment *)
  | RecClosure of ident * ident * expr * value_env  (* Recursive closure *)


(* Lookup a variable in the type environment *)
let lookup_ty env x =
  try List.assoc x env with Not_found -> failwith ("Unbound variable: " ^ x)

(* Extend the type environment *)
let extend_ty env x t = (x, t) :: env

(* Lookup a variable in the value environment *)
let lookup env x =
  try List.assoc x env with Not_found -> failwith ("Unbound variable: " ^ x)

(* Extend the value environment *)
let extend env x v = (x, v) :: env

(* --------------- Type Checking --------------- *)

(* Type checking function *)
let rec typeof ty_env e =
  match e with
  | IntLit _ -> TyInt
  | BoolLit _ -> TyBool
  | Var x -> lookup_ty ty_env x
  | Op (e1, op, e2) ->
      let ty1 = typeof ty_env e1 in
      let ty2 = typeof ty_env e2 in
      (match op, ty1, ty2 with
       | Plus, TyInt, TyInt -> TyInt
       | Minus, TyInt, TyInt -> TyInt
       | Times, TyInt, TyInt -> TyInt
       | Div, TyInt, TyInt -> TyInt
       | Minor, TyInt, TyInt -> TyBool
       | And, TyBool, TyBool -> TyBool
       | Or, TyBool, TyBool -> TyBool
       | Not, TyBool, _ -> TyBool
       | _ -> failwith "Type mismatch in operation")
  | If (cond, then_exp, else_exp) ->
      let cond_ty = typeof ty_env cond in
      if cond_ty <> TyBool then failwith "Condition must be a boolean"
      else
        let then_ty = typeof ty_env then_exp in
        let else_ty = typeof ty_env else_exp in
        if then_ty = else_ty then then_ty
        else failwith "Branches of if-expression must have the same type"
  | Fun (x, ty_x, body) ->
      let body_ty = typeof (extend_ty ty_env x ty_x) body in
      TyArrow (ty_x, body_ty)
  | Let (x, ty_x, e1, e2) ->
      let e1_ty = typeof ty_env e1 in
      if e1_ty <> ty_x then failwith "Type mismatch in let binding"
      else typeof (extend_ty ty_env x ty_x) e2
  | Letfun (f, x, ty_x, body, body2) ->
      let body_ty = typeof (extend_ty (extend_ty ty_env x ty_x) f (TyArrow (ty_x, TyInt))) body in
      if body_ty <> TyInt then failwith "Recursive function body must return an integer"
      else typeof (extend_ty ty_env f (TyArrow (ty_x, TyInt))) body2
  | App (e1, e2) ->
      let ty1 = typeof ty_env e1 in
      let ty2 = typeof ty_env e2 in
      (match ty1 with
       | TyArrow (ty_arg, ty_ret) ->
           if ty_arg = ty2 then ty_ret
           else failwith "Argument type mismatch in function application"
       | _ -> failwith "Application expected a function")

(* --------------- Evaluation --------------- *)

(* Evaluation function *)
let rec eval env e =
  match e with
  | IntLit i -> IntVal i
  | BoolLit b -> BoolVal b
  | Var x -> lookup env x
  | Op (e1, op, e2) ->
      let v1 = eval env e1 in
      let v2 = eval env e2 in
      (match op, v1, v2 with
       | Plus, IntVal n1, IntVal n2 -> IntVal (n1 + n2)
       | Minus, IntVal n1, IntVal n2 -> IntVal (n1 - n2)
       | Times, IntVal n1, IntVal n2 -> IntVal (n1 * n2)
       | Div, IntVal n1, IntVal n2 -> IntVal (n1 / n2)
       | Minor, IntVal n1, IntVal n2 -> BoolVal (n1 < n2)
       | And, BoolVal b1, BoolVal b2 -> BoolVal (b1 && b2)
       | Or, BoolVal b1, BoolVal b2 -> BoolVal (b1 || b2)
       | Not, BoolVal b, _ -> BoolVal (not b)
       | _ -> failwith "Invalid operation")
  | If (cond, then_exp, else_exp) ->
      let cond_val = eval env cond in
      (match cond_val with
       | BoolVal true -> eval env then_exp
       | BoolVal false -> eval env else_exp
       | _ -> failwith "Condition must be a boolean")
  | Fun (x, _, body) -> Closure (x, body, env)
  | Let (x, _, e1, e2) ->
      let v1 = eval env e1 in
      eval (extend env x v1) e2
  | Letfun (f, x, _, body, body2) ->
      let rec _closure arg = eval (extend (extend env x arg) f (RecClosure (f, x, body, env))) body in
      eval (extend env f (RecClosure (f, x, body, env))) body2
  | App (e1, e2) ->
      let v1 = eval env e1 in
      let v2 = eval env e2 in
      (match v1 with
       | Closure (x, body, closure_env) ->
           eval (extend closure_env x v2) body
       | RecClosure (f, x, body, closure_env) ->
           let env' = extend closure_env f (RecClosure (f, x, body, closure_env)) in
           eval (extend env' x v2) body
       | _ -> failwith "Application to non-function")

(* --------------- Testing --------------- *)

(* Helper function to print test results *)
let print_test_result name result =
  Printf.printf "Test: %s -> %s\n" name (if result then "PASS" else "FAIL")

(* Test 1: Evaluate integer literal *)
let test_int_lit () =
  let expr = IntLit 42 in
  let ty = typeof [] expr in
  let v = eval [] expr in
  ty = TyInt && v = IntVal 42

(* Test 2: Evaluate addition *)
let test_plus () =
  let expr = Op (IntLit 10, Plus, IntLit 5) in
  let ty = typeof [] expr in
  let v = eval [] expr in
  ty = TyInt && v = IntVal 15

(* Test 3: Evaluate function application *)
let test_fun_app () =
  let expr = App (Fun ("x", TyInt, Op (Var "x", Plus, IntLit 1)), IntLit 5) in
  let ty = typeof [] expr in
  let v = eval [] expr in
  ty = TyInt && v = IntVal 6

(* Test 4: Evaluate if-expression *)
let test_if () =
  let expr = If (Op (IntLit 1, Minor, IntLit 2), IntLit 10, IntLit 20) in
  let ty = typeof [] expr in
  let v = eval [] expr in
  ty = TyInt && v = IntVal 10

(* Test 5: Evaluate recursive function (factorial) *)
let test_recursive () =
  let expr = Letfun ("fact", "x", TyInt,
                     If (Op (Var "x", Minor, IntLit 2),
                         IntLit 1,
                         Op (Var "x", Times, App (Var "fact", Op (Var "x", Minus, IntLit 1)))),
                     App (Var "fact", IntLit 5)) in
  let ty = typeof [] expr in
  let v = eval [] expr in
  ty = TyInt && v = IntVal 120

(* Run all tests *)
let run_tests () =
  print_test_result "Integer literal" (test_int_lit ());
  print_test_result "Addition" (test_plus ());
  print_test_result "Function application" (test_fun_app ());
  print_test_result "If-expression" (test_if ());
  print_test_result "Recursive function (factorial)" (test_recursive ())

(* Execute tests *)
let () = run_tests ()