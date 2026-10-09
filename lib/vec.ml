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

(* Callback consumers come in pairs: the plain name keeps the global
   signature (callback sees global elements, takes a global vector), the
   [_local] twin accepts a local vector and hands the callback
   [@ local] elements. *)
let iter f (v : 'a t) =
  let n = Rrbvec.length v in
  for i = 0 to n - 1 do
    f (Rrbvec.nth v i)
  done
let iter_local = Rrbvec.iter

let iteri f (v : 'a t) =
  let n = Rrbvec.length v in
  for i = 0 to n - 1 do
    f i (Rrbvec.nth v i)
  done
let iteri_local = Rrbvec.iteri

let iter2 = Rrbvec.iter2

let fold_left f acc (v : 'a t) =
  let n = Rrbvec.length v in
  let r = ref acc in
  for i = 0 to n - 1 do
    r := f !r (Rrbvec.nth v i)
  done;
  !r
let fold_left_local = Rrbvec.fold_left

let fold_right f (v : 'a t) acc =
  let r = ref acc in
  for i = Rrbvec.length v - 1 downto 0 do
    r := f (Rrbvec.nth v i) !r
  done;
  !r
let fold_right_local = Rrbvec.fold_right

let foldi f acc (v : 'a t) =
  let n = Rrbvec.length v in
  let r = ref acc in
  for i = 0 to n - 1 do
    r := f !r i (Rrbvec.nth v i)
  done;
  !r

let foldi_local (f @ local) acc (v @ local) =
  let acc' = ref acc in
  let () = Rrbvec.iteri (fun i x -> acc' := f !acc' i x) v in
  !acc'

let reduce = fold_left
let reduce_local = fold_left_local
let reduce_kv = foldi
let reduce_kv_local = foldi_local

let reduce_r f acc (v : 'a t) =
  let exception Stop in
  let n = Rrbvec.length v in
  let res = ref acc in
  (try
     for i = 0 to n - 1 do
       match f !res (Rrbvec.nth v i) with
       | Reduced.Continue acc' -> res := acc'
       | Reduced.Reduced acc' ->
         res := acc';
         raise Stop
     done
   with Stop -> ());
  !res

let reduce_r_local (f @ local) acc (v @ local) =
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

let exists p (v : 'a t) =
  let n = Rrbvec.length v in
  let rec go i = i < n && (p (Rrbvec.nth v i) || go (i + 1)) in
  go 0
let exists_local = Rrbvec.exists

let for_all p (v : 'a t) =
  let n = Rrbvec.length v in
  let rec go i = i >= n || (p (Rrbvec.nth v i) && go (i + 1)) in
  go 0
let for_all_local = Rrbvec.for_all

let every_ = for_all
let every_local = for_all_local
let some p v = Rrbvec.find_opt p v
let not_any_ p v = not (exists p v)
let not_any_local (p @ local) (v @ local) = not (exists_local p v)
let not_every_ p v = not (for_all p v)
let not_every_local (p @ local) (v @ local) = not (for_all_local p v)
let find = Rrbvec.find_opt

let find_map f (v : 'a t) =
  let n = Rrbvec.length v in
  let rec go i =
    if i >= n then None
    else
      match f (Rrbvec.nth v i) with
      | Some _ as r -> r
      | None -> go (i + 1)
  in
  go 0
let find_map_local = Rrbvec.find_map

let map f (v : 'a t) = Rrbvec.mapi (fun _ x -> f x) v
let map_local = Rrbvec.map
let mapv = map
let mapv_local = map_local
let mapi = Rrbvec.mapi

let mapi_local (f @ local) (v @ local) =
  let n = Rrbvec.length v in
  if n = 0 then Rrbvec.empty
  else begin
    let a = Array.make n (f 0 (Rrbvec.nth_local v 0)) in
    for i = 1 to n - 1 do
      Array.unsafe_set a i (f i (Rrbvec.nth_local v i))
    done;
    Rrbvec.of_array a
  end
let map_indexed = mapi
let map_indexed_local = mapi_local
let filter = Rrbvec.filter
let filterv = filter
let remove p v = Rrbvec.filter (fun x -> not (p x)) v
let filter_map = Rrbvec.filter_map

let filter_map_local (f @ local) (v @ local) =
  let n = Rrbvec.length v in
  let acc = ref Rrbvec.empty in
  for i = 0 to n - 1 do
    match f (Rrbvec.nth_local v i) with
    | Some b -> acc := Rrbvec.push_back !acc b
    | None -> ()
  done;
  !acc
let keep = filter_map
let keep_local = filter_map_local

let keep_indexed f v =
  let n = Rrbvec.length v in
  let acc = ref Rrbvec.empty in
  for i = 0 to n - 1 do
    match f i (Rrbvec.nth v i) with
    | Some b -> acc := Rrbvec.push_back !acc b
    | None -> ()
  done;
  !acc

let mapcat f (v : 'a t) =
  let n = Rrbvec.length v in
  let acc = ref Rrbvec.empty in
  for i = 0 to n - 1 do
    let u = f (Rrbvec.nth v i) in
    let m = Rrbvec.length u in
    for j = 0 to m - 1 do
      acc := Rrbvec.push_back !acc (Rrbvec.nth u j)
    done
  done;
  !acc
let mapcat_local = Rrbvec.concat_map
let flat_map = mapcat
let flat_map_local = mapcat_local
let map2 (f @ local) (a @ local) (b @ local) =
  let n = min (Rrbvec.length a) (Rrbvec.length b) in
  if n = 0 then Rrbvec.empty
  else begin
    let arr = Array.make n (f (Rrbvec.nth_local a 0) (Rrbvec.nth_local b 0)) in
    for i = 1 to n - 1 do
      Array.unsafe_set arr i
        (f (Rrbvec.nth_local a i) (Rrbvec.nth_local b i))
    done;
    Rrbvec.of_array arr
  end

let zip a b =
  let n = min (Rrbvec.length a) (Rrbvec.length b) in
  Rrbvec.init n (fun i -> (Rrbvec.nth a i, Rrbvec.nth b i))
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
    let rec loop i prev acc =
      if i >= Rrbvec.length v then acc
      else begin
        let x = Rrbvec.nth v i in
        if x = prev then loop (i + 1) prev acc
        else loop (i + 1) x (Rrbvec.push_back acc x)
      end
    in
    loop 1 first (singleton first)

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

let equal ?(eq = ( = )) a b =
  let la = Rrbvec.length a and lb = Rrbvec.length b in
  la = lb
  && (let rec go i =
        i >= la || (eq (Rrbvec.nth a i) (Rrbvec.nth b i) && go (i + 1))
      in
      go 0)
let compare ?(cmp = Stdlib.compare) a b =
  let la = Rrbvec.length a and lb = Rrbvec.length b in
  let rec go i =
    if i >= la && i >= lb then 0
    else if i >= la then -1
    else if i >= lb then 1
    else
      let c = cmp (Rrbvec.nth a i) (Rrbvec.nth b i) in
      if c <> 0 then c else go (i + 1)
  in
  go 0

(* borrow variants *)
let of_seq_local = Rrbvec.of_seq

external uset_local : 'a array @ local -> int -> 'a @ local -> unit
  = "%array_unsafe_set"

(* -- Borrow twins: [@ local] inputs, results in the caller's region. -- *)

let of_list_local = Rrbvec.of_list_local
let of_array_local = Rrbvec.of_array_local
let of_seq_local = Rrbvec.of_seq_local
let nth_local = Rrbvec.nth_local
let nth_opt_local = Rrbvec.nth_opt_local
let get_local = Rrbvec.nth_opt_local
let first_local = Rrbvec.peek_front_opt_local
let last_local = Rrbvec.peek_back_opt_local
let peek_local = Rrbvec.peek_back_opt_local
let peek_front_local = Rrbvec.peek_front_opt_local
let peek_back_local = Rrbvec.peek_back_opt_local
let to_list_local = Rrbvec.to_list_local
let to_array_local = Rrbvec.to_array_local
let drop_local = Rrbvec.drop_local
let take_local = Rrbvec.take_local
let rest_local = Rrbvec.rest_local

(* Reverse a local list into a fresh local list. *)
let lrev (l @ local) =
  let rec go (acc @ local) = function
    | [] -> acc
    | x :: t -> exclave_ (go (x :: acc) t)
  in
  exclave_ (go [] l)

(* Length of a local list. *)
let llength (l @ local) =
  let rec go n = function
    | [] -> n
    | _ :: t -> go (n + 1) t
  in
  go 0 l

(* Membership test on a local list (linear). *)
let lmem (x @ local) (l @ local) =
  let rec go (x @ local) = function
    | [] -> false
    | y :: t -> if x = y then true else exclave_ (go x t)
  in
  exclave_ (go x l)

(* Filter a local list, preserving order. *)
let lfilter (p @ local) (l @ local) =
  let rec go (p @ local) (acc @ local) = function
    | [] -> acc
    | x :: t ->
        if p x then exclave_ (go p (x :: acc) t)
        else exclave_ (go p acc t)
  in
  exclave_ (lrev (go p [] l))

(* Insertion sort a local list with a (possibly local) comparator. *)
let lsort (cmp @ local) (l @ local) =
  let rec insert (cmp @ local) (x @ local) = function
    | [] -> exclave_ [x]
    | y :: t ->
        if cmp x y <= 0 then exclave_ (x :: y :: t)
        else exclave_ (y :: insert cmp x t)
  in
  let rec go (cmp @ local) (acc @ local) = function
    | [] -> acc
    | x :: t -> exclave_ (go cmp (insert cmp x acc) t)
  in
  exclave_ (go cmp [] l)

let filterv_local (p @ local) (v @ local) =
  exclave_ (Rrbvec.of_list_local (lfilter p (Rrbvec.to_list_local v)))

let remove_local (p @ local) (v @ local) =
  exclave_
    (Rrbvec.of_list_local
       (lfilter (fun x -> not (p x)) (Rrbvec.to_list_local v)))

let rev_local (v @ local) =
  exclave_ (Rrbvec.of_list_local (lrev (Rrbvec.to_list_local v)))

let reverse_local = rev_local

let sort_local (v @ local) =
  exclave_
    (Rrbvec.of_list_local
       (lsort (fun (a @ local) (b @ local) -> Stdlib.compare a b)
          (Rrbvec.to_list_local v)))

let sort_by_local (f @ local) (v @ local) =
  exclave_
    (Rrbvec.of_list_local
       (lsort (fun (a @ local) (b @ local) -> Stdlib.compare (f a) (f b))
          (Rrbvec.to_list_local v)))

let sort_uniq_local (v @ local) =
  let cmp = fun (a @ local) (b @ local) -> Stdlib.compare a b in
  exclave_
    (let sorted = lsort cmp (Rrbvec.to_list_local v) in
     let rec dedup (cmp @ local) = function
       | x :: (y :: _ as t) ->
           if cmp x y = 0 then exclave_ (dedup cmp t)
           else exclave_ (x :: dedup cmp t)
       | l -> exclave_ l
     in
     Rrbvec.of_list_local (dedup cmp sorted))

let shuffle_local ?(rng = Stdlib.Random.State.make_self_init ()) (v @ local) =
  exclave_
    (let a = Rrbvec.to_array_local v in
     let n = Array.length a in
     for i = n - 1 downto 1 do
       let j = Stdlib.Random.State.int rng (i + 1) in
       let tmp = Array.unsafe_get a i in
       uset_local a i (Array.unsafe_get a j);
       uset_local a j tmp
     done;
     Rrbvec.of_array_local a)

let distinct_local (v @ local) =
  exclave_
    (let rec go (acc @ local) (seen @ local) (l @ local) =
       match l with
       | [] -> exclave_ acc
       | x :: t ->
           if lmem x seen then exclave_ (go acc seen t)
           else exclave_ (go (x :: acc) (x :: seen) t)
     in
     Rrbvec.of_list_local (lrev (go [] [] (Rrbvec.to_list_local v))))

let dedupe_local (v @ local) =
  exclave_
    (let rec go (acc @ local) (prev : 'a option @ local) (l @ local) =
       match l with
       | [] -> exclave_ acc
       | x :: t ->
           (match prev with
           | Some p when p = x -> exclave_ (go acc prev t)
           | _ -> exclave_ (go (x :: acc) (Some x) t))
     in
     Rrbvec.of_list_local (lrev (go [] None (Rrbvec.to_list_local v))))
