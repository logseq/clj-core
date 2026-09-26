module L = Stdlib.List

let empty = []
let list xs = xs
let of_seq = L.of_seq
let of_array = Stdlib.Array.to_list
let of_vec = Vec.to_list
let to_seq = L.to_seq
let seq = to_seq
let to_vec = Vec.of_list
let to_array = Stdlib.Array.of_list

let count = L.length
let length = L.length
let empty_ l = l = []
let is_empty = empty_
let mem = L.mem

let first = function [] -> None | x :: _ -> Some x
let rest = function [] -> [] | _ :: xs -> xs
let next = function [] | [ _ ] -> None | _ :: xs -> Some xs
let second = function _ :: x :: _ -> Some x | _ -> None
let last l = L.fold_left (fun _ x -> Some x) None l
let butlast l = match L.rev l with _ :: xs -> L.rev xs | [] -> []
let nth = L.nth
let nth_opt = L.nth_opt
let peek = first

let pop = function
  | _ :: xs -> xs
  | [] -> failwith "Clj_core.List.pop: pop on empty list"

let pop_opt = function _ :: xs -> Some xs | [] -> None
let conj l x = x :: l
let cons x l = x :: l
let into l s = Stdlib.Seq.fold_left conj l s

let map = L.map
let mapi = L.mapi
let map_indexed = mapi
let filter = L.filter
let remove p = filter (fun x -> not (p x))
let filter_map = L.filter_map
let keep = filter_map
let mapcat = L.concat_map
let flat_map = mapcat
let concat = L.concat
let flatten = L.concat
let rec zip a b =
  match (a, b) with x :: xs, y :: ys -> (x, y) :: zip xs ys | _ -> []

let rec map2 f a b =
  match (a, b) with x :: xs, y :: ys -> f x y :: map2 f xs ys | _ -> []
let iter = L.iter
let iteri = L.iteri
let fold = L.fold_left
let reduce = L.fold_left
let fold_left = L.fold_left
let fold_right = L.fold_right

let reduce_r f acc l =
  let rec go acc = function
    | [] -> acc
    | x :: xs -> (
        match f acc x with
        | Reduced.Continue acc' -> go acc' xs
        | Reduced.Reduced acc' -> acc')
  in
  go acc l

let every_ = L.for_all
let for_all = L.for_all
let some p l = L.find_opt p l
let not_any_ p l = not (L.exists p l)
let not_every_ p l = not (L.for_all p l)
let find = L.find_opt
let find_map = L.find_map

let take n l =
  if n <= 0 then []
  else
    let rec go acc n = function
      | x :: xs when n > 0 -> go (x :: acc) (n - 1) xs
      | _ -> L.rev acc
    in
    go [] n l

let drop n l =
  if n <= 0 then l
  else
    let rec go n l = if n <= 0 then l else match l with [] -> [] | _ :: xs -> go (n - 1) xs in
    go n l

let rec take_while p = function
  | x :: xs when p x -> x :: take_while p xs
  | _ -> []

let rec drop_while p = function
  | x :: xs when p x -> drop_while p xs
  | l -> l

let take_last n l =
  let len = L.length l in
  if n >= len then l else L.filteri (fun i _ -> i >= len - n) l

let drop_last n l =
  let len = L.length l in
  take (len - n) l

let take_nth n l =
  L.filteri (fun i _ -> i mod n = 0) l

let nthrest l n = drop n l
let split_at n l = (take n l, drop n l)
let split_with p l = (take_while p l, drop_while p l)

let partition n l =
  if n <= 0 then invalid_arg "Clj_core.List.partition: n must be positive";
  let rec go l =
    let chunk = take n l in
    if L.length chunk = n then chunk :: go (drop n l) else []
  in
  go l

let partition_all n l =
  if n <= 0 then invalid_arg "Clj_core.List.partition_all: n must be positive";
  let rec go l =
    match take n l with [] -> [] | chunk -> chunk :: go (drop n l)
  in
  go l

let partition_by f l =
  let rec go = function
    | [] -> []
    | x :: _ as l ->
      let k = f x in
      let chunk, rest = split_with (fun y -> f y = k) l in
      chunk :: go rest
  in
  go l

let rec interleave a b =
  match (a, b) with
  | x :: a', y :: b' -> x :: y :: interleave a' b'
  | _ -> []

let rec interpose sep = function
  | [] -> []
  | [ x ] -> [ x ]
  | x :: xs -> x :: sep :: interpose sep xs

let dedupe l =
  let rec go prev acc = function
    | x :: xs when x = prev -> go prev acc xs
    | x :: xs -> go x (x :: acc) xs
    | [] -> L.rev acc
  in
  match l with
  | [] -> []
  | x :: xs -> go x [ x ] xs

let distinct l =
  let seen = Hashtbl.create 16 in
  L.filter
    (fun x ->
      if Hashtbl.mem seen x then false
      else begin
        Hashtbl.add seen x ();
        true
      end)
    l

let reverse = L.rev
let rev = L.rev
let sort ?(cmp = Stdlib.compare) l = L.sort cmp l
let sort_by ?(cmp = Stdlib.compare) f l = L.sort (fun a b -> cmp (f a) (f b)) l
let shuffle ?(rng = Stdlib.Random.State.make_self_init ()) l =
  Vec.to_list (Vec.shuffle ~rng (Vec.of_list l))

let group_by ?(cmp = Stdlib.compare) f l = Seq.group_by ~cmp f (L.to_seq l)
let frequencies ?(cmp = Stdlib.compare) l = Seq.frequencies ~cmp (L.to_seq l)
let equal ?(eq = ( = )) a b = L.equal eq a b
let compare ?(cmp = Stdlib.compare) a b = L.compare cmp a b
