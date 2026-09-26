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

let cycle s =
  let rec go () = Stdlib.Seq.append s (lazy_seq (fun () -> go)) () in
  go

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
      match best with
      | Some (_, bk) when cmp (f x) bk >= 0 -> best
      | _ -> Some (x, f x))
    None s
  |> Option.map fst

let max_key ?(cmp = Stdlib.compare) f s =
  Stdlib.Seq.fold_left
    (fun best x ->
      match best with
      | Some (_, bk) when cmp (f x) bk <= 0 -> best
      | _ -> Some (x, f x))
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
