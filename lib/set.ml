type 'a t = ('a, unit) Map.t

let empty ?cmp () = Map.empty ?cmp ()
let singleton ?cmp x = Map.singleton ?cmp x ()

let of_list ?cmp xs =
  Stdlib.List.fold_left (fun s x -> Map.assoc s x ()) (empty ?cmp ()) xs

let of_array ?cmp xs =
  Stdlib.Array.fold_left (fun s x -> Map.assoc s x ()) (empty ?cmp ()) xs

let of_seq ?cmp xs =
  Stdlib.Seq.fold_left (fun s x -> Map.assoc s x ()) (empty ?cmp ()) xs

let set ?cmp xs = of_list ?cmp xs
let hash_set ?cmp xs = of_list ?cmp xs
let sorted_set ?cmp xs = of_list ?cmp xs
let sorted_set_by cmp xs = of_list ~cmp xs

let cmp = Map.cmp
let count = Map.count
let empty_ = Map.empty_
let is_empty = empty_
let contains_ = Map.contains_
let mem x s = Map.contains_ s x

let conj s x = Map.assoc s x ()
let disj = Map.dissoc
let into s xs = Stdlib.Seq.fold_left conj s xs

let union a b =
  (* fold the smaller set into the larger *)
  let fold_into dst src =
    Stdlib.List.fold_left
      (fun acc (k, ()) -> Map.assoc acc k ())
      dst (Map.entries src)
  in
  if count a >= count b then fold_into a b else fold_into b a

let intersection a b =
  Map.filter (fun k () -> Map.contains_ b k) a

let difference a b = Map.filter (fun k () -> not (Map.contains_ b k)) a
let subset_ a b =
  Stdlib.List.for_all (fun (k, ()) -> Map.contains_ b k) (Map.entries a)
let superset_ a b = subset_ b a

let select p s = Map.filter (fun k () -> p k) s
let filter = select
let remove p s = filter (fun x -> not (p x)) s

let map ?(cmp = Stdlib.compare) f s =
  of_seq ~cmp (Stdlib.Seq.map f (Map.keys s))

let min_elt = Map.min_key
let max_elt = Map.max_key
let first = min_elt
let last = max_elt

let slice ?from_ ?to_ s = Map.slice ?from_ ?to_ s
let subseq ?from_ ?to_ s = Map.keys (Map.slice ?from_ ?to_ s)
let rsubseq ?from_ ?to_ s =
  Stdlib.Seq.map fst (Map.rseq (Map.slice ?from_ ?to_ s))

let iter (f @ local) (s @ local) = let () = Map.iter (fun k () -> f k) s in ()
let fold (f @ local) acc (s @ local) = let r = Map.fold (fun acc k () -> f acc k) acc s in r
let every_ (p @ local) (s @ local) = let r = Map.every_ (fun k () -> p k) s in r
let for_all = every_
let some p s = Option.map fst (Map.some (fun k () -> p k) s)
let exists (p @ local) (s @ local) = not (every_ (fun k -> not (p k)) s)
let find = some
let count_matching (p @ local) (s @ local) =
  let r = Map.count_matching (fun k () -> p k) s in
  r

let seq = Map.keys
let to_seq = Map.keys

let rseq s = Stdlib.Seq.map fst (Map.rseq s)
let to_list s = Stdlib.List.map fst (Map.to_list s)
let to_vec s =
  let entries = Map.to_vec s in
  Vec.init (Vec.length entries) (fun i -> fst (Vec.nth entries i))

let equal a b = Map.equal ~eq:(fun () () -> true) a b

(* borrow variants *)
