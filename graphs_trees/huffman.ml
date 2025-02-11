
(** Module Hashtbl (dictionnaires) :
        https://ocaml.org/api/Hashtbl.html
*)
(** Module String (chaînes de caractères) :
        https://ocaml.org/api/String.html
*)

(** Fonctions d'affichage **)

(* Pour afficher le contenu des tables d'associations *)
let print_values c i =
  print_char c;
  print_string " -> ";
  print_int i;
  print_newline ()
;;

let print_huffman c s =
  print_char c;
  print_string " -> ";
  print_string s;
  print_newline ()
;;

let display print_func hash_tbl =
  print_newline ();
  print_string "----------";
  print_newline ();
  Hashtbl.iter print_func hash_tbl;
  print_string "----------"
;;

(** Implémentation d'une file de priorité **)

type huffman =
  | F of char |
  N of huffman * huffman
;;

(* File de priorité par tas-min *)
type 'a tas = {mutable free_idx : int; tbl : 'a array};;
type couple = {weight : int; tree : huffman};;

let empty_couple = {weight = -1; tree = F ' '};;

(* ************************************************** *)
(* File de priorité à partir d'un tas-min *)
let swap a i j =
  let x = a.(i) in a.(i) <- a.(j) ; a.(j) <- x
;;

(* Constructeur d'un tas *)
let create_heap size =
  {free_idx = 0; tbl = Array.make size empty_couple};;

let is_empty h = h.free_idx = 0;;
let is_full h = h.free_idx = (Array.length h.tbl);;

(* Remontée de l'élément d'indice k pour reconstituer la structure de
   tas *)
let rec sift_up h = function
  | 0 -> ()
  | j ->
     let i = (j - 1) / 2 in
     if h.tbl.(i).weight > h.tbl.(j).weight then begin
       swap h.tbl i j;
       sift_up h i
       end
;;

(* Descente d'un élément d'indice k *)
let rec sift_down h = function
  | i when 2 * i + 1 >= h.free_idx - 1 -> ()
  | i ->
     let j = if (2 * i + 2 = h.free_idx - 1) || (h.tbl.(2 * i + 1).weight < h.tbl.(2 * i + 2).weight) then
               2 * i + 1
             else
               2 * i + 2
     in
     if h.tbl.(i).weight >= h.tbl.(j).weight then begin
         swap h.tbl i j;
         sift_down h j
       end
;;

(* Insertion aux feuilles d'une valeur dans un tas puis reconstitution
   du tas *)
let insert h value =
  if is_full h then
    failwith "insertion impossible -> tas plein"
  else
    let i = ref h.free_idx in
    begin
      h.free_idx <- !i + 1;
      h.tbl.(!i) <- value;
      sift_up h !i
    end
;;

(* Supression du minimum par permutation avec le dernier élément puis
   sift_down du nouveau premier élément *)
let take h =
  let n = h.free_idx in
  let mini = h.tbl.(0) in
  h.tbl.(0) <- h.tbl.(n-1);
  h.tbl.(n-1) <- empty_couple;
  sift_down h 0;
  h.free_idx <- (h.free_idx-1);
  mini
;;

(** Fonctions à implémenter **)

(* Question 1 : Dictionnaire des nombres d'occurrences *)
let nb_occ s =
  failwith "À implémenter"
;;

(* Question 2 : Arbre de Huffman *)
let make_huffman_tree s =
  failwith "À implémenter"
;;

(* Question 3 : Dictionnaire des codes de Huffman *)
let make_dic_huffman s =
  failwith "À implémenter"
;;

(* Question 4 : Encodage *)
let huffman_encode s huffman_tree =
  failwith "À implémenter"
;;

(* Question 5 : Décodage *)
let huffman_decode s_code huffman_tree =
  failwith "À implémenter"
;;

(* ************************************************** *)
(* let s = "scienceinformatique";; *)
let s = "abracadabra";;

let dic_nb_occ = nb_occ s;;
display print_values dic_nb_occ;;

make_huffman_tree s;;
let h_tree = fst (make_huffman_tree s);;

let dic_huffman = make_dic_huffman s;;
display print_huffman dic_huffman;;

let s_code = huffman_encode s h_tree;;
huffman_decode s_code h_tree;;
