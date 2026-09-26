type 'k comparator = 'k -> 'k -> int

(* A persistent map as a sorted, deduplicated (k, v) vector: binary search for
   lookups, rrbvec subvec/concat for insert/remove with structural sharing. *)
type ('k, 'v) t = { cmp : 'k comparator; entries : ('k * 'v) Vec.t }

let cmp m = m.cmp
let empty ?(cmp = Stdlib.compare) () = { cmp; entries = Vec.empty }
let singleton ?(cmp = Stdlib.compare) k v = { cmp; entries = Vec.singleton (k, v) }
let count m = Vec.count m.entries
let empty_ m = count m = 0
let is_empty = empty_

(* index of the first key >= k *)
let lower_bound m k =
  let rec go lo hi =
    if lo = hi then lo
    else
      let mid = (lo + hi) / 2 in
      if m.cmp (fst (Vec.nth m.entries mid)) k < 0 then go (mid + 1) hi
      else go lo mid
  in
  go 0 (count m)

(* (index, found) — index is the existing slot or the insertion point *)
let find_index m k =
  let i = lower_bound m k in
  ( i,
    i < count m && m.cmp (fst (Vec.nth m.entries i)) k = 0 )

let get m k =
  let i, found = find_index m k in
  if found then Some (snd (Vec.nth m.entries i)) else None

let get_or default m k =
  let i, found = find_index m k in
  if found then snd (Vec.nth m.entries i) else default

let find m k =
  let i, found = find_index m k in
  if found then Some (Vec.nth m.entries i) else None

let contains_ m k = snd (find_index m k)
let min_entry m = Vec.first m.entries
let max_entry m = Vec.last m.entries
let min_key m = Option.map fst (min_entry m)
let max_key m = Option.map fst (max_entry m)
let keys m = Stdlib.Seq.map fst (Vec.to_seq m.entries)
let vals m = Stdlib.Seq.map snd (Vec.to_seq m.entries)
let entries m = Vec.to_list m.entries
let to_list = entries
let to_seq m = Vec.to_seq m.entries
let seq = to_seq
let rseq m = Vec.rseq m.entries
let to_vec m = m.entries

let splice_insert entries i x =
  match (Vec.subvec entries 0 i, Vec.subvec entries i (Vec.length entries)) with
  | Some a, Some b -> Vec.concat (Vec.push_back a x) b
  | _ -> assert false

let splice_remove entries i =
  match
    (Vec.subvec entries 0 i, Vec.subvec entries (i + 1) (Vec.length entries))
  with
  | Some a, Some b -> Vec.concat a b
  | _ -> assert false

let assoc m k v =
  let i, found = find_index m k in
  if found then { m with entries = Rrbvec.set m.entries i (k, v) }
  else { m with entries = splice_insert m.entries i (k, v) }

let conj m (k, v) = assoc m k v

let dissoc m k =
  let i, found = find_index m k in
  if found then { m with entries = splice_remove m.entries i } else m

let update m k f = assoc m k (f (get m k))

let update_opt m k f =
  match f (get m k) with Some v -> assoc m k v | None -> dissoc m k

let update_vals m f =
  { m with entries = Vec.map (fun (k, v) -> (k, f v)) m.entries }

let map f m = update_vals m f

let map_kv f m =
  { m with entries = Vec.map (fun (k, v) -> (k, f k v)) m.entries }

let of_list ?(cmp = Stdlib.compare) pairs =
  Stdlib.List.fold_left
    (fun m (k, v) -> assoc m k v)
    (empty ~cmp ()) pairs

let of_array ?(cmp = Stdlib.compare) pairs =
  Stdlib.Array.fold_left
    (fun m (k, v) -> assoc m k v)
    (empty ~cmp ()) pairs

let of_seq ?(cmp = Stdlib.compare) pairs =
  Stdlib.Seq.fold_left
    (fun m (k, v) -> assoc m k v)
    (empty ~cmp ()) pairs

let sorted_map ?cmp pairs = of_list ?cmp pairs
let hash_map ?cmp pairs = of_list ?cmp pairs
let array_map ?cmp pairs = of_list ?cmp pairs

let zipmap ?(cmp = Stdlib.compare) ks vs =
  let rec go m ks vs =
    match (ks, vs) with
    | k :: ks', v :: vs' -> go (assoc m k v) ks' vs'
    | _ -> m
  in
  go (empty ~cmp ()) ks vs

let update_keys ?(cmp = Stdlib.compare) m f =
  of_seq ~cmp (Stdlib.Seq.map (fun (k, v) -> (f k, v)) (to_seq m))

let filter f m =
  { m with entries = Vec.filter (fun (k, v) -> f k v) m.entries }

let remove f m = filter (fun k v -> not (f k v)) m

let select_keys m ks =
  Stdlib.List.fold_left
    (fun acc k -> match get m k with Some v -> assoc acc k v | None -> acc)
    (empty ~cmp:m.cmp ()) ks

let merge a b =
  Stdlib.Seq.fold_left (fun m (k, v) -> assoc m k v) a (to_seq b)

let merge_with f a b =
  Stdlib.Seq.fold_left
    (fun m (k, v) ->
      match get m k with
      | Some old -> assoc m k (f old v)
      | None -> assoc m k v)
    a (to_seq b)

let into m s = Stdlib.Seq.fold_left conj m s
let iter f m = Vec.iter (fun (k, v) -> f k v) m.entries
let fold f acc m = Vec.fold_left (fun acc (k, v) -> f acc k v) acc m.entries
let fold_kv = fold
let reduce_kv = fold
let every_ f m = Vec.for_all (fun (k, v) -> f k v) m.entries
let some f m = Vec.find (fun (k, v) -> f k v) m.entries
let find_map f m = Vec.find_map (fun (k, v) -> f k v) m.entries
let count_matching f m = Vec.count (Vec.filter (fun (k, v) -> f k v) m.entries)

let slice_bounds m from_ to_ =
  let lo = match from_ with None -> 0 | Some k -> lower_bound m k in
  let hi = match to_ with None -> count m | Some k -> lower_bound m k in
  (lo, hi)

let slice ?from_ ?to_ m =
  let lo, hi = slice_bounds m from_ to_ in
  { m with entries = Vec.subvec_exn m.entries lo hi }

let slice_seq ?from_ ?to_ m =
  let lo, hi = slice_bounds m from_ to_ in
  Vec.to_seq (Vec.subvec_exn m.entries lo hi)

let equal ?(eq = ( = )) a b =
  let n = count a in
  n = count b
  && Vec.for_all
       (fun (k, v) ->
         let i, found = find_index b k in
         found && eq v (snd (Vec.nth b.entries i)))
       a.entries
