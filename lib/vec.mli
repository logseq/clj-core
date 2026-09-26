(** Persistent vectors — Clojure's [PersistentVector] over {!Rrbvec}.

    Indexed access and updates are O(log32 n); appends at either end are
    effectively O(1) while the edge buffers have room. All operations are
    persistent: the input vector is never modified. *)

type 'a t = 'a Rrbvec.t
(** An immutable vector backed by an RRB tree. *)

(** {1 Construction} *)

val empty : 'a t
(** The empty vector. *)

val singleton : 'a -> 'a t
(** [singleton x] is the one-element vector [\[x\]]. *)

val of_list : 'a list -> 'a t
(** [of_list \[x1; x2; ...\]] builds a vector in order. *)

val of_array : 'a array -> 'a t
(** [of_array a] copies the array into a vector. *)

val of_seq : 'a Stdlib.Seq.t -> 'a t
(** [of_seq s] realizes the sequence into a vector, in order. *)

val init : int -> (int -> 'a) -> 'a t
(** [init n f] is [\[f 0; f 1; ...; f (n-1)\]]. *)

val repeat : int -> 'a -> 'a t
(** [repeat n x] is a vector of [n] copies of [x]. *)
val range : ?start:int -> ?step:int -> int -> int t
(** [range ?start ?step stop] is [\[start; start+step; ...\]) bounded by [stop],
    like Clojure's [(range start stop step)]. Defaults: [start=0], [step=1]. *)

val vec : 'a Stdlib.Seq.t -> 'a t
(** [vec s] materializes a sequence — Clojure's [(vec coll)]. *)

val vector : 'a list -> 'a t
(** [vector \[a; b; ...\]] — Clojure's [(vector a b ...)]. *)

(** {1 Predicates and size} *)

val count : 'a t -> int
(** [count v] is the number of elements — Clojure's [(count v)]. *)

val length : 'a t -> int
(** Alias for {!count}. *)

val empty_ : 'a t -> bool
(** [empty_ v] is [true] when [v] has no elements — Clojure's [(empty? v)]. *)

val is_empty : 'a t -> bool
(** Alias for {!empty_}. *)
val contains_ : 'a t -> int -> bool
(** [contains_ v i] is [true] when [i] is a valid index — Clojure's [(contains?
    v i)] checks the index, not the value. Use {!mem} for values. *)

val mem : 'a -> 'a t -> bool
(** [mem x v] is [true] when [x] occurs in [v] (structural equality). Unlike
    Clojure's [contains?] on vectors, this checks values, not indices. *)

(** {1 Access} *)

val nth : 'a t -> int -> 'a
(** Raises [Invalid_argument] when out of bounds. *)

val nth_opt : 'a t -> int -> 'a option
(** [nth_opt v i] is [Some (nth v i)] or [None] out of bounds. *)

val get : 'a t -> int -> 'a option
(** [get v i] is {!nth_opt} — Clojure's [(get v i)] returns nil when missing. *)

val first : 'a t -> 'a option
(** [first v] is the first element, [None] on empty — Clojure's [(first v)]. *)

val last : 'a t -> 'a option
(** [last v] is the last element, [None] on empty — Clojure's [(last v)]. *)
val peek : 'a t -> 'a option
(** [peek v] is {!last} — Clojure's [(peek v)]. *)

val peek_front : 'a t -> 'a option
(** Alias for {!first}. *)

val peek_back : 'a t -> 'a option
(** Alias for {!last}. *)

(** {1 Update (persistent)} *)

val conj : 'a t -> 'a -> 'a t
(** [conj v x] appends at the end — Clojure's [(conj v x)]. *)

val cons : 'a -> 'a t -> 'a t
(** [cons x v] prepends — Clojure's [(cons x v)]. *)

val assoc : 'a t -> int -> 'a -> 'a t
(** [assoc v i x] sets index [i]. When [i = count v] the value is appended, like
    Clojure's [(assoc v (count v) x)]. Out-of-range indices raise
    [Invalid_argument]. *)

val update : 'a t -> int -> ('a -> 'a) -> 'a t
(** [update v i f] is [assoc v i (f (nth v i))]. Raises when [i] is out of
    range. *)

val pop : 'a t -> 'a t
(** Removes the last element. Raises [Invalid_argument] on empty — Clojure's
    [(pop \[\])] throws. *)

val pop_opt : 'a t -> 'a t option
(** [pop_opt v] is [Some (pop v)] or [None] on empty. *)

val push_back : 'a t -> 'a -> 'a t
(** Alias for {!conj}. *)

val push_front : 'a t -> 'a -> 'a t
(** [push_front v x] prepends [x] — element order matches {!cons}. *)
val insert_at : 'a t -> int -> 'a -> 'a t
(** [insert_at v i x] inserts [x] at index [i] (shifting later elements right).
    [i] must satisfy [0 <= i <= count v]. *)

val remove_at : 'a t -> int -> 'a t
(** [remove_at v i] drops index [i]. Out-of-range indices return [v]
    unchanged. *)

(** {1 Slicing and splitting} *)

val subvec : 'a t -> int -> int -> 'a t option
(** [subvec v start stop] is the half-open slice [\[start, stop)]. Returns
    [None] on out-of-range bounds — Clojure's [subvec] throws. *)

val subvec_exn : 'a t -> int -> int -> 'a t
(** Like {!subvec} but raises [Invalid_argument] on out-of-range bounds. *)

val take : int -> 'a t -> 'a t
(** [take n v] keeps the first [n] elements (clamped). *)

val drop : int -> 'a t -> 'a t
(** [drop n v] drops the first [n] elements (clamped). *)

val take_last : int -> 'a t -> 'a t
(** [take_last n v] keeps the last [n] elements (clamped). *)

val drop_last : int -> 'a t -> 'a t
(** [drop_last n v] drops the last [n] elements (clamped). *)

val butlast : 'a t -> 'a t
(** [butlast v] drops the last element — Clojure's [butlast]. *)

val take_while : ('a -> bool) -> 'a t -> 'a t
(** [take_while p v] is the longest prefix satisfying [p]. *)

val drop_while : ('a -> bool) -> 'a t -> 'a t
(** [drop_while p v] drops the longest prefix satisfying [p]. *)

val split_at : int -> 'a t -> 'a t * 'a t
(** [split_at n v] is [(take n v, drop n v)] — Clojure's [split-at]. *)
val split_with : ('a -> bool) -> 'a t -> 'a t * 'a t
(** [split_with p v] is [(take_while p v, drop_while p v)]. *)

val slice : ?start:int -> ?stop:int -> 'a t -> 'a t
(** [slice ?start ?stop v] is the clamped half-open slice. *)

val catvec : 'a t -> 'a t -> 'a t
(** [catvec a b] is the concatenation [a ++ b] — Clojure's [catvec]. *)

val concat : 'a t -> 'a t -> 'a t
(** Alias for {!catvec}. *)

val append : 'a t -> 'a t -> 'a t
(** Alias for {!catvec}. *)


(** {1 Iteration and folding} *)

val iter : ('a -> unit) -> 'a t -> unit
(** [iter f v] applies [f] to each element in order, for effects. *)

val iteri : (int -> 'a -> unit) -> 'a t -> unit
(** [iteri f v] applies [f i x] to each element with its index. *)

val iter2 : ('a -> 'b -> unit) -> 'a t -> 'b t -> unit
(** [iter2 f a b] applies [f] to paired elements; raises [Invalid_argument] on
    unequal lengths. *)

val fold_left : ('acc -> 'a -> 'acc) -> 'acc -> 'a t -> 'acc
(** Left fold over [v]. *)

val fold_right : ('a -> 'acc -> 'acc) -> 'a t -> 'acc -> 'acc
(** Right fold over [v]. *)

val foldi : ('acc -> int -> 'a -> 'acc) -> 'acc -> 'a t -> 'acc
(** [foldi f acc v] folds [f acc i x] over each element with its index. *)
val reduce : ('acc -> 'a -> 'acc) -> 'acc -> 'a t -> 'acc
(** [reduce] is {!fold_left} — Clojure's [(reduce f init coll)]. *)

val reduce_kv : ('acc -> int -> 'a -> 'acc) -> 'acc -> 'a t -> 'acc
(** [reduce_kv f acc v] folds with indices — Clojure's [reduce-kv]. *)

val reduce_r : ('acc -> 'a -> 'acc Reduced.t) -> 'acc -> 'a t -> 'acc
(** [reduce_r f acc v] stops early when [f] returns [Reduced.reduced _]. *)

val exists : ('a -> bool) -> 'a t -> bool
(** [exists p v] is [true] when some element satisfies [p]. *)

val for_all : ('a -> bool) -> 'a t -> bool
(** [for_all p v] is [true] when every element satisfies [p]. *)

val every_ : ('a -> bool) -> 'a t -> bool
(** Alias for {!for_all} — Clojure's [every?]. *)

val some : ('a -> bool) -> 'a t -> 'a option
(** [some p v] is the first element satisfying [p] — like Clojure's [(some (fn
    [x] (when (p x) x)) v)]. *)

val not_any_ : ('a -> bool) -> 'a t -> bool
(** [not_any_ p v] is [not (exists p v)] — Clojure's [not-any?]. *)

val not_every_ : ('a -> bool) -> 'a t -> bool
(** [not_every_ p v] is [not (for_all p v)] — Clojure's [not-every?]. *)

val find : ('a -> bool) -> 'a t -> 'a option
(** Alias for {!some}. *)

val find_map : ('a -> 'b option) -> 'a t -> 'b option
(** [find_map f v] is the first [Some _] produced by [f]. *)

(** {1 Transformations} *)

val map : ('a -> 'b) -> 'a t -> 'b t
(** [map f v] applies [f] to each element, eagerly returning a vector. *)

val mapv : ('a -> 'b) -> 'a t -> 'b t
(** Alias for {!map} — Clojure's [mapv]. *)

val mapi : (int -> 'a -> 'b) -> 'a t -> 'b t
(** [mapi f v] maps [f i x] over each element with its index. *)

val map_indexed : (int -> 'a -> 'b) -> 'a t -> 'b t
(** Alias for {!mapi} — Clojure's [map-indexed]. *)

val filter : ('a -> bool) -> 'a t -> 'a t
(** [filter p v] keeps elements satisfying [p], in order. *)

val filterv : ('a -> bool) -> 'a t -> 'a t
(** Alias for {!filter} — Clojure's [filterv]. *)

val remove : ('a -> bool) -> 'a t -> 'a t
(** [remove p v] drops elements satisfying [p] — Clojure's [remove]. *)

val filter_map : ('a -> 'b option) -> 'a t -> 'b t
(** [filter_map f v] maps [f] and drops [None] results. *)

val keep : ('a -> 'b option) -> 'a t -> 'b t
(** Alias for {!filter_map} — Clojure's [keep]. *)

val keep_indexed : (int -> 'a -> 'b option) -> 'a t -> 'b t
(** [keep_indexed f v] maps [f i x] and drops [None] results — Clojure's
    [keep-indexed]. *)

val mapcat : ('a -> 'b t) -> 'a t -> 'b t
(** [mapcat f v] maps [f] and concatenates the result vectors. *)

val flat_map : ('a -> 'b t) -> 'a t -> 'b t
(** Alias for {!mapcat}. *)
val zip : 'a t -> 'b t -> ('a * 'b) t
(** [zip a b] pairs elements; stops at the shorter — Clojure semantics. *)

val map2 : ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'c t
(** [map2 f a b] stops at the shorter — Clojure's [map f a b]. *)
val rev : 'a t -> 'a t
(** [rev v] is [v] in reverse order. *)

val reverse : 'a t -> 'a t
(** Alias for {!rev} — Clojure's [reverse]. *)

val sort : ?cmp:('a -> 'a -> int) -> 'a t -> 'a t
(** [sort ?cmp v] sorts ascending by [cmp] (default [Stdlib.compare]) —
    Clojure's [sort]. *)

val sort_by : ?cmp:('b -> 'b -> int) -> ('a -> 'b) -> 'a t -> 'a t
(** [sort_by ?cmp f v] sorts ascending by the keys [f x] — Clojure's
    [sort-by]. *)

val sort_uniq : ?cmp:('a -> 'a -> int) -> 'a t -> 'a t
(** [sort_uniq ?cmp v] sorts and removes duplicates. *)

val shuffle : ?rng:Stdlib.Random.State.t -> 'a t -> 'a t
(** [shuffle ?rng v] randomly permutes [v] (Fisher-Yates) — Clojure's
    [shuffle]. *)
val distinct : 'a t -> 'a t
(** Removes duplicates, keeping first occurrences (structural equality). *)

val dedupe : 'a t -> 'a t
(** Collapses runs of equal adjacent elements — Clojure's [dedupe]. *)

val split_by : ('a -> bool) -> 'a t -> 'a t * 'a t
(** [split_by p v] splits [v] into [(matching, non-matching)], preserving
    order. *)

val partition : int -> 'a t -> 'a t t
(** [partition n v] groups consecutive elements into vectors of exactly size
    [n]; leftover elements are dropped — Clojure's [partition]. *)

val partition_all : int -> 'a t -> 'a t t
(** [partition_all n v] is {!partition} but keeps the trailing partial chunk —
    Clojure's [partition-all]. *)

(** {1 Conversions} *)

val seq : 'a t -> 'a Stdlib.Seq.t
(** [seq v] views [v] as a sequence front-to-back. *)

val to_seq : 'a t -> 'a Stdlib.Seq.t
(** Alias for {!seq}. *)
val rseq : 'a t -> 'a Stdlib.Seq.t
(** [rseq v] iterates back to front — Clojure's [rseq]. *)

val rest : 'a t -> 'a Stdlib.Seq.t
(** [rest v] is the elements after the first — Clojure's [rest] returns a seq,
    empty on empty input. *)

val next : 'a t -> 'a Stdlib.Seq.t option
(** [next v] is [None] when {!rest} would be empty — Clojure's [next]. *)

val to_list : 'a t -> 'a list
(** [to_list v] is the element list, in order. *)

val to_array : 'a t -> 'a array
(** [to_array v] copies [v] into a fresh array. *)
val into : 'a t -> 'a Stdlib.Seq.t -> 'a t
(** [into v s] conjs every element of [s] onto [v]. *)

(** {1 Equality and comparison} *)

val equal : ?eq:('a -> 'a -> bool) -> 'a t -> 'a t -> bool
(** [equal ?eq a b] compares element-wise with [eq] (default [(=)]). *)

val compare : ?cmp:('a -> 'a -> int) -> 'a t -> 'a t -> int
(** [compare ?cmp a b] lexicographic comparison with [cmp] (default
    [Stdlib.compare]); a shorter prefix sorts first. *)
