type formula = 
  | Var of int
  | Neg of formula
  | And of formula * formula 
  | Or of formula * formula
  | Implies of formula * formula

(* Question 1: *)

let f1 = Implies(Implies(Var 1, Var 2), Var 3)
let f2 = Or(Implies(Neg(Var 1), Neg(Var 2)), Implies(Var 3, Var 1))
let f3 n = 
  let rec aux i acc = 
    if i <= n then 
      let new_formula = Or(acc, And(Var i, Var(i+1))) in 
      aux (i+1) new_formula
    else 
      acc
  in aux 2 (And(Var 1, Var 2))

(* Question 2: *)
let rec size f = 
  match f with
  | Var _ -> 1
  | Neg f1 -> size f1
  | And (f1, f2) | Or (f1, f2) | Implies (f1, f2) -> (size f1) + (size f2)

(* Question 5: *)
let rec remove_implication f = 
  match f with
  | Implies (f1, f2)  -> Or (Neg (remove_implication f1), remove_implication f2)
  | Or (f1, f2)        -> Or (remove_implication f1, remove_implication f2)
  | And (f1, f2)        -> And (remove_implication f1, remove_implication f2)
  | Neg(f)             -> Neg (remove_implication f)
  | f                 -> f

(* Question 6: *)
let rec push_not_down f = 
  match f with
  | Neg (Neg f1)      -> push_not_down f1
  | Neg (And (f1, f2)) -> Or (push_not_down (Neg f1), push_not_down (Neg f2))
  | Neg (Or (f1, f2)) -> And (push_not_down (Neg f1), push_not_down (Neg f2))
  | And (f1, f2)       -> And (push_not_down f1, push_not_down f2)
  | Or (f1, f2)       -> Or (push_not_down f1, push_not_down f2)
  | Implies(f1, f2)  -> Implies (push_not_down f1, push_not_down f2)
  | f                 -> f

let rec push_or_down = function
  | Or (f1, f2) -> begin
    match push_or_down f1, push_or_down f2 with
    | f1, And (f2, f3) | And (f2, f3), f1 ->
      push_or_down (And (Or (f1, f2), Or (f1, f3)))
    | f1, f2 -> Or (f1, f2)
  end
  | And (f1, f2) -> And (push_or_down f1, push_or_down f2)
  | f -> f

(* Question 8: *)
let to_cnf f = push_not_down ((remove_implication (push_or_down f)))
let is_literal = function
  | Var _ | Neg (Var _) -> true
  | _ -> false

let rec is_clause = function
  | Or (f1, f2) ->
     (is_literal f1 || is_clause f1) && (is_literal f2 || is_clause f2)
  | f -> is_literal f

let rec is_cnf = function
  | And (f1, f2) -> is_cnf f1 && is_cnf f2
  | f -> is_clause f

let rec number_of_clauses = function
  | And (f1, f2) -> number_of_clauses f1 + number_of_clauses f2
  | _ -> 1

let ff = f_ex42 16
let ffc = to_cnf ff
let _ = size ff
let _ = size ffc

type literal = int
type clause = int list  (* sorted *)

(* Inserting into a sorted list *)
let rec insert f c =
  match c with
  | [] -> [f]
  | x :: xs when f <= x -> f :: c
  | x :: xs -> x :: insert f xs

let to_clause_form f =
  let f = to_cnf f in
  let rec to_clause f c =
    match f with
    | Or (f1, f2) -> to_clause f1 (to_clause f2 c)
    | _ -> insert f c
  in
  let rec to_clause_form f fc =
    match f with
    | And (f1, f2) -> to_clause_form f1 (to_clause_form f2 fc)
    | f -> to_clause f []
  in
  to_clause_form f []

let cut (c1 : clause) (c2 : clause) (p : literal) : clause =
  assert (List.mem p c1);
  assert (List.mem (-p) c2);
  let remove p = List.filter ((<>) p) in
  let merge = List.merge Stdlib.compare in
  merge (remove p c1) (remove p c2)

let variables_to_cut (c1 : clause) (c2 : clause) : clause =
  List.fold_left (fun acc elt -> if List.mem (-elt) c2 then elt :: acc else acc ) [] c1

let new_clauses (c1 : clause) (c2 : clause) : clause list =
  List.fold_left (fun acc elt -> cut c1 c2 elt :: acc) [] (variables_to_cut c1 c2)

let has_empty_clause (clauses : clause list) : bool = List.mem [] clauses

let derive_empty_clause (clauses : clause list) : bool =
  let rec process (to_process : clause list) (provable : clause list) : clause list =
    match to_process with
    | [] -> provable
    | c :: rest ->
       let (new_clauses : clause list) =
         List.map (new_clauses c) (provable : clause list)
         |> List.flatten
         |> List.filter @@ Fun.flip List.mem (to_process @ provable)
       in
       process (to_process @ new_clauses) (c :: provable)
  in
  process clauses [] |> has_empty_clause
