type graph = {nb_sommets : int; voisins : int -> int list}

exception Trouve of int array

let hamilton_depuis g x0 = 
  let ordre = Array.make g.nb_sommets (-1) in
  let voisins_libres x = List.filter (fun y -> ordre.(y) = - 1) (g.voisins x) in
  let rec explore k x = 
    ordre.(x) <- k;
    if k = g.nb_sommets - 1 then raise (Trouve ordre);
    List.iter (explore (k + 1)) (voisins_libres x);
    ordre.(x) <- -1 
  in
  try
    explore 0 x0;
    None
  with
  |Trouve _ -> Some ordre
  

let graphe_cavalier n m = 
  let indice i j = i * m + j in 
  (* on numérote les cases de 0 à m-1 sur la premièreligne, 
     de m à 2m - 1 sur la deuxième, etc*)
  let coord s = (s / m, s mod m) in
  let voisins s = 
    let i, j = coord s in
    let ok x y = 
      0 <= x && x <n && 0 <= y && y < m 
    in let u = ref [] in
    let deltas = [(1, 2); (-1, 2); (1, -2); (-1, -2)] in
    let ajoute (dx, dy) = 
      if ok (i + dx) (j + dy) then u := indice (i + dx) (j + dy) :: !u;
      if ok (i + dy) (j + dx) then u := indice (i + dy) (j + dx) :: !u
    in
    List.iter ajoute deltas;
    !u 
  in {nb_sommets = n * m; voisins = voisins}


let hamilton_opt_depuis g x0 =
  let ordre = Array.make g.nb_sommets (-1) in
  let voisins_libres x = 
    List.filter (fun y -> ordre.(y) = -1) (g.voisins x) in
  let nb_voisins_libres x = 
    List.length (voisins_libres x)
  in 
  let rec explore k x = 
    ordre.(x) <- k;
    if k = g.nb_sommets - 1 then raise (Trouve ordre); 
    let voisins_tries = List.sort (fun y z -> nb_voisins_libres z - nb_voisins_libres y) (voisins_libres x) in
    List.iter (fun v -> explore (k + 1) v) voisins_tries;
    ordre.(x) <- -1
  in try
    explore 0 x0;
    None
  with
  |Trouve _ -> Some ordre


  
(* tableau auto_référents *)
type 'a reponse = 
  |Refus 
  |Accepte of 'a 
  |Partiel of 'a 

type 'a probleme = 
  {accepte : 'a -> 'a reponse;
  enfants : 'a -> 'a list;
  initiale : 'a}

let enumere probleme = 
  let rec backtrack candidat = 
    match probleme.accepte candidat with
    |Refus -> []
    |Accepte solution -> [solution]
    |Partiel c' -> 
      let rec aux enfants = 
        match enfants with
        |[] -> []
        |e :: es -> backtrack e @ aux es in
      aux (probleme.enfants c') in 
  backtrack probleme.initial


let occurences t n = 
  let occs = Array.make n 0 in
  Array.iter (fun x -> occ.(x) <- occ.(x) + 1) t;
  occs

let enfants_auto n t = 
  let f i = Array.append t [| i |] in
  List.init n f


let accepte_auto n t = 
  if Array.lenght t = n then 
    let occs = occurences t in
    if occs = t then Accepte t 
    else Refus
  else Partiel t 


let autoreferents_brute n = 
  {accepte = accepte_auto n;
  enfants = enfants_auto n;
  initiale = [| |]}


(* élagage : *)
let accepte_auto_bis n t = 
  let exception Echec in
  let k = Array.length t in
  if n = k then accepte_auto n t 
  else 
    try 
    let somme = Array.fold_left (+) 0 t in
    if somme > n then raise Echec;
    let occs = occurences t in
    if k > 0 && somme + (n - k) - (t.(0) - occ.(0)) > n then raise Echec (* on est sûr que cela va dépasser n plus tard *)
    let dispo = ref (n - k) in
    for i = 0 to k-1 do 
      dispo := !dispo - t.(i) + occ.(i);
      if occs.(i) > t.(i) || !dispo < 0 then raise Echec;
    done;
    Partiel t 
  with
  Echec -> Refus
