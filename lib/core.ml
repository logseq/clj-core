type 'a coll =
  [ `Vec of 'a Vec.t
  | `Lst of 'a list
  | `Arr of 'a array
  | `Seq of 'a Stdlib.Seq.t
  | `Set of 'a Set.t ]

let coll_of_map m = `Seq (Map.to_seq m)
let coll_of_string s = `Seq (Stdlib.String.to_seq s)

let to_seq (c : 'a coll) : 'a Stdlib.Seq.t =
  match c with
  | `Vec v -> Vec.to_seq v
  | `Lst l -> Stdlib.List.to_seq l
  | `Arr a -> Stdlib.Array.to_seq a
  | `Seq s -> s
  | `Set s -> Set.to_seq s

let seq c =
  let s = to_seq c in
  match s () with Stdlib.Seq.Nil -> None | _ -> Some s

let count c = Stdlib.Seq.length (to_seq c)
let empty_ c = seq c = None
let is_empty = empty_
let first c = match to_seq c () with Stdlib.Seq.Nil -> None | Stdlib.Seq.Cons (x, _) -> Some x
let ffirst c = match first c with Some inner -> first (`Seq inner) | None -> None
let rest c = match to_seq c () with Stdlib.Seq.Nil -> Stdlib.Seq.empty | Stdlib.Seq.Cons (_, r) -> r
let next c = match rest c () with Stdlib.Seq.Nil -> None | s -> Some (fun () -> s)
let second c = match next c with None -> None | Some s -> first (`Seq s)
let last c = Seq.last (to_seq c)
let nth c i = Seq.nth (to_seq c) i
let nth_opt c i = Seq.nth_opt (to_seq c) i

let mem x c =
  Stdlib.Seq.exists (fun y -> y = x) (to_seq c)

let map f c = Stdlib.Seq.map f (to_seq c)
let filter p c = Stdlib.Seq.filter p (to_seq c)
let remove p c = Stdlib.Seq.filter (fun x -> not (p x)) (to_seq c)
let filter_map f c = Stdlib.Seq.filter_map f (to_seq c)
let keep = filter_map
let keep_indexed f c = Seq.keep_indexed f (to_seq c)
let map_indexed f c = Seq.map_indexed f (to_seq c)
let mapcat f c = Stdlib.Seq.concat_map (fun x -> to_seq (f x)) (to_seq c)
let flat_map = mapcat
let concat c = mapcat (fun x -> `Seq (to_seq x)) c
let take n c = Stdlib.Seq.take n (to_seq c)
let drop n c = Stdlib.Seq.drop n (to_seq c)
let take_while p c = Stdlib.Seq.take_while p (to_seq c)
let drop_while p c = Stdlib.Seq.drop_while p (to_seq c)
let take_nth n c = Seq.take_nth n (to_seq c)
let interpose sep c = Seq.interpose sep (to_seq c)
let dedupe c = Seq.dedupe (to_seq c)
let distinct c = Seq.distinct (to_seq c)
let partition_all n c = Seq.partition_all n (to_seq c)
let partition_by f c = Seq.partition_by f (to_seq c)
let reductions f acc c = Seq.reductions f acc (to_seq c)

let reduce f acc c = Stdlib.Seq.fold_left f acc (to_seq c)
let reduce_r f acc c = Seq.reduce_r f acc (to_seq c)
let fold = reduce
let iter f c = Stdlib.Seq.iter f (to_seq c)
let every_ p c = Stdlib.Seq.for_all p (to_seq c)
let some p c = Seq.some p (to_seq c)
let not_any_ p c = not (Stdlib.Seq.exists p (to_seq c))
let not_every_ p c = not (every_ p c)
let find = some
let find_map f c = Seq.find_map f (to_seq c)

let reverse c = Seq.reverse (to_seq c)
let sort ?(cmp = Stdlib.compare) c = Seq.sort ~cmp (to_seq c)
let sort_by ?(cmp = Stdlib.compare) f c = Seq.sort_by ~cmp f (to_seq c)
let shuffle ?(rng = Stdlib.Random.State.make_self_init ()) c =
  Vec.to_seq (Vec.shuffle ~rng (Vec.of_seq (to_seq c)))

let group_by ?(cmp = Stdlib.compare) f c = Seq.group_by ~cmp f (to_seq c)
let frequencies ?(cmp = Stdlib.compare) c = Seq.frequencies ~cmp (to_seq c)
let min_key f c = Seq.min_key f (to_seq c)
let max_key f c = Seq.max_key f (to_seq c)

let doall s = Stdlib.List.of_seq s
let dorun s = Stdlib.Seq.iter (fun _ -> ()) s
let into_vec c = Vec.of_seq (to_seq c)
let into_list c = doall (to_seq c)
let into_set ?(cmp = Stdlib.compare) c = Set.of_seq ~cmp (to_seq c)

let into_map ?(cmp = Stdlib.compare) (c : ('k * 'v) coll) : ('k, 'v) Map.t =
  Map.of_seq ~cmp (to_seq c)

let iterate = Seq.iterate
let repeat = Seq.repeat
let repeatedly = Seq.repeatedly
let cycle c = Seq.cycle (to_seq c)
let range = Seq.range
let lazy_seq = Seq.lazy_seq

let identity x = x
let constantly x _ = x
let comp f g x = f (g x)
let comp3 f g h x = f (g (h x))
let complement p x = not (p x)
let fnil f default = function None -> default | Some x -> f x
let juxt f g x = (f x, g x)
let juxt3 f g h x = (f x, g x, h x)

let memoize f =
  let tbl = Hashtbl.create 16 in
  fun x ->
    match Hashtbl.find_opt tbl x with
    | Some y -> y
    | None ->
      let y = f x in
      Hashtbl.add tbl x y;
      y

let if_ p t f = if p then t () else f ()
let when_ p f = if p then f ()
let when_some o f = match o with Some x -> f x | None -> ()

let rec cond = function
  | [] -> None
  | (true, f) :: _ -> Some (f ())
  | (false, _) :: tl -> cond tl

let or_else o default = match o with Some x -> x | None -> default
let nil_ = Option.is_none
let some_ = Option.is_some
let is_none = nil_

let inc x = x + 1
let dec x = x - 1
let zero_ x = x = 0
let pos_ x = x > 0
let neg_ x = x < 0
let even_ x = x land 1 = 0
let odd_ x = x land 1 <> 0
let abs = Stdlib.abs
let quot = ( / )
let rem = ( mod )
let mod_ a b = ((a mod b) + b) mod b

let rand ?(rng = Stdlib.Random.State.make_self_init ()) () = Stdlib.Random.State.float rng 1.0
let rand_int ?(rng = Stdlib.Random.State.make_self_init ()) n = Stdlib.Random.State.int rng n

let rand_nth ?(rng = Stdlib.Random.State.make_self_init ()) c =
  let v = into_vec c in
  Vec.nth v (Stdlib.Random.State.int rng (Vec.count v))

let min2 = Stdlib.min
let max2 = Stdlib.max
let sum c = reduce ( + ) 0 c
let product c = reduce ( * ) 1 c
let sumf c = reduce ( +. ) 0.0 c

let str c = Str.str (to_seq c)
let print s = Stdlib.print_string s
let println = Stdlib.print_endline
let prn = println

type 'a derefable =
  [ `Atom of 'a Atom.t
  | `Delay of 'a Delay.t
  | `Volatile of 'a Volatile.t
  | `Ref of 'a ref ]

let deref (d : 'a derefable) : 'a =
  match d with
  | `Atom a -> Atom.deref a
  | `Delay d -> Delay.deref d
  | `Volatile v -> Volatile.deref v
  | `Ref r -> !r

let atom = Atom.atom
let delay = Delay.delay
let realized_ = Delay.realized_

exception Ex_info of string * (string, string) Map.t

let ex_info msg data = Ex_info (msg, data)
let ex_data = function Ex_info (_, d) -> Some d | _ -> None
let ex_message = function
  | Ex_info (msg, _) -> msg
  | exn -> Stdlib.Printexc.to_string exn
