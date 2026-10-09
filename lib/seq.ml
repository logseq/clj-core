type 'a t = 'a Stdlib.Seq.t
type 'a node = 'a Stdlib.Seq.node = Nil | Cons of 'a * 'a t

let empty = Stdlib.Seq.empty
let singleton = Stdlib.Seq.return
let return = Stdlib.Seq.return
let cons = Stdlib.Seq.cons
let of_list = Stdlib.List.to_seq
let of_array = Stdlib.Array.to_seq
let of_string = Stdlib.String.to_seq
let unfold = Stdlib.Seq.unfold
let uncons = Stdlib.Seq.uncons
let lazy_seq f () = f () ()

let init n f =
  let rec go i () = if i >= n then Nil else Cons (f i, go (i + 1)) in
  go 0

let iterate f x =
  let rec go x () = Cons (x, go (f x)) in
  go x

let repeat ?n x =
  match n with
  | None ->
    let rec go () = Cons (x, go) in
    go
  | Some n ->
    let rec go n () = if n <= 0 then Nil else Cons (x, go (n - 1)) in
    go n

let repeatedly ?n f =
  match n with
  | None ->
    let rec go () = Cons (f (), go) in
    go
  | Some n ->
    let rec go n () = if n <= 0 then Nil else Cons (f (), go (n - 1)) in
    go n

