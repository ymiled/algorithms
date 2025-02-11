(* This code deals with propositional logic formulas, including evaluation and satisfiability checks.
   It includes a brute-force method and a decision tree method for determining satisfiability. *)

(* Define the type for propositional logic formulas *)
type formula = 
  | C of bool            (* Constant boolean value *)
  | V of int             (* Variable identified by an integer index *)
  | And of formula * formula   (* Logical AND *)
  | Or of formula * formula    (* Logical OR *)
  | Imp of formula * formula  (* Logical implication *)
  | Not of formula       (* Logical NOT *)

(* Type for valuation: an array of boolean values for variables *)
type valuation = bool array

(* Compute the size of a formula, which is the number of sub-formulas plus one *)
let rec size f = 
  match f with
  | C _ -> 1
  | V _ -> 1
  | And(f1, f2) | Or(f1, f2) | Imp(f1, f2) -> (size f1) + (size f2) + 1
  | Not f1 -> 1 + (size f1)

(* Find the maximum variable index in a formula *)
let rec max_var f = 
  match f with
  | C _ -> max_int
  | V i -> i
  | And(f1, f2) | Or(f1, f2) | Imp(f1, f2) -> max (max_var f1) (max_var f2)
  | Not f1 -> max_var f1 

(* Evaluate a formula given a valuation (array of boolean values) *)
let rec evaluate f v = 
  match f with
  | C b -> b 
  | V i -> v.(i)
  | And(f1, f2) -> (evaluate f1 v) && (evaluate f2 v)
  | Or(f1, f2) -> (evaluate f1 v) || (evaluate f2 v)
  | Imp(f1, f2) -> (not (evaluate f1 v)) || (evaluate f2 v)
  | Not f1 -> not (evaluate f1 v)

(* Exception used when all possible valuations have been tried *)
exception Done 

(* Increment the valuation array to the next combination of boolean values *)
let rec increment_valuation v =
  let n = Array.length v in 
  let i = ref 0 in
  while !i < n && v.(!i) do 
    v.(!i) <- false;
    incr i
  done;
  if !i < n then
    v.(!i) <- true
  else raise Done

(* Brute-force method to check if a formula is satisfiable *)
let satisfiable_brute f = 
  let n = max_var f in
  let v = Array.make n false in
  try 
    while not (evaluate f v) do 
      increment_valuation v
    done;
    true
  with
  | Done -> false

(* Quine's Algorithm to simplify formulas by eliminating constants *)

(* Eliminate constant sub-formulas from the formula *)
let rec eliminate_constants f = 
  match f with
  | And(f1, f2) -> 
    begin
      match eliminate_constants f1, eliminate_constants f2 with
      | C false, _ | _, C false -> C false
      | C true, h | h, C true -> h
      | f1', f2' -> And(f1', f2')
    end

  | Or(f1, f2) -> 
    begin
      match eliminate_constants f1, eliminate_constants f2 with
      | C true, _ | _, C true -> C true
      | C false, h | h, C false -> h 
      | f1', f2' -> Or(f1', f2')
    end

  | Imp(f1, f2) -> 
    begin 
      match eliminate_constants f1, eliminate_constants f2 with
      | C false, _ | _, C true -> C true
      | C true, h -> h
      | f1', C true -> Not f1'
      | f1', f2' -> Imp(f1', f2')
    end

  | Not f1 -> 
    begin
      match eliminate_constants f1 with
      | C b -> C (not b)
      | f1' -> Not f1'
    end
  
  | _ -> f

(* Substitute a formula into another formula *)
let rec substitute f i g = 
  match f with
  | V j when j = i -> g
  | And(f1, f2) -> And(substitute f1 i g, substitute f2 i g)
  | Or(f1, f2) -> Or(substitute f1 i g, substitute f2 i g)
  | Imp(f1, f2) -> Imp(substitute f1 i g, substitute f2 i g)
  | _ -> f

(* Type for decision tree nodes used in the decision tree method *)
type decision = 
  | Leaf of bool          (* Leaf node containing a boolean value *)
  | Node of int * decision * decision  (* Internal node with a variable index and two subtrees *)

(* Find the minimum variable index in a formula *)
let rec min_var f = 
  match f with
  | C _ -> max_int
  | V i -> i
  | And(f1, f2) | Or(f1, f2) | Imp(f1, f2) -> min (min_var f1) (min_var f2)
  | Not f1 -> min_var f1 

(* Build a decision tree from a formula *)
let rec build_tree f = 
  match eliminate_constants f with
  | C b -> Leaf b
  | f' -> 
    let i = min_var f in
    let f_bot = substitute f i (C false) in
    let f_top = substitute f i (C true) in
    Node(i, build_tree f_bot, build_tree f_top)

(* Check satisfiability of a formula using a decision tree *)
let rec satisfiable_via_tree f = 
  let rec aux t = 
    match t with
    | Leaf b -> b
    | Node(i, g, d) -> 
      (aux g) || (aux d)

  in aux (build_tree f)
