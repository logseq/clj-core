type 'a t = 'a Rrbvec.t

let empty = Rrbvec.empty
let singleton = Rrbvec.singleton
let of_list = Rrbvec.of_list
let of_array = Rrbvec.of_array
let of_seq = Rrbvec.of_seq
let init = Rrbvec.init
let vec = of_seq
let vector = of_list

let repeat n x = Rrbvec.init n (fun _ -> x)

let range ?(start = 0) ?(step = 1) stop =
  if step = 0 then invalid_arg "Clj_core.Vec.range: step must not be 0";
  let len =
    if (step > 0 && start >= stop) || (step < 0 && start <= stop) then 0
    else (stop - start + step - (if step > 0 then 1 else -1)) / step
  in
  Rrbvec.init len (fun i -> start + (i * step))

let count = Rrbvec.length
let length = Rrbvec.length
let empty_ = Rrbvec.is_empty
let is_empty = empty_
let contains_ v i = 0 <= i && i < Rrbvec.length v
let mem = Rrbvec.mem

let nth = Rrbvec.nth
let nth_opt = Rrbvec.nth_opt
let get = Rrbvec.nth_opt
let first = Rrbvec.peek_front_opt
let last = Rrbvec.peek_back_opt
let peek = last
let peek_front = Rrbvec.peek_front_opt
let peek_back = Rrbvec.peek_back_opt

let conj = Rrbvec.push_back
let cons x v = Rrbvec.push_front v x
let push_back = Rrbvec.push_back
let push_front = Rrbvec.push_front

let assoc v i x =
  if i = Rrbvec.length v then Rrbvec.push_back v x else Rrbvec.set v i x

let update v i f = Rrbvec.set v i (f (Rrbvec.nth v i))

let pop_opt v = Option.map snd (Rrbvec.pop_back v)

