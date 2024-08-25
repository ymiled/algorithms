type graph = (int * float) list array 

let swap i j tas indices =
  let u, v = tas.(i), tas.(j) in
  tas.(i) <- v;
  tas.(j) <- u;
  indices.(u) <- j;
  indices.(v) <- i


let rec remonte i tas indices dist = 
  let pere = i / 2 in
  if i = 1 then ()
  else 
    if dist.(tas.(pere)) > dist.(tas.(i)) then
      begin
        swap i pere tas indices;
        remonte pere tas indices dist
      end


let rec descend i tas indices dist = 
  let fg = 2 * i in
  let fd = 2 * i + 1 in
  let argmin j k = 
    if k < tas.(0) && dist.(tas.(k)) < dist.(tas.(j)) then k 
    else j
  in 
  let j = argmin (argmin i fg) fd in
  if j <> i then
    (swap i j tas indices;
    descend i tas indices dist)


let push elt tas indices dist = 
  tas.(0) <- tas.(0) + 1;
  tas.(tas.(0)) <- elt;
  indices.(elt) <- tas.(0);
  remonte tas.(0) tas indices dist


let pop tas indices dist = 
  let x = tas.(1) in
  swap 1 tas.(0) tas indices;
  tas.(0) <- tas.(0) - 1;
  descend 1 tas indices dist;
  x 

let is_empty tas = 
  tas.(0) = 0

let relacher u v w tas dist indices h pere = 
  match dist.(u), dist.(v) with
  | du, infinity -> 
    dist.(v) <- du +. w +. h.(v);
    pere.(v) <- u;
    push v tas indices dist

  | du, dv when dv > du +. w -> 
    dist.(v) <- du +. w +. h.(v);
    pere.(v) <- u;
    remonte indices.(v) tas indices dist
    
  | _ -> failwith"impossible"

exception Found

let astar source but h g = (* h est l'heuristique *)
  let n = Array.length g in
  let tas = Array.make n 0 in
  let dist = Array.make n infinity in
  let indices = Array.make n (-1) in
  let pere = Array.make n (-1) in
  dist.(source) <- 0.;
  push source tas indices dist;
  pere.(source) <- source;
  try 
    while not(is_empty tas) do 
      let u = pop tas indices dist in
      if u = but then raise Found
      else List.iter (fun (v, w) -> relacher u v w tas dist indices h pere) g.(u)
    done;
    infinity
  with
  | Found -> dist.(but)



