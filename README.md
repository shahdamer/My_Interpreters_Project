# 🧩 My Interpreters Project — MiniFun & MiniTyFun (OCaml)

This repository contains two interpreters for small functional languages implemented in OCaml, developed as part of the *Languages, Compilers and Interpreters* course during the first semester of the Master’s in Computer Science (Software Program) at the **University of Pisa (2024/2025)**.

---

## 📘 Project Overview

The project includes two interpreters:

1. 🧠 **MiniFun-Interpreter**
   - A small *functional* programming language interpreter supporting functions, recursion, and let-bindings.
   - Implements lexical scoping and first-class functions.

2. 🔍 **MiniTyFun-Interpreter**
   - A **typed** extension of MiniFun with explicit type definitions and a static type-checking system.
   - Adds type inference, recursive closures, and function typing rules.

Both interpreters are written in OCaml using **OCamllex** and **Menhir**, with modular design and clear separation between **core semantics**, **lexer**, **parser**, and **main driver**.

---

## 🗂 Repository Structure

```
My_Interpreters_Project/
│
├── MiniFun-Interpreter/
│   ├── core.ml
│   ├── main.ml
│   ├── minifun_lexer.mll
│   ├── minifun_parser.mly
│   ├── dune
│   ├── dune-project
│   └── tests/
│       ├── test1.minifun
│       ├── ...
│
└── MiniTyFun-Interpreter/
    ├── minityfun
    ├── test_minityfun.ml
    ├── test_minityfun.cmi
    ├── test_minityfun.cmo
    └── test_minityfun (binary)
```

---

## 🧠 MiniFun Language

### 1. Purpose
MiniFun is a lightweight *functional programming language* built to experiment with:
- **First-class functions**
- **Closures**
- **Let-bindings**
- **Function application and recursion**

The interpreter evaluates MiniFun expressions recursively in an *environment* that stores variable bindings.

---

### 2. Core Module (`core.ml`)

Defines:
- **Values:**
  ```ocaml
  type value =
    | IntVal of int
    | BoolVal of bool
    | Closure of string * expr * env
    | RecClosure of string * string * expr * env
  ```
- **Environment:** list of `(variable, value)` pairs.
- **Evaluation:** `eval expr env` evaluates an expression recursively.

Supported features:
- Arithmetic and boolean operations  
- Variable lookup  
- Let-bindings and nested scopes  
- Function definitions (`fun x -> e`)  
- Function application (`f e`)  
- Recursion via `let rec f x = e1 in e2`

---

### 3. Lexer (`minifun_lexer.mll`)

Implements tokenization using **OCamllex**:
- Keywords: `let`, `fun`, `in`, `if`, `then`, `else`
- Operators: `+`, `-`, `*`, `/`, `%`, `and`, `or`, `not`, `<`, `>`, `=`
- Literals: integers and booleans
- Identifiers: variables and function names

---

### 4. Parser (`minifun_parser.mly`)

Implements grammar and operator precedence using **Menhir**:
- Function definitions and applications are **left-associative**
- Operator precedence ensures `*` and `/` > `+` and `-`
- Logical operators (`and`, `or`, `not`) follow standard precedence

Key grammar rules:
```ocaml
expr:
  | LET x = expr IN expr
  | LETREC f x = expr IN expr
  | FUN x ARROW expr
  | IF expr THEN expr ELSE expr
  | expr PLUS expr
  | expr TIMES expr
  | expr AND expr
  | expr OR expr
  | NOT expr
  | expr expr  (* function application *)
```

---

### 5. Evaluation Examples

**Example 1: Simple logical operation**
```minifun
let x = true in
let y = false in
x and not y
```
✅ Output: `true`

**Example 2: Function and variable binding**
```minifun
let x = 5 in
let y = fun z => z * x in
let x = 0 in
y 10
```
✅ Output: `50`  
(Uses outer `x` = 5 inside the closure.)

---

## 🧮 MiniTyFun Language

### 1. Overview

MiniTyFun extends MiniFun by adding **static typing**:
- Integers, booleans, and function types  
- Type inference and type-checking  
- Recursive closures for self-referential functions

---

### 2. Types and AST

Supported types:
```ocaml
type ty =
  | TyInt
  | TyBool
  | TyArrow of ty * ty
```

Expressions include:
- Literals (`IntLit`, `BoolLit`)
- Variables (`Var`)
- Arithmetic and logical ops
- Conditional (`If`)
- Functions (`Fun`)
- Let-bindings and recursive functions (`Letfun`)
- Applications (`App`)

---

### 3. Type Checking

The function `typeof expr tenv` ensures that:
- Arithmetic operations only apply to integers
- Boolean operators only apply to booleans
- Function arguments and return types are consistent

Example:
```ocaml
If (Op (Var "x", Minor, IntLit 2),
    IntLit 1,
    Op (Var "x", Times, App (Var "fact", Op (Var "x", Minus, IntLit 1))))
```
✔️ `x` must be an integer,  
✔️ `fact` must be of type `int -> int`.

---

### 4. Recursive Closures

To support recursion, **recursive closures (RecClosure)** store:
- Function name  
- Parameter name  
- Function body  
- Environment containing self-reference

Example:
```ocaml
letfun fact x : int =
  if x < 2 then 1
  else x * fact (x - 1)
in fact 5
```
✅ Output: `120`

The function is bound to its own environment, resolving self-calls safely.

---

### 5. Evaluation (`eval`)

- Evaluates expressions recursively with a runtime environment.
- Supports nested closures and recursive calls.
- Ensures type correctness before execution.

---

### 6. Example Run

```bash
ocamlc -o minityfun core.ml
./minityfun
```

Or if using Dune:
```bash
dune exec ./test_minityfun.exe
```

---

## 🧩 Summary of Differences

| Feature | MiniFun | MiniTyFun |
|----------|----------|------------|
| Type System | Untyped | Static typing (TyInt, TyBool, TyArrow) |
| Recursion | LetRec closures | Recursive closures (RecClosure) |
| Type Inference | None | Built-in `typeof` function |
| Language Constructs | Basic functional | Typed functional with checks |

---

## 🧰 Technologies

- **Language:** OCaml  
- **Tools:** Dune, OCamllex, Menhir  
- **Concepts:** Parsing, Type Checking, Functional Evaluation, Closures, Recursion  

---

## 🧑‍💻 Author
**Shahd Amer**  
University of Pisa — Languages, Compilers and Interpreters (2024/2025)  
📧 `s.amer@studenti.unipi.it`

---

## 🧭 How to Run All Projects

### Build and run MiniFun:
```bash
cd MiniFun-Interpreter
dune build
dune exec ./main.exe tests/test1.minifun
```

### Build and run MiniTyFun:
```bash
cd MiniTyFun-Interpreter
dune build
dune exec ./test_minityfun.exe
```

---
