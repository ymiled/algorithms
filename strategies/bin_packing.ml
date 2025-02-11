(* Given n objects of volumes x0 , . . . , xn−1 , and boxes of capacity C, the aim is to distribute the objects in k boxes so that the sum 
of volumes always remains less than the capacity, while minimizing the number k of boxes used *)
type instance = int * int list

type box = { 
  vol_dispo : int;
  elements : int list
}

let next_fit instance = 
  let capacity, items = instance in
  let rec aux remaining current = 
    match remaining with 
    | [] -> [current]
    | x :: xs -> 
      if x <= current.vol_dispo then 
        let updated_current = 
          { vol_dispo = current.vol_dispo - x; elements = x :: current.elements } in
        aux xs updated_current
      else 
        let new_box = { vol_dispo = capacity; elements = [] } in
        current :: (aux remaining new_box)
  in
  let empty = { vol_dispo = capacity; elements = [] } in
  aux items empty  


let first_fit instance = 
  let capacity, items = instance in
  let rec process_elem x boxes = 
    match boxes with
    | l :: next -> 
      if l.vol_dispo >= x then 
        let updated_box = { vol_dispo = l.vol_dispo - x; elements = x :: l.elements } in
        updated_box :: next
      else l :: (process_elem x next)
    | [] -> let new_box = { vol_dispo = capacity - x; elements = [x] } in [new_box]
  in
  let rec aux remaining boxes = 
    match remaining with
    | [] -> boxes
    | x :: xs -> aux xs (process_elem x boxes)
  in 
  aux items []

let first_fit_decreasing instance = 
  let capacity, items = instance in
  let sorted = List.sort (fun x y -> y - x) items in
  first_fit (capacity, sorted)

let ex1 = next_fit (10, [2; 5; 4; 7; 1; 3; 8])
let ex2 = first_fit_decreasing (10, [2; 5; 4; 7; 1; 3; 8])

let empty_box capacity =
  { vol_dispo = capacity; elements = [] }

let add_object x box =
  assert (box.vol_dispo >= x);
  { vol_dispo = box.vol_dispo - x; elements = x :: box.elements }

let singleton capacity x =
  add_object x (empty_box capacity)

let solve (capacity, object_list) =
  let objects = Array.of_list object_list in
  Array.sort (fun x y -> y - x) objects;
  let n = Array.length objects in
  let first_guess = first_fit_decreasing (capacity, object_list) in
  let best_boxes = ref (Array.of_list first_guess) in
  let best_k = ref (Array.length !best_boxes) in
  let boxes = Array.make !best_k (empty_box capacity) in
  let rec explore k next_object_index =
    if next_object_index = n then 
      begin
        best_k := k;
        best_boxes := Array.copy boxes
      end
    else if k < !best_k then 
      begin
        let x = objects.(next_object_index) in
        for i = 0 to k - 1 do
          if x <= boxes.(i).vol_dispo then
            begin
              let b = boxes.(i) in
              boxes.(i) <- add_object x b;
              explore k (next_object_index + 1);
              (* if we reach here, the final solution built 
                   was not the best, so we revert to the previous state, 
                   i.e., the moment we tried to insert x *)
              boxes.(i) <- b
            end
        done;
        (* if we reach here, it means x could not be inserted into existing boxes *)
        if k < !best_k - 1 then
          (* there is at least one box that remains empty and could lead
               to a better solution since k + 1 < !best_k *)
          begin
            boxes.(k) <- singleton capacity x;
            (* we inserted into a new position so we need to increase
                   k in the next recursive call: *)
            explore (k + 1) (next_object_index + 1);
            (* if we reach here, it means it did not lead to a better 
                   solution *)
            boxes.(k) <- empty_box capacity
          end
      end
  in
  explore 0 0;
  Array.to_list (Array.sub !best_boxes 0 !best_k)

