(* MiniFun Interpreter Main
   This module is the entry point for the MiniFun interpreter.
   It handles file input, user interaction, and program execution.
*)

open Core  (* Import the core module *)

(* Helper function to read and validate integer input *)
let rec read_int () =
  Printf.printf " Please enter an integer: ";
  flush stdout; (* Ensure the prompt appears immediately *)
  let input = read_line () in
  try int_of_string input
  with Failure _ ->
    Printf.eprintf " Invalid integer! Please try again.\n";
    flush stderr; (* Flush error message immediately *)
    read_int () (* Retry *)

(* Recursive function to get input value from the user *)
let rec get_input_value () =
  Printf.printf " Please enter input type (int || bool): ";
  flush stdout; (* Ensure the prompt appears immediately *)
  let input_type = read_line () in
  match input_type with
  | "int" -> IntVal (read_int ()) (* Use the helper function *)
  | "bool" -> 
      Printf.printf " Please enter boolean (true || false): ";
      flush stdout; (* Ensure the prompt appears immediately *)
      let s = read_line () in
      if s = "true" then BoolVal true
      else if s = "false" then BoolVal false
      else (
        Printf.eprintf " Invalid boolean! Please enter 'true' || 'false'.\n";
        flush stderr; (* Flush error message immediately *)
        get_input_value () (* Retry *)
      )
  | _ -> 
      Printf.eprintf " Invalid input type! Please enter 'int' || 'bool'.\n";
      flush stderr; (* Flush error message immediately *)
      get_input_value () (* Retry *)

(* Entry point of the program *)
let () =
  (* Check if the program file is provided as a command-line argument *)
  if Array.length Sys.argv <> 2 then (
    Printf.eprintf " Usage: %s <program.minifun>\n" Sys.argv.(0);
    exit 1
  );

  (* Read program file from command-line argument *)
  let program_file = Sys.argv.(1) in

  (* Attempt to open and lex the program file *)
  let lexbuf =
    try Lexing.from_channel (open_in program_file)
    with Sys_error msg ->
      Printf.eprintf " Error: Unable to open file %s\nReason: %s\n" program_file msg;
      exit 1
  in

  (* Parse the MiniFun program *)
  let program = 
    try Minifun_parser.program Minifun_lexer.read lexbuf
    with
    | Minifun_lexer.LexingError msg ->
        Printf.eprintf " Error Detected (Lexing error): %s\n" msg;
        exit 1
    | Minifun_parser.Error ->
        Printf.eprintf " Error Detected (Syntax error) in: %s\n" program_file;
        exit 1
  in

  (* Get input value from the user *)
  let input_value = get_input_value () in

  (* Bind the input value to the environment *)
  let env = [("input", input_value)] in

  (* Evaluate the program with the input bound to "input" *)
  let result_value = 
    try eval env program  (* Pass the environment and program to eval *)
    with Failure msg ->
      Printf.eprintf " Error Detected (Runtime error): %s\n" msg;
      exit 1
  in

  (* Display output *)
  match result_value with
  | IntVal v -> Printf.printf " Result (int output): %d\n" v
  | BoolVal v -> Printf.printf " Result (bool output): %b\n" v
  | _ -> Printf.printf " Invalid result type\n"