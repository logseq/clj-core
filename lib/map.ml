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
let to_list_local (m @ local) = exclave_ (Vec.to_list_local m.entries)
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
  let entries = m.entries in
  {
    m with
    entries =
      Rrbvec.init (Rrbvec.length entries) (fun i ->
          let k, v = Rrbvec.nth entries i in
          (k, f v));
  }

let map f m = update_vals m f

let map_kv f m =
  let entries = m.entries in
  {
    m with
    entries =
      Rrbvec.init (Rrbvec.length entries) (fun i ->
          let k, v = Rrbvec.nth entries i in
          (k, f k v));
  }

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
let sorted_map_by cmp pairs = of_list ~cmp pairs
let hash_map ?cmp pairs = of_list ?cmp pairs
let array_map ?cmp pairs = of_list ?cmp pairs
let key = fst
let value = snd

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
let iter f (m : ('k, 'v) t) =
  let () = Vec.iter (fun (k, v) -> f k v) m.entries in
  ()
let iter_local (f @ local) (m @ local) =
  let () = Vec.iter_local (fun (k, v) -> f k v) m.entries in
  ()
let fold f acc (m : ('k, 'v) t) =
  let acc' = ref acc in
  let () = Vec.iter (fun (k, v) -> acc' := f !acc' k v) m.entries in
  !acc'
let fold_local (f @ local) acc (m @ local) =
  let acc' = ref acc in
  let () = Vec.iter_local (fun (k, v) -> acc' := f !acc' k v) m.entries in
  !acc'
let fold_kv = fold
let fold_kv_local = fold_local
let reduce_kv = fold
let reduce_kv_local = fold_local
let every_ f (m : ('k, 'v) t) =
  let r = Vec.for_all (fun (k, v) -> f k v) m.entries in
  r
let every_local (f @ local) (m @ local) =
  let r = Vec.for_all_local (fun (k, v) -> f k v) m.entries in
  r
let some f m = Vec.find (fun (k, v) -> f k v) m.entries
let find_map f (m : ('k, 'v) t) =
  let r = Vec.find_map (fun (k, v) -> f k v) m.entries in
  r
let find_map_local (f @ local) (m @ local) =
  let r = Vec.find_map_local (fun (k, v) -> f k v) m.entries in
  r
let count_matching f (m : ('k, 'v) t) =
  let n = ref 0 in
  let () = Vec.iter (fun (k, v) -> if f k v then incr n) m.entries in
  !n
let count_matching_local (f @ local) (m @ local) =
  let n = ref 0 in
  let () = Vec.iter_local (fun (k, v) -> if f k v then incr n) m.entries in
  !n

let slice_bounds m from_ to_ =
  let lo = match from_ with None -> 0 | Some k -> lower_bound m k in
  let hi = match to_ with None -> count m | Some k -> lower_bound m k in
  (lo, max lo hi)

let slice ?from_ ?to_ m =
  let lo, hi = slice_bounds m from_ to_ in
  { m with entries = Vec.subvec_exn m.entries lo hi }

let slice_seq ?from_ ?to_ m =
  let lo, hi = slice_bounds m from_ to_ in
  Vec.to_seq (Vec.subvec_exn m.entries lo hi)

let subseq ?from_ ?to_ m = slice_seq ?from_ ?to_ m
let rsubseq ?from_ ?to_ m = Vec.rseq (to_vec (slice ?from_ ?to_ m))

type ('k, 'v) nest = Leaf of 'v | Nest of ('k, ('k, 'v) nest) t

let rec get_in m ks =
  match ks with
  | [] -> Some (Nest m)
  | [ k ] -> get m k
  | k :: ks' -> (
      match get m k with Some (Nest m') -> get_in m' ks' | _ -> None)

let rec assoc_in m ks v =
  match ks with
  | [] -> invalid_arg "Clj_core.Map.assoc_in: empty path"
  | [ k ] -> assoc m k v
  | k :: ks' ->
    let child =
      match get m k with
      | Some (Nest m') -> m'
      | _ -> empty ~cmp:m.cmp ()
    in
    assoc m k (Nest (assoc_in child ks' v))

let rec update_in m ks f =
  match ks with
  | [] -> invalid_arg "Clj_core.Map.update_in: empty path"
  | [ k ] -> update m k f
  | k :: ks' ->
    let child =
      match get m k with
      | Some (Nest m') -> m'
      | _ -> empty ~cmp:m.cmp ()
    in
    assoc m k (Nest (update_in child ks' f))

let equal ?(eq = ( = )) a b =
  let n = count a in
  if n <> count b then false
  else begin
    let rec check i =
      if i >= n then true
      else begin
        let k, v = Vec.nth a.entries i in
        let j, found = find_index b k in
        found && eq v (snd (Vec.nth b.entries j)) && check (i + 1)
      end
    in
    check 0
  end
