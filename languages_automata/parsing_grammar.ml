type token = 
  | L              (* opening parenthesis *)
  | R              (* closing parenthesis *)
  | Int of int
  | Bin of string  (* operator for integers *)

exception Lexical_error of string

let is_integer s = 
  try 
    let k = int_of_string s in true
  with
  | Failure "int_of_string" -> false

let lexer s = 
  let list = String.split_on_char ' ' s in
  let rec aux l res = 
    match l with
    | [] -> List.rev res
    | x :: xs -> 
      if is_integer x then aux xs (Int (int_of_string x) :: res)
      else 
        begin
          match x with
          | "(" -> aux xs (L :: res)
          | ")" -> aux xs (R :: res)
          | "+" -> aux xs (Bin x :: res)
          | "*" -> aux xs (Bin x :: res)
          | _ -> raise (Lexical_error x)
        end
  in aux list []

let a = lexer "3 5 42 + * 2 +"

type tree = Leaf of int | Node of string * tree * tree

exception Syntax_Error of string

let transform x = 
  match x with
  | Bin s -> s
  | L -> "("
  | R -> ")"

let parse token_list = 
  let stack = Stack.create () in
  let rec aux token_list = 
    match token_list with
    | x :: xs ->
      begin
        match x with
        | Int y -> Stack.push (Leaf y) stack
        | _ -> 
          let a1 = Stack.pop stack in
          let a2 = Stack.pop stack in
          Stack.push (Node (transform x, a1, a2)) stack;
      end;
      aux xs
    | [] -> Stack.pop stack
  in aux token_list

type parser_state = {
  tokens : token array;
  mutable next_index : int;
}

let init token_list = 
  { tokens = token_list; next_index = 0 }

let state = init [||] (* The example shows an empty array; adjust as needed *)

let peek () =
  let i = state.next_index in
  if i < Array.length state.tokens then Some state.tokens.(i)
  else None

(* peek returns the element i that the cursor (next_index) points to
   and consume token consumes the token if the cursor points to this token and increments
   the cursor, otherwise, it raises an error *)

let consume token =
  match peek () with
  | Some t when t = token ->
      state.next_index <- state.next_index + 1
  | Some t -> raise (Syntax_Error "unexpected token")
  | None -> raise (Syntax_Error "unexpected end of input")  


let rec factor () =
  match peek () with
  | Some L ->
      consume L;
      let t = sum () in
      consume R;
      t
  | Some (Int x) ->
      Leaf x
  | Some _ -> raise (Syntax_Error "unexpected token")
  | None -> raise (Syntax_Error "unexpected end of input")