let pop v =
  match Rrbvec.pop_back v with
  | Some (_, v') -> v'
  | None -> invalid_arg "Clj_core.Vec.pop: pop on empty vector"

let subvec = Rrbvec.subvec

let subvec_exn v start stop =
  match Rrbvec.subvec v start stop with
  | Some s -> s
  | None -> invalid_arg "Clj_core.Vec.subvec_exn: index out of bounds"

let clampi n lo hi = if n < lo then lo else if n > hi then hi else n

let slice ?(start = 0) ?stop v =
  let len = Rrbvec.length v in
  let start = clampi start 0 len in
  let stop = clampi (Option.value stop ~default:len) start len in
  match Rrbvec.subvec v start stop with
  | Some s -> s
  | None -> v (* unreachable: bounds are clamped *)

let take n v = slice ~start:0 ~stop:n v
let drop n v = slice ~start:n v
let take_last n v = slice ~start:(Rrbvec.length v - n) v
let drop_last n v = slice ~start:0 ~stop:(Rrbvec.length v - n) v
let butlast v = drop_last 1 v
let split_at n v = (take n v, drop n v)

let take_while p v =
  let rec go i =
    if i >= Rrbvec.length v then i
    else if p (Rrbvec.nth v i) then go (i + 1)
    else i
  in
  take (go 0) v

let drop_while p v =
  let rec go i =
    if i >= Rrbvec.length v then i
    else if p (Rrbvec.nth v i) then go (i + 1)
    else i
  in
  drop (go 0) v

let split_with p v =
  let rec go i =
    if i >= Rrbvec.length v then i
    else if p (Rrbvec.nth v i) then go (i + 1)
    else i
  in
  split_at (go 0) v

let catvec = Rrbvec.concat
let concat = Rrbvec.concat
let append = Rrbvec.append


let insert_at v i x =
  let len = Rrbvec.length v in
  if i < 0 || i > len then invalid_arg "Clj_core.Vec.insert_at"
  else
    match (Rrbvec.subvec v 0 i, Rrbvec.subvec v i len) with
    | Some a, Some b -> Rrbvec.concat (Rrbvec.push_back a x) b
    | _ -> assert false

let remove_at v i =
  let len = Rrbvec.length v in
  if i < 0 || i >= len then v
  else
    match (Rrbvec.subvec v 0 i, Rrbvec.subvec v (i + 1) len) with
    | Some a, Some b -> Rrbvec.concat a b
    | _ -> assert false

let iter = Rrbvec.iter
let iteri = Rrbvec.iteri
let iter2 = Rrbvec.iter2
let fold_left = Rrbvec.fold_left
let fold_right = Rrbvec.fold_right

let foldi f acc v =
  let i = ref (-1) in
  Rrbvec.fold_left
    (fun acc x ->
      incr i;
      f acc !i x)
    acc v

let reduce = fold_left
let reduce_kv = foldi

let reduce_r f acc v =
  let exception Stop in
  let res = ref acc in
  (try
     Rrbvec.iter
       (fun x ->
         match f !res x with
         | Reduced.Continue acc' -> res := acc'
         | Reduced.Reduced acc' ->
           res := acc';
           raise Stop)
       v
   with Stop -> ());
  !res

let exists = Rrbvec.exists
let for_all = Rrbvec.for_all
let every_ = for_all
let some p v = Rrbvec.find_opt p v
let not_any_ p v = not (exists p v)
let not_every_ p v = not (for_all p v)
let find = Rrbvec.find_opt
let find_map = Rrbvec.find_map

let map = Rrbvec.map
let mapv = map
let mapi = Rrbvec.mapi
let map_indexed = mapi
let filter = Rrbvec.filter
let filterv = filter
let remove p v = Rrbvec.filter (fun x -> not (p x)) v
let filter_map = Rrbvec.filter_map
let keep = filter_map

let keep_indexed f v =
  snd
    (Rrbvec.fold_left
       (fun (i, acc) x ->
         ( i + 1,
           match f i x with Some y -> Rrbvec.push_back acc y | None -> acc ))
       (0, empty) v)

let mapcat = Rrbvec.concat_map
let flat_map = mapcat
let map2 f a b =
  let n = min (Rrbvec.length a) (Rrbvec.length b) in
  Rrbvec.init n (fun i -> f (Rrbvec.nth a i) (Rrbvec.nth b i))

let zip a b = map2 (fun x y -> (x, y)) a b
let rev = Rrbvec.rev
let reverse = rev

let sort ?(cmp = Stdlib.compare) v = Rrbvec.sort cmp v

let sort_by ?(cmp = Stdlib.compare) f v =
  Rrbvec.sort (fun a b -> cmp (f a) (f b)) v

let sort_uniq ?(cmp = Stdlib.compare) v = Rrbvec.sort_uniq cmp v

let shuffle ?(rng = Stdlib.Random.State.make_self_init ()) v =
  let a = Rrbvec.to_array v in
  for i = Array.length a - 1 downto 1 do
    let j = Stdlib.Random.State.int rng (i + 1) in
    let tmp = a.(i) in
    a.(i) <- a.(j);
    a.(j) <- tmp
  done;
  Rrbvec.of_array a

let distinct v =
  let seen = Hashtbl.create 16 in
  Rrbvec.filter
    (fun x ->
      if Hashtbl.mem seen x then false
      else begin
        Hashtbl.add seen x ();
        true
      end)
    v

let dedupe v =
  match Rrbvec.peek_front_opt v with
  | None -> empty
  | Some first ->
    snd
      (Rrbvec.fold_left
         (fun (prev, acc) x ->
           if x = prev then (prev, acc) else (x, Rrbvec.push_back acc x))
         (first, singleton first) v)

let split_by p v = Rrbvec.partition p v

let partition n v =
  if n <= 0 then invalid_arg "Clj_core.Vec.partition: n must be positive";
  let len = Rrbvec.length v in
  let whole = len / n in
  Rrbvec.init whole (fun c -> subvec_exn v (c * n) ((c + 1) * n))

let partition_all n v =
  if n <= 0 then invalid_arg "Clj_core.Vec.partition_all: n must be positive";
  let len = Rrbvec.length v in
  let whole = (len + n - 1) / n in
  Rrbvec.init whole (fun c -> subvec_exn v (c * n) (min ((c + 1) * n) len))

let seq = Rrbvec.to_seq
let to_seq = Rrbvec.to_seq

let rseq v =
  let rec go i () =
    if i < 0 then Stdlib.Seq.Nil else Stdlib.Seq.Cons (Rrbvec.nth v i, go (i - 1))
  in
  go (Rrbvec.length v - 1)

let rest v =
  let len = Rrbvec.length v in
  if len <= 1 then Stdlib.Seq.empty
  else (
    match Rrbvec.subvec v 1 len with
    | Some s -> Rrbvec.to_seq s
    | None -> Stdlib.Seq.empty)

let next v = if Rrbvec.length v <= 1 then None else Some (rest v)

let to_list = Rrbvec.to_list
let to_array = Rrbvec.to_array
let into v s = Stdlib.Seq.fold_left (fun acc x -> Rrbvec.push_back acc x) v s

let equal ?(eq = ( = )) a b = Rrbvec.equal eq a b
let compare ?(cmp = Stdlib.compare) a b = Rrbvec.compare cmp a b
