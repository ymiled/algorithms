let no_conflict sol = 
  (* Check if there is a conflict between the last queen and the other queens
     that have been placed *)
  let k = Array.length sol in 
  let no_problem = ref true in
  let i = ref 0 in
  while !i < k - 1 && !no_problem do
    no_problem := (abs (sol.(k - 1) - sol.(!i)) <> abs (k - 1 - !i)) && (sol.(!i) <> sol.(k - 1));
    incr i
  done; 
  !no_problem


let rec n_queens n = 
  let rec aux sol = 
    if not (no_conflict sol) then 0 
    else 
      let k = Array.length sol in
      if k = n then 1 
      else 
        begin
          let count = ref 0 in
          for i = 0 to n - 1 do (* i is the column for the queen to be placed *)
            (* Add the (k+1)th queen to column i *)
            let new_sol = Array.init (k + 1) (fun j -> if j = k then i else sol.(j)) in 
            count := !count + (aux new_sol)
          done;
          !count
        end 
  in
  aux [||]
