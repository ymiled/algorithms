let sampling k a = 
  let n = Array.length a in
  if k < 0 || k > Array.length a then failwith "erreur"
  else 
    let r = Array.sub a 0 k in (* r = [|a0; a1; ...; a_k-1|] *)
    for i = k to n - 1 do 
      let j = Random.int (i + 1) in
      if j < k then 
        r.(j) <- a.(i)
    done;
    r

(* Sélection aléatoire online : *)

let random_element l = 
  let rec aux candidat n l = 
    match l with
    | [] -> candidat
    | x :: xs -> 
      if (Random.int (n + 1)) = 0 then aux x (n + 1) xs
      else aux candidat (n + 1) xs 
    in match l with
    | [] -> failwith "liste vide"
    | x :: xs -> aux x 1 xs