(* Elements are realized once into [buf] (like Clojure's realized chunk), then
   replayed forever — re-running effectful seqs is avoided. *)
let cycle s =
  match uncons s with
  | None -> empty
  | Some (x, xs) ->
    let buf = ref (Vec.singleton x) in
    let rec first_pass s () =
      match uncons s with
      | Some (x, xs) ->
        buf := Vec.conj !buf x;
        Cons (x, first_pass xs)
      | None -> replay !buf 0 ()
    and replay v i () =
      if i >= Vec.count v then replay v 0 () else Cons (Vec.nth v i, replay v (i + 1))
    in
    cons x (first_pass xs)

let range ?(start = 0) ?(step = 1) stop =
  if step = 0 then invalid_arg "Clj_core.Seq.range: step must not be 0";
  let rec go x () =
    if (step > 0 && x >= stop) || (step < 0 && x <= stop) then Nil
    else Cons (x, go (x + step))
  in
  go start

let ints ?(start = 0) ?(step = 1) () =
  let rec go x () = Cons (x, go (x + step)) in
  go start

let append = Stdlib.Seq.append
let concat = Stdlib.Seq.concat
let concat_list ss = concat (Stdlib.List.to_seq ss)

let rec interleave a b () =
  match (uncons a, uncons b) with
  | Some (x, a'), Some (y, b') -> Cons (x, cons y (interleave a' b'))
  | _ -> Nil

let rec interpose sep s () =
  match uncons s with
  | Some (x, xs) -> (
      match uncons xs with
      | Some _ -> Cons (x, cons sep (interpose sep xs))
      | None -> Cons (x, empty))
  | None -> Nil

let rec zip a b () =
  match (uncons a, uncons b) with
  | Some (x, a'), Some (y, b') -> Cons ((x, y), zip a' b')
  | _ -> Nil

let rec map2 f a b () =
  match (uncons a, uncons b) with
  | Some (x, a'), Some (y, b') -> Cons (f x y, map2 f a' b')
  | _ -> Nil

let seq s = match uncons s with None -> None | Some _ -> Some s
let first s = Option.map fst (uncons s)

let rest s = match uncons s with Some (_, xs) -> xs | None -> empty

let next s = seq (rest s)
let second s = first (rest s)

let rec nth_opt s n =
  if n < 0 then None
  else
    match uncons s with
    | Some (x, _) when n = 0 -> Some x
    | Some (_, xs) -> nth_opt xs (n - 1)
    | None -> None

let nth s n =
  match nth_opt s n with
  | Some x -> x
  | None -> invalid_arg "Clj_core.Seq.nth: index out of bounds"

let last s = Stdlib.Seq.fold_left (fun _ x -> Some x) None s

let butlast s =
  let rec go s () =
    match uncons s with
    | Some (x, xs) -> (
        match uncons xs with Some _ -> Cons (x, go xs) | None -> Nil)
    | None -> Nil
  in
  go s

let rec nthrest s n =
  if n <= 0 then s
  else match uncons s with Some (_, xs) -> nthrest xs (n - 1) | None -> empty

let length s = Stdlib.Seq.fold_left (fun n _ -> n + 1) 0 s
let count = length
let is_empty s = uncons s = None
let empty_ = is_empty

let map = Stdlib.Seq.map

let mapi f s =
  unfold
    (fun (i, s) ->
      match uncons s with
      | Some (x, xs) -> Some (f i x, (i + 1, xs))
      | None -> None)
    (0, s)

let map_indexed = mapi
let filter = Stdlib.Seq.filter
let remove p = filter (fun x -> not (p x))

let rec filter_map f s () =
  match uncons s with
  | Some (x, xs) -> (
      match f x with
      | Some y -> Cons (y, filter_map f xs)
      | None -> filter_map f xs ())
  | None -> Nil

let keep = filter_map

let keep_indexed f s =
  filter_map (fun (i, x) -> f i x) (mapi (fun i x -> (i, x)) s)

let mapcat = Stdlib.Seq.concat_map
let flat_map = mapcat

let rec take n s () =
  if n <= 0 then Nil
  else
    match uncons s with
    | Some (x, xs) -> Cons (x, take (n - 1) xs)
    | None -> Nil

let rec drop n s =
  if n <= 0 then s
  else match uncons s with Some (_, xs) -> drop (n - 1) xs | None -> empty

let rec take_while p s () =
  match uncons s with
  | Some (x, xs) when p x -> Cons (x, take_while p xs)
  | _ -> Nil

let drop_while p s =
  let rec go s =
    match uncons s with Some (x, xs) when p x -> go xs | _ -> s
  in
  go s

let take_nth n s =
  if n <= 0 then invalid_arg "Clj_core.Seq.take_nth: n must be positive";
  filter_map
    (fun (i, x) -> if i mod n = 0 then Some x else None)
    (mapi (fun i x -> (i, x)) s)

let take_last n s =
  let l = Stdlib.List.of_seq s in
  let len = Stdlib.List.length l in
  if n >= len then l else Stdlib.List.filteri (fun i _ -> i >= len - n) l

let drop_last n s =
  let rec go q s () =
    match uncons s with
    | Some (x, xs) ->
      let q = Queue.conj q x in
      if Queue.count q > n then
        match Queue.pop_full q with
        | Some (y, q') -> Cons (y, go q' xs)
        | None -> Nil
      else go q xs ()
    | None -> Nil
  in
  go Queue.empty s

let split_at n s = (take n s, drop n s)
let split_with p s = (take_while p s, drop_while p s)

let partition n s =
  if n <= 0 then invalid_arg "Clj_core.Seq.partition: n must be positive";
  let rec go s () =
    let chunk = Stdlib.List.of_seq (take n s) in
    if Stdlib.List.length chunk = n then
      Cons (Stdlib.List.to_seq chunk, go (drop n s))
    else Nil
  in
  go s

let partition_all n s =
  if n <= 0 then invalid_arg "Clj_core.Seq.partition_all: n must be positive";
  let rec go s () =
    let chunk = Stdlib.List.of_seq (take n s) in
    match chunk with
    | [] -> Nil
    | _ -> Cons (Stdlib.List.to_seq chunk, go (drop n s))
  in
  go s

let partition_by f s =
  let rec go s () =
    match uncons s with
    | Some (x, _) ->
      let k = f x in
      let chunk, rest = split_with (fun y -> f y = k) s in
      Cons (chunk, go rest)
    | None -> Nil
  in
  go s

let dedupe s =
  let rec go prev s () =
    match uncons s with
    | Some (x, xs) when x <> prev -> Cons (x, go x xs)
    | Some (_, xs) -> go prev xs ()
    | None -> Nil
  in
  match uncons s with
  | Some (x, xs) -> cons x (go x xs)
  | None -> empty

let distinct s =
  let seen = Hashtbl.create 16 in
  filter
    (fun x ->
      if Hashtbl.mem seen x then false
      else begin
        Hashtbl.add seen x ();
        true
      end)
    s

let reductions f acc s =
  let rec go acc s () =
    Cons
      ( acc,
        match uncons s with
        | Some (x, xs) -> go (f acc x) xs
        | None -> empty )
  in
  go acc s

let reduce = Stdlib.Seq.fold_left
let fold_left = Stdlib.Seq.fold_left

let reduce_r f acc s =
  let rec go acc s =
    match uncons s with
    | Some (x, xs) -> (
        match f acc x with
        | Reduced.Continue acc' -> go acc' xs
        | Reduced.Reduced acc' -> acc')
    | None -> acc
  in
  go acc s

let iter = Stdlib.Seq.iter
let every_ = Stdlib.Seq.for_all
let for_all = Stdlib.Seq.for_all

let rec find p s =
  match uncons s with
  | Some (x, xs) -> if p x then Some x else find p xs
  | None -> None

let some = find
let exists p s = find p s <> None
let not_any_ p s = not (Stdlib.Seq.exists p s)
let not_every_ p s = not (for_all p s)

let rec find_map f s =
  match uncons s with
  | Some (x, xs) -> ( match f x with Some _ as r -> r | None -> find_map f xs)
  | None -> None

let mem x s = Stdlib.Seq.exists (fun y -> y = x) s

let to_list = Stdlib.List.of_seq
let sort ?(cmp = Stdlib.compare) s = of_list (Stdlib.List.sort cmp (to_list s))

let sort_by ?(cmp = Stdlib.compare) f s =
  sort ~cmp:(fun a b -> cmp (f a) (f b)) s

let reverse s = of_list (Stdlib.List.rev (to_list s))

let shuffle ?(rng = Stdlib.Random.State.make_self_init ()) s =
  Vec.to_seq (Vec.shuffle ~rng (Vec.of_seq s))

let min_key ?(cmp = Stdlib.compare) f s =
  Stdlib.Seq.fold_left
    (fun best x ->
      let fx = f x in
      match best with
      | Some (_, bk) when cmp fx bk >= 0 -> best
      | _ -> Some (x, fx))
    None s
  |> Option.map fst

let max_key ?(cmp = Stdlib.compare) f s =
  Stdlib.Seq.fold_left
    (fun best x ->
      let fx = f x in
      match best with
      | Some (_, bk) when cmp fx bk <= 0 -> best
      | _ -> Some (x, fx))
    None s
  |> Option.map fst

let group_by ?(cmp = Stdlib.compare) f s =
  Stdlib.Seq.fold_left
    (fun m x ->
      let k = f x in
      Map.update m k (function Some v -> Vec.conj v x | None -> Vec.singleton x))
    (Map.empty ~cmp ()) s

let frequencies ?(cmp = Stdlib.compare) s =
  Stdlib.Seq.fold_left
    (fun m x -> Map.update m x (function Some n -> n + 1 | None -> 1))
    (Map.empty ~cmp ()) s

let doall = to_list
let dorun s = iter ignore s
let to_vec = Vec.of_seq
let to_array s = Stdlib.Array.of_seq s
let to_set ?(cmp = Stdlib.compare) s = Set.of_seq ~cmp s
let of_map = Map.to_seq
let of_vec = Vec.to_seq
let of_set = Set.to_seq
let of_queue = Queue.to_seq

let sequence s = s
let run_ f s = iter (fun x -> ignore (f x)) s

let not_empty s = match s () with Nil -> None | _ -> Some s
let bounded_count n s = Stdlib.min n (count (take n s))
let nth_next s n = next (nthrest s n)
let fnext s = Option.bind (next s) first
let nfirst s = Option.bind (first s) next
let nnext s = Option.bind (next s) next

let distinct_ s =
  let seen = Hashtbl.create 16 in
  let rec go s =
    match uncons s with
    | None -> true
    | Some (x, xs) ->
      if Hashtbl.mem seen x then false
      else (
        Hashtbl.add seen x ();
        go xs)
  in
  go s

let replicate n x = repeat ~n x
let some_vals s = filter_map Fun.id s

let random_sample ?(prob = 1.0) ?(rng = Stdlib.Random.State.make_self_init ()) s =
  filter (fun _ -> Stdlib.Random.State.float rng 1.0 < prob) s

(* ---- borrow variants (OxCaml): the .mli gives these `t @ local`
   signatures; bodies mirror the plain versions but operate directly on
   the borrowed seq so local inputs never reach a global-only function *)

let uncons_local s = s ()
let singleton_local x = fun () -> Cons (x, empty)
let cons_local x s = fun () -> Cons (x, s)
let lazy_seq_local f = fun () -> f () ()

let rec of_list_local l () =
  match l with [] -> Nil | x :: xs -> Cons (x, of_list_local xs)

let of_vec_local v = Vec.to_seq_local v
let of_set_local s = Set.to_seq_local s
let of_map_local m = Map.to_seq_local m

let of_string_local (s : string) : char t =
  let n = String.length s in
  let rec go i () =
    if i >= n then Nil else Cons (String.unsafe_get s i, go (i + 1))
  in
  go 0

let rec map_local f s () =
  match s () with
  | Nil -> Nil
  | Cons (x, xs) -> Cons (f x, map_local f xs)

let rec mapi_local f s =
  let rec go i s () =
    match s () with
    | Nil -> Nil
    | Cons (x, xs) -> Cons (f i x, go (i + 1) xs)
  in
  go 0 s

let map_indexed_local = mapi_local

let rec filter_local p s () =
  match s () with
  | Nil -> Nil
  | Cons (x, xs) -> if p x then Cons (x, filter_local p xs) else filter_local p xs ()

let remove_local p s = filter_local (fun x -> not (p x)) s

let rec filter_map_local f s () =
  match s () with
  | Nil -> Nil
  | Cons (x, xs) ->
    (match f x with
     | Some y -> Cons (y, filter_map_local f xs)
     | None -> filter_map_local f xs ())

let keep_local = filter_map_local

let rec mapcat_local f s () =
  match s () with
  | Nil -> Nil
  | Cons (x, xs) ->
    let rec inner s' () =
      match s' () with
      | Nil -> mapcat_local f xs ()
      | Cons (y, ys) -> Cons (y, inner ys)
    in
    inner (f x) ()

let rec take_local n s () =
  if n <= 0 then Nil
  else
    match s () with
    | Cons (x, xs) -> Cons (x, take_local (n - 1) xs)
    | Nil -> Nil

let rec drop_local n s =
  if n <= 0 then s
  else match s () with Cons (_, xs) -> drop_local (n - 1) xs | Nil -> empty

let rec take_while_local p s () =
  match s () with
  | Cons (x, xs) when p x -> Cons (x, take_while_local p xs)
  | _ -> Nil

let drop_while_local p s =
  let rec go s =
    match s () with Cons (x, xs) when p x -> go xs | _ -> s
  in
  go s

let take_nth_local n s =
  if n <= 0 then invalid_arg "Clj_core.Seq.take_nth_local: n must be positive";
  filter_map_local
    (fun (i, x) -> if i mod n = 0 then Some x else None)
    (mapi_local (fun i x -> (i, x)) s)

let rec nthrest_local s n =
  if n <= 0 then s
  else match s () with Cons (_, xs) -> nthrest_local xs (n - 1) | Nil -> empty

let drop_last_local n s =
  (* two passes over the realized list: the Queue-based single pass would
     store local elements in a heap structure *)
  let l = to_list_local s in
  let rec len l = match l with [] -> 0 | _ :: xs -> 1 + len xs in
  let keep = len l - n in
  let rec go i l () =
    match l with
    | x :: xs when i < keep -> Cons (x, go (i + 1) xs)
    | _ -> Nil
  in
  go 0 l

let rest_local s = match s () with Cons (_, xs) -> xs | Nil -> empty
let next_local s = match rest_local s with s' -> (match s' () with Nil -> None | _ -> Some s')

let rec interleave_local a b () =
  match (a (), b ()) with
  | Cons (x, a'), Cons (y, b') -> Cons (x, cons_local y (interleave_local a' b'))
  | _ -> Nil

let rec interpose_local sep s () =
  match s () with
  | Cons (x, xs) ->
    (match xs () with
     | Cons _ -> Cons (x, cons_local sep (interpose_local sep xs))
     | Nil -> Cons (x, empty))
  | Nil -> Nil

let partition_local n s =
  if n <= 0 then invalid_arg "Clj_core.Seq.partition_local: n must be positive";
  let rec go s () =
    let chunk = to_list_local (take_local n s) in
    if Stdlib.List.length chunk = n then
      Cons (of_list_local chunk, go (drop_local n s))
    else Nil
  in
  go s

let partition_all_local n s =
  if n <= 0 then invalid_arg "Clj_core.Seq.partition_all_local: n must be positive";
  let rec go s () =
    match to_list_local (take_local n s) with
    | [] -> Nil
    | chunk -> Cons (of_list_local chunk, go (drop_local n s))
  in
  go s

let reductions_local f acc s =
  let rec go acc s () =
    Cons
      ( acc,
        match s () with
        | Cons (x, xs) -> go (f acc x) xs
        | Nil -> empty )
  in
  go acc s

let dedupe_local s =
  let rec go prev s () =
    match s () with
    | Cons (x, xs) when x <> prev -> Cons (x, go x xs)
    | Cons (_, xs) -> go prev xs ()
    | Nil -> Nil
  in
  match s () with
  | Cons (x, xs) -> cons_local x (go x xs)
  | Nil -> empty

let concat_local ss =
  let rec go ss () =
    match ss () with
    | Nil -> Nil
    | Cons (s, rest) ->
      let rec inner s () =
        match s () with
        | Nil -> go rest ()
        | Cons (x, xs) -> Cons (x, inner xs)
      in
      inner s ()
  in
  go ss

let rec iterate_local f x () = Cons (x, iterate_local f (f x))

let repeat_local ?n x =
  match n with
  | None ->
    let rec go () = Cons (x, go) in
    go
  | Some n ->
    let rec go n () = if n <= 0 then Nil else Cons (x, go (n - 1)) in
    go n

let repeatedly_local ?n f =
  match n with
  | None ->
    let rec go () = Cons (f (), go) in
    go
  | Some n ->
    let rec go n () = if n <= 0 then Nil else Cons (f (), go (n - 1)) in
    go n

let range_local ?(start = 0) ?(step = 1) stop =
  if step = 0 then invalid_arg "Clj_core.Seq.range_local: step must not be 0";
  let rec go x () =
    if (step > 0 && x >= stop) || (step < 0 && x <= stop) then Nil
    else Cons (x, go (x + step))
  in
  go start

let ints_local ?(start = 0) ?(step = 1) () =
  let rec go x () = Cons (x, go (x + step)) in
  go start

let to_list_local s =
  let rec go s acc =
    match s () with Cons (x, xs) -> go xs (x :: acc) | Nil -> Stdlib.List.rev acc
  in
  go s []

let to_vec_local s = Vec.of_seq_local s

let count_local s =
  let rec go s n = match s () with Cons (_, xs) -> go xs (n + 1) | Nil -> n in
  go s 0

let is_empty_local s = s () = Nil

let first_local s = match s () with Cons (x, _) -> Some x | Nil -> None
let second_local s =
  match s () with Cons (_, xs) -> first_local xs | Nil -> None

let last_local s =
  let rec go s acc = match s () with Cons (x, xs) -> go xs (Some x) | Nil -> acc in
  go s None

let rec nth_opt_local s n =
  if n < 0 then None
  else
    match s () with
    | Cons (x, _) when n = 0 -> Some x
    | Cons (_, xs) -> nth_opt_local xs (n - 1)
    | Nil -> None

let nth_local s n =
  match nth_opt_local s n with
  | Some x -> x
  | None -> invalid_arg "Clj_core.Seq.nth_local: index out of bounds"

let take_last_local n s =
  let l = to_list_local s in
  let len = Stdlib.List.length l in
  if n >= len then l else Stdlib.List.filteri (fun i _ -> i >= len - n) l

let split_at_local n s = (take_local n s, drop_local n s)
let split_with_local p s = (take_while_local p s, drop_while_local p s)

let rec reduce_local f acc s =
  match s () with
  | Cons (x, xs) -> reduce_local f (f acc x) xs
  | Nil -> acc

let fold_left_local = reduce_local

let rec every_local p s =
  match s () with
  | Cons (x, xs) -> p x && every_local p xs
  | Nil -> true

let rec find_local p s =
  match s () with
  | Cons (x, xs) -> if p x then Some x else find_local p xs
  | Nil -> None

let exists_local p s = find_local p s <> None
let mem_local x s = exists_local (fun y -> y = x) s

let rec iter_local f s =
  match s () with
  | Cons (x, xs) -> f x; iter_local f xs
  | Nil -> ()

let dorun_local s = iter_local (fun _ -> ()) s

let sort_local ?(cmp = Stdlib.compare) s =
  of_list_local (Stdlib.List.sort cmp (to_list_local s))

let reverse_local s = of_list_local (Stdlib.List.rev (to_list_local s))
