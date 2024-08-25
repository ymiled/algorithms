type regexp =
  | Empty
  | Epsilon
  | Lettre of char
  | Union of regexp * regexp
  | Concat of regexp * regexp
  | Kleene of regexp

let rec is_empty e =
  match e with
  | Empty -> true
  | Epsilon -> false
  | Lettre(_) -> false
  | Union(e1, e2) -> is_empty e1 && is_empty e2
  | Concat(e1, e2) -> is_empty e1 || is_empty e2
  | Kleene(_) -> false
    
(* Complexity is O(n), where n is the depth of the expression *)

(* Function to check if a regular expression can generate the empty string *)
let rec has_eps e =
  match e with
  | Empty -> false
  | Epsilon -> true
  | Lettre(_) -> false
  | Union(e1, e2) -> has_eps e1 || has_eps e2
  | Concat(e1, e2) -> has_eps e1 && has_eps e2
  | Kleene(_) -> true

(* Complexity is O(n), where n is the depth of the expression *)

(* Function to check if a regular expression can generate the empty string (considering the possibility of epsilon) *)
let rec is_eps e =
  match e with
  | Empty -> false
  | Epsilon -> true
  | Lettre(_) -> false
  | Union(e1, e2) -> 
      (is_eps e1 && is_eps e2) || (is_eps e1 && is_empty e2) || (is_empty e1 && is_eps e2)
  | Concat(e1, e2) -> is_eps e1 && is_eps e2
  | Kleene(e1) -> is_eps e1 || is_empty e1

(* L(expr1) = {a} . {b}* . {a}* *)
let expr1 = Concat(Concat(Lettre('a'), Kleene(Lettre('b'))), Lettre('a'))

(* Function to compute the residual of a regular expression with respect to a character *)
let rec residual a e =
  match e with
  | Empty | Epsilon -> Empty
  | Lettre e       -> if a = e then Epsilon else Empty 
  | Union(e1, e2)  -> Union(residual a e1, residual a e2)
  | Concat(e1, e2) -> Union((if has_eps e1 then residual a e2 else Empty), Concat(residual a e1, e2))
  | Kleene e       -> Concat(residual a e, Kleene e)

(* Function to check if a string belongs to the language described by a regular expression *)
let list_of_char u = List.rev(String.fold_left (fun acc x -> x::acc) [] u)

let contains u e =
  (* First compute the residual language of e with respect to the string u,
     then check if epsilon belongs to the obtained language *)
  let rec aux l exp =
    match l with
    | []    -> has_eps exp
    | x::xs -> let new_exp = residual x exp in aux xs new_exp
  in aux (list_of_char u) e

(* Alternative function to check if a string belongs to the language described by a regular expression *)
let contains_bis mot regexp =
  String.fold_right residual mot regexp |> has_eps
