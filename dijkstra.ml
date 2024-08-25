(* This code implements Dijkstra's algorithm for finding the shortest paths in a graph.
   It uses a priority queue to efficiently extract the minimum distance node and update distances. *)

   type rbar = 
   |R of float   (* Represents a real number distance *)
   |Inf          (* Represents infinity, used for initial distances *)
 
 (* Determines if one distance is less than another *)
 let inferior r r' =
   match r, r' with
   | Inf, _ -> false
   | _, Inf -> true
   | R x, R y -> x < y
 
 (* Computes the parent, left child, and right child indices in a binary heap *)
 let parent i = i / 2
 let left_child i = 2 * i 
 let right_child i = 2 * i + 1
 
 (* Checks if the priority queue (heap) is empty *)
 let is_heap_empty heap = heap.(0) = 0
 
 (* Swaps two elements in the heap and updates their indices *)
 let swap i j heap index =
   let u, v = heap.(i), heap.(j) in
   heap.(i) <- v;
   heap.(j) <- u;
   index.(u) <- j;
   index.(v) <- i
 
 (* Moves an element up the heap to maintain the heap property *)
 let rec heapify_up i heap index dist = 
   let p = parent i in
   if i = 1 then ()
   else if inferior dist.(heap.(i)) dist.(heap.(p)) then 
     begin
       swap i p heap index;
       heapify_up p heap index dist 
     end
 
 (* Moves an element down the heap to maintain the heap property *)
 let rec heapify_down i heap index dist = 
   let argmin j k = 
     if k <= heap.(0) && inferior dist.(k) dist.(j) then k else j
   in 
   let j = argmin i (argmin (left_child i) (right_child i)) in
   if i <> j then
     begin
       swap i j heap index;
       heapify_down j heap index dist
     end
 
 (* Inserts an element into the priority queue and updates the heap *)
 let insert heap dist index s = 
   heap.(0) <- heap.(0) + 1;
   heap.(heap.(0)) <- s;
   index.(s) <- heap.(0);
   heapify_up heap.(0) heap index dist
 
 (* Extracts the minimum element from the priority queue and updates the heap *)
 let extract_min heap dist index =
   let min = heap.(1) in
   swap 1 heap.(0) heap index;
   heap.(0) <- heap.(0) - 1;
   heapify_down 1 heap index dist;
   min
 
 (* Relaxes the edges of a node and updates distances and predecessors *)
 let relax heap dist index parent u (v, w) =
   match dist.(u), dist.(v) with
   |R du, Inf -> 
     dist.(v) <- R (du +. w);
     parent.(v) <- u;
     insert heap dist index v
   |R du, R dv when dv > du +. w ->
     dist.(v) <- R (du +. w);
     parent.(v) <- u;
     heapify_up v heap index dist
   |_ -> ()
 
 (* Runs Dijkstra's algorithm to find shortest paths from a start node *)
 let dijkstra graph start_node = 
   let n = Array.length graph in
   let parent = Array.make n (-1) in
   let dist = Array.make n Inf in
   let heap = Array.make n 0 in
   let index = Array.make n (-1) in
   dist.(start_node) <- R 0.;
   parent.(start_node) <- start_node;
   insert heap dist index start_node;
   while not (is_heap_empty heap) do
     let u = extract_min heap dist index in
     List.iter (relax heap dist index parent u) graph.(u)
   done;
   dist, parent
 
 (* Reconstructs the shortest path from the start node to node u *)
 let shortest_path parent u =
   let rec build_path u path = 
     if u = parent.(u) then (u :: path)
     else build_path (parent.(u)) (u :: path)
   in build_path u []
 