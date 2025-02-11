(* This code provides solutions to problems related to subsequences in lists.
   Specifically, it includes functions to:
   - Check if a list is in strictly increasing order.
   - Generate all prefixes of lists.
   - Compute all possible subsequences of a list.
   - Find the length of the longest increasing subsequence (naively and dynamically).
   - Retrieve the longest increasing subsequence using dynamic programming. *)

let is_increasing l = (List.sort (fun x y -> y - x) l) = l

let prefix x l = 
  List.map (fun y -> x :: y) l 

let subsequences s = 
  let rec aux s acc = 
    match s with
    |[] -> acc
    |x :: xs -> aux xs ((List.map (fun l -> x :: l) acc) @ acc)
  in aux (List.rev s) [[]]

let naive_longest_increasing_seq s = 
  let all_increasing_seq = List.filter is_increasing (subsequences s) in
  let rec aux max_len l =
    match l with
    |[] -> max_len
    |l1 :: rest -> 
        let len = List.length l1 in 
        if len > max_len then aux len rest 
        else aux max_len rest 
  in aux 0 all_increasing_seq

let dyn_aux s = 
  let n = Array.length s in
  let lengths = Array.make n 0 in 
  for i = 0 to n - 1 do 
    let max_len = ref 1 in
    for k = 0 to i - 1 do 
      if s.(k) <= s.(i) then max_len := max !max_len (lengths.(k) + 1)
    done;
    lengths.(i) <- !max_len
  done;
  lengths

let index_and_max arr = 
  let max_index = ref 0 in
  for i = 1 to Array.length arr - 1 do 
    if arr.(i) > arr.(!max_index) then max_index := i
  done;
  !max_index, arr.(!max_index)

let dynamic_longest_increasing_seq s = 
  snd (index_and_max (dyn_aux s))

let dynamic_subsequence s = 
  let length_table = dyn_aux s in
  let last_index, length = index_and_max length_table in
  let subseq = Array.make length s.(last_index) in
  let k = ref (last_index - 1) in
  let to_choose = ref (length - 1) in
  while !to_choose > 0 do
    (* Traverse the array to the left, choosing an element where the length matches 
       the number of elements left to choose and the value is less than the last chosen element *)
    if length_table.(!k) = !to_choose && s.(!k) <= subseq.(!to_choose) then
      begin
        decr to_choose;
        subseq.(!to_choose) <- s.(!k)
      end;
    decr k
  done;
  subseq
