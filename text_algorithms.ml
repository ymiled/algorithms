(* Calculate the rightmost positions of characters in the given string *)
let calculate_rightmost_positions s = 
  let rightmost_positions = Array.make 256 (-1) in
  for i = 0 to String.length s - 1 do
    rightmost_positions.(int_of_char s.[i]) <- i
  done;
  rightmost_positions

(* Boyer-Moore-Horspool string search algorithm *)
let boyer_moore_horspool text pattern = 
  let len_text = String.length text in 
  let len_pattern = String.length pattern in
  let rightmost_positions = calculate_rightmost_positions pattern in
  let rec all_matches start i =
    (* Compare the pattern and the text substring from the end of the pattern *)
    if i = -1 then start :: (all_matches (start + 1) (len_pattern - 1)) (* If the entire pattern is matched *)
    else if start + i >= len_text then []  (* Pattern does not fit in the remaining text *)
    else if text.[start + i] = pattern.[i] then all_matches start (i - 1) (* Characters match, move to the previous character *)
    else 
      let rightmost = rightmost_positions.(int_of_char text.[start + i]) in   
      (* Shift by max(1, i - rightmost) where rightmost is the rightmost position of text[start + i] *)
      if i > rightmost then all_matches (start + i - rightmost) (len_pattern - 1)
      else all_matches (start + 1) (len_pattern - 1)

  in all_matches 0 (len_pattern - 1) 

(* Recursive function to compute x raised to the power of n *)
let rec power x n = 
  if n = 0 then 1 
  else if n mod 2 = 0 then 
    let acc = power x (n / 2) in acc * acc
  else 
    let acc = power x ((n - 1) / 2) in x * acc * acc

(* Check if the substring text[i:j] is equal to pattern *)
let equal pattern text i j = 
  (* Assumes i < j *)
  let result = ref true in
  let k = ref i in
  while !result && !k < j do 
    if text.[!k] != pattern.[!k] then result := false
    else incr k 
  done;
  !result
  
(* Rabin-Karp string search algorithm *)
let rabin_karp text pattern base prime = 
  (* base is the base for hashing, prime is a large prime number for modulo operations *)
  let n = String.length text in
  let k = String.length pattern in
  if k > n then []
  else
    let target_hash = ref 0 in
    let current_hash = ref 0 in
    let base_power = (power base (k - 1)) mod prime in
    let occurrences = ref [] in
    for i = 0 to k - 1 do
      target_hash := (base * !target_hash + (int_of_char pattern.[i])) mod prime;
      current_hash := (base * !current_hash + (int_of_char text.[i])) mod prime
    done;
    for i = 0 to n - k do 
      if !current_hash = !target_hash && equal pattern text i (i + k) then occurrences := i :: !occurrences;
      if i + k < n then
        current_hash := (base * (!current_hash - base_power * (int_of_char text.[i])) + (int_of_char text.[i + k])) mod prime;
    done;
    !occurrences
