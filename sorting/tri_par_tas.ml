(* TP13 MP2I (voir en bas le tri par tas) : *)
(* position suivante et précedente : *)

type path = bool list 

let rec incr p = 
  match p with
  |false :: p' -> true :: p' 
  |true :: p' -> false :: (incr p')
  |[] -> [false]

let next p = List.rev (incr (List.rev p))

let rec decr p = 
  match p with 
  |true :: p' -> false :: p'
  |false :: p' -> true :: (decr p')
  |[] -> failwith "chemin vide"

let prev p = List.rev (decr (List.rev p))

(* Tri par tas *)
(* Attention ici on étudie un tas max !!! *)

let tri_par_tas t =

  (* Échange `t.(i)` et `t.(j)` *)
  let swap i j =
  let tmp = t.(i) in
  t.(i) <- t.(j);
  t.(j) <- tmp
  in

  (* Percolation (vers le bas) de `i` dans `t[0..last]` *)
let rec sift_down i last =
  let left = 2 * i + 1 in
  let right = 2 * i + 2 in
  let largest = ref i in
  if left <= last && t.(left) > t.(i) then
    largest := left;
  if right <= last && t.(right) > t.(!largest) then
    largest := right;
  if !largest <> i then begin
      swap i !largest;
      sift_down !largest last
  end
  in

  (* Extraction du maximum de `t[0..last]` que l'on place en `last` *)
  let extract last =
    swap 0 last;
    sift_down 0 (last - 1) in

  (* Insertion de tous les noeuds dans le tas *)
  let n = Array.length t in
  for i = (n - 1) / 2 downto 0 do
    sift_down i (n - 1)
  done;

  (* Extractions successives du maximum *)
  for last = n - 1 downto 1 do
    extract last
  done
