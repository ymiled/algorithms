let char_list_of_string u = List.rev (String.fold_left (fun acc c -> c::acc) [] u)


type automaton = {
  num_states : int;
  initial : int;
  final_states : bool array;
  transitions : int array array
}

let example = 
  let final_states = Array.make 4 false in
  final_states.(0) <- true;
  let transitions = Array.make_matrix 4 128 2 in
  transitions.(0).(int_of_char 'a') <- 1;
  transitions.(0).(int_of_char 'b') <- 0;
  transitions.(1).(int_of_char 'a') <- 0;
  transitions.(1).(int_of_char 'b') <- 1;

  {num_states = 4; initial = 0; final_states = final_states; transitions = transitions}


let delta automaton q s =
  automaton.transitions.(q).(int_of_char s)

let delta_star automaton q u =
  let n = String.length u in
  let pos = ref q in
  for i = 0 to n-1 do
    pos := delta automaton !pos u.[i]
  done;
  !pos

let delta_star_2 automaton q u =
  let list = char_list_of_string u in
  let rec aux acc l =
    match l with
    |[]    -> acc
    |x::xs -> aux (delta automaton acc x) xs    
  in aux q list

let delta_star_3 automaton q u =
  List.fold_left (fun acc x -> delta automaton acc x) q u

let recognized automaton u =
  let i = delta_star_2 automaton (automaton.initial) u in
  automaton.final_states.(i)  

let rec explore e automaton visited =
  visited.(e) <- true;
  Array.iter (fun x -> if not visited.(x) then explore x automaton visited) automaton.transitions.(e)

let accessible automaton = 
  let n = automaton.num_states in
  let visited = Array.make n false in
  explore automaton.initial automaton visited; 
  let rec list_of_visited i =
    if i >= automaton.num_states then []
    else if visited.(i) then i::(list_of_visited (i + 1))
    else list_of_visited (i + 1)
  in list_of_visited 0

let accessible_2 automaton =
  let n = automaton.num_states in
  let visited = Array.make n false in   
  explore automaton.initial automaton visited;
  let l = List.init n (fun i -> i) in
  List.filter (fun i -> visited.(i)) l

type automaton_2 = {
  num_states : int;
  initial : int;
  final_states : bool array;
  transitions : (char * int) list array  (* array of n elements which are lists, each list at index i contains char * int 
                                          e.g., if list i contains ('a', j) then there is a transition from i to j on reading 'a' *)
}


let example = 
  let num_states = 2 in
  let initial = 0 in
  let final_states = Array.make 2 false in
  final_states.(0) <- true;
  let transitions = Array.make 2 [] in
  transitions.(0) <- [('a', 1); ('b', 0)] ;
  transitions.(1) <- [('a', 0); ('b', 1)];
  {num_states = num_states; initial = initial; final_states = final_states; transitions = transitions}

exception Stuck

let delta_2 (automaton : automaton_2) q s =
  let neighbors = automaton.transitions.(q) in
  let rec aux list =
    match list with
    |[]            -> raise Stuck
    |(c, state)::xs -> if c = s then state else aux xs
  in aux neighbors 

let delta_3 automaton q s = 
  List.assoc s automaton.transitions.(q)

let new_delta_star automaton q u =
  String.fold_left (fun acc x -> delta_3 automaton acc x) (automaton.initial) u

let new_recognized (automaton: automaton_2) u =
  try automaton.final_states.(new_delta_star automaton (automaton.initial) u) with
  |Stuck -> false

(* The second representation is better suited for non-deterministic automata because you can have a 
  list containing multiple states reachable by reading a letter, unlike the first representation which uses 
  a matrix where each cell is reserved for a single state accessible by reading a certain letter.
  You just need to change initial to an array of initial states *)

type general_automaton = {
  num_states : int;
  initial : bool array;
  final_states : bool array;
  transitions : (char * int) list array
}

let aba_suffix = 
  let num_states = 4 in
  let initial = Array.make num_states false in
  initial.(0) <- true;
  let final_states = Array.make num_states false in
  final_states.(3) <- true;
  let transitions = Array.make num_states [] in
  
  transitions.(0) <- ('b', 0)::('a', 1)::transitions.(0);
  transitions.(1) <- ('b', 2)::transitions.(1);
  transitions.(2) <- ('a', 3)::transitions.(2);
  transitions.(3) <- ('a', 3)::('b', 3)::transitions.(3);
  {num_states = num_states; initial = initial; final_states = final_states; transitions = transitions}


let int_to_array int size = (* decompose int into binary representation, e.g., 13 = 2⁰ + 2² + 2³ *)
  let array = Array.make size false in
  let x = ref int in
  for i = 0 to size-1 do 
    if !x mod 2 = 1 then array.(i) <- true;
    x := !x / 2
  done;
  array

let array_to_int array = 
  let int_value = ref 0 in 
  let base = ref 1 in
  let size = Array.length array in
  for i = 0 to size-1 do
    if array.(i) then 
      int_value := !int_value + !base;
    base := 2 * !base
  done;
  !int_value


let rec power x n =
  if n = 0 then 1 
  else
    let acc = power x (n / 2) in
    if n mod 2 = 1 then x * acc * acc
    else acc * acc

let terminal_state state n final_states =  (* n is the size of the array representing the integer state *)
  let array = int_to_array state n in
  let i = ref 0 in
  while !i < n && not (array.(!i) && final_states.(!i)) do
    incr i
  done;
  !i < n

let rec update arrival letter trans =
  match trans with
  |[]               -> ()
  |(c, state)::rest -> 
    if not (c = letter) then update arrival letter rest
    else arrival.(state) <- true; update arrival letter rest

let determinize (auto_nd: general_automaton) : automaton =
  let n = auto_nd.num_states in
  let num_states = power 2 n in
  let initial = array_to_int auto_nd.initial in
  let final_states = Array.make num_states false in
  for state = 0 to num_states-1 do
    if terminal_state state n auto_nd.final_states then final_states.(state) <- true
  done;
  let transitions = Array.make_matrix num_states 128 0 in 
  for state = 0 to num_states-1 do
    for letter = 0 to 127 do
      let arrival = Array.make n false in
      let array = int_to_array state n in
      for i = 0 to n-1 do
        if array.(i) then update arrival (char_of_int letter) auto_nd.transitions.(i)
      done;
      transitions.(state).(letter) <- (array_to_int arrival);
    done
  done;
  {
    num_states = num_states;
    initial = initial; 
    final_states = final_states; 
    transitions = transitions
  }
