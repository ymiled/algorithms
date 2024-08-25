let swap i j tab =
  let tmp = tab.(i) in 
  tab.(i) <- tab.(j);
  tab.(j) <- tmp

let knuth tab = 
  let n = Array.length tab in
  for i = 0 to n - 1 do 
    let j = Random.int (i + 1) in
    swap i j tab
  done;
  tab