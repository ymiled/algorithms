type color =
 | Red
 | Black

type 'a bicolor =
  | Empty
  | Node of color * 'a bicolor * 'a * 'a bicolor


let rec height a =
  match a with
  | Empty -> 0
  | Node (_, left, _, right) -> 1 + max (height left) (height right)


(* We only need to consider one path since all paths have the same number of black nodes.
   We only traverse one path, so the complexity is O(h) *)

let rec black_height a =
  match a with
  | Empty -> 0
  | Node (c, left, _, _) ->
     (if c = Black then 1 else 0) + black_height left


let is_bst a =
  (* Checks if a is a binary search tree and returns its minimum and maximum. We
     assume that a is not empty *)
  let rec check a =
    match a with
    | Empty -> failwith "Impossible: implementation error"
    | Node (_, Empty, e, Empty) -> true, e, e
    | Node (_, Empty, e, right) ->
       let is_bst_right, min_right, max_right = check right in
       (is_bst_right && e <= min_right, e, max_right)
    | Node (_, left, e, Empty) ->
       let is_bst_left, min_left, max_left = check left in
       (is_bst_left && max_left <= e, min_left, e)
    | Node (_, left, e, right) ->
       let is_bst_right, min_right, max_right = check right in
       let is_bst_left, min_left, max_left = check left in
       (is_bst_right && is_bst_left && max_left <= e && e <= min_right, min_left, max_right)
  in
  a = Empty || let result, _, _ = check a in result

let is_red_black a =
  (* Checks if a is red-black knowing the color of its parent
     and also returns its black height *)
  let rec check a parent_color =
    match a with
    | Empty -> true, 0
    | Node (c, left, _, right) ->
       let ok_left, black_height_left = check left c in
       let ok_right, black_height_right = check right c in
       ((parent_color = Black || c = Black) && ok_left && ok_right && black_height_left = black_height_right),
       (if c = Black then 1 else 0) + black_height_left
  in
  fst (check a Red)


let fix_red_nodes tree =
  match tree with
  | Node (Black, Node (Red, Node (Red, a, x, b), y, c), z, d)
    | Node (Black, Node (Red, a, x, Node (Red, b, y, c)), z, d)
    | Node (Black, a, x, Node (Red, b, y, Node (Red, c, z, d)))
    | Node (Black, a, x, Node (Red, Node (Red, b, y, c), z, d))
    -> Node (Red, Node (Black, a, x, b), y, Node (Black, c, z, d))
  | _ -> tree


let insert x a =
  let rec insert_and_fix a =
    match a with
    | Empty -> Node (Red, Empty, x, Empty)
    | Node (c, left, e, right) ->
       if x <= e then
         fix_red_nodes (Node (c, insert_and_fix left, e, right))
       else
         fix_red_nodes (Node (c, left, e, insert_and_fix right))
  in
  match insert_and_fix a with
  | Node (_, left, e, right) -> Node (Black, left, e, right)
  | Empty -> failwith "impossible"


let test n =
  let build_rbt n =
    let rec add_from k acc =
      if k > n then acc
      else add_from (k + 1) (insert k acc)
    in
    add_from 1 Empty
  in
  let rbt_test = build_rbt n in
  assert (is_bst rbt_test && is_red_black rbt_test);
  Printf.printf "%d : %d %d\n" n (height rbt_test) (black_height rbt_test)

