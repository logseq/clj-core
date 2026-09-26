(** Persistent vectors — Clojure's [PersistentVector] over {!Rrbvec}.

    Indexed access and updates are O(log32 n); appends at either end are
    effectively O(1) while the edge buffers have room. All operations are
    persistent: the input vector is never modified. *)

type 'a t = 'a Rrbvec.t

(** {1 Construction} *)

val empty : 'a t
val singleton : 'a -> 'a t
val of_list : 'a list -> 'a t
val of_array : 'a array -> 'a t
val of_seq : 'a Stdlib.Seq.t -> 'a t
val init : int -> (int -> 'a) -> 'a t
val repeat : int -> 'a -> 'a t
val range : ?start:int -> ?step:int -> int -> int t
(** [range ?start ?step stop] is [\[start; start+step; ...\]) bounded by [stop],
    like Clojure's [(range start stop step)]. Defaults: [start=0], [step=1]. *)

val vec : 'a Stdlib.Seq.t -> 'a t
(** [vec s] materializes a sequence — Clojure's [(vec coll)]. *)

val vector : 'a list -> 'a t
(** [vector \[a; b; ...\]] — Clojure's [(vector a b ...)]. *)

(** {1 Predicates and size} *)

val count : 'a t -> int
val length : 'a t -> int
val empty_ : 'a t -> bool
val is_empty : 'a t -> bool
val contains_ : 'a t -> int -> bool
(** [contains_ v i] is [true] when [i] is a valid index — Clojure's [(contains?
    v i)] checks the index, not the value. Use {!mem} for values. *)

val mem : 'a -> 'a t -> bool

(** {1 Access} *)

val nth : 'a t -> int -> 'a
(** Raises [Invalid_argument] when out of bounds. *)

val nth_opt : 'a t -> int -> 'a option
val get : 'a t -> int -> 'a option
(** [get v i] is {!nth_opt} — Clojure's [(get v i)] returns nil when missing. *)

val first : 'a t -> 'a option
val last : 'a t -> 'a option
val peek : 'a t -> 'a option
(** [peek v] is {!last} — Clojure's [(peek v)]. *)

val peek_front : 'a t -> 'a option
val peek_back : 'a t -> 'a option

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
val push_back : 'a t -> 'a -> 'a t
val push_front : 'a t -> 'a -> 'a t
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
val take : int -> 'a t -> 'a t
(** [take n v] keeps the first [n] elements (clamped). *)

val drop : int -> 'a t -> 'a t
(** [drop n v] drops the first [n] elements (clamped). *)

val take_last : int -> 'a t -> 'a t
val drop_last : int -> 'a t -> 'a t
val butlast : 'a t -> 'a t
val take_while : ('a -> bool) -> 'a t -> 'a t
val drop_while : ('a -> bool) -> 'a t -> 'a t
val split_at : int -> 'a t -> 'a t * 'a t
val split_with : ('a -> bool) -> 'a t -> 'a t * 'a t
(** [split_with p v] is [(take_while p v, drop_while p v)]. *)

val slice : ?start:int -> ?stop:int -> 'a t -> 'a t
(** [slice ?start ?stop v] is the clamped half-open slice. *)

val catvec : 'a t -> 'a t -> 'a t
val concat : 'a t -> 'a t -> 'a t
val append : 'a t -> 'a t -> 'a t


(** {1 Iteration and folding} *)

val iter : ('a -> unit) -> 'a t -> unit
val iteri : (int -> 'a -> unit) -> 'a t -> unit
val iter2 : ('a -> 'b -> unit) -> 'a t -> 'b t -> unit
val fold_left : ('acc -> 'a -> 'acc) -> 'acc -> 'a t -> 'acc
val fold_right : ('a -> 'acc -> 'acc) -> 'a t -> 'acc -> 'acc
val foldi : ('acc -> int -> 'a -> 'acc) -> 'acc -> 'a t -> 'acc
val reduce : ('acc -> 'a -> 'acc) -> 'acc -> 'a t -> 'acc
(** [reduce] is {!fold_left} — Clojure's [(reduce f init coll)]. *)

val reduce_kv : ('acc -> int -> 'a -> 'acc) -> 'acc -> 'a t -> 'acc
(** [reduce_kv f acc v] folds with indices — Clojure's [reduce-kv]. *)

val reduce_r : ('acc -> 'a -> 'acc Reduced.t) -> 'acc -> 'a t -> 'acc
(** [reduce_r f acc v] stops early when [f] returns [Reduced.reduced _]. *)

val exists : ('a -> bool) -> 'a t -> bool
val for_all : ('a -> bool) -> 'a t -> bool
val every_ : ('a -> bool) -> 'a t -> bool
val some : ('a -> bool) -> 'a t -> 'a option
(** [some p v] is the first element satisfying [p] — like Clojure's [(some (fn
    [x] (when (p x) x)) v)]. *)

val not_any_ : ('a -> bool) -> 'a t -> bool
val not_every_ : ('a -> bool) -> 'a t -> bool
val find : ('a -> bool) -> 'a t -> 'a option
val find_map : ('a -> 'b option) -> 'a t -> 'b option

(** {1 Transformations} *)

val map : ('a -> 'b) -> 'a t -> 'b t
val mapv : ('a -> 'b) -> 'a t -> 'b t
val mapi : (int -> 'a -> 'b) -> 'a t -> 'b t
val map_indexed : (int -> 'a -> 'b) -> 'a t -> 'b t
val filter : ('a -> bool) -> 'a t -> 'a t
val filterv : ('a -> bool) -> 'a t -> 'a t
val remove : ('a -> bool) -> 'a t -> 'a t
val filter_map : ('a -> 'b option) -> 'a t -> 'b t
val keep : ('a -> 'b option) -> 'a t -> 'b t
val keep_indexed : (int -> 'a -> 'b option) -> 'a t -> 'b t
val mapcat : ('a -> 'b t) -> 'a t -> 'b t
val flat_map : ('a -> 'b t) -> 'a t -> 'b t
val zip : 'a t -> 'b t -> ('a * 'b) t
(** [zip a b] pairs elements; stops at the shorter — Clojure semantics. *)

val map2 : ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'c t
(** [map2 f a b] stops at the shorter — Clojure's [map f a b]. *)
val rev : 'a t -> 'a t
val reverse : 'a t -> 'a t
val sort : ?cmp:('a -> 'a -> int) -> 'a t -> 'a t
val sort_by : ?cmp:('b -> 'b -> int) -> ('a -> 'b) -> 'a t -> 'a t
val sort_uniq : ?cmp:('a -> 'a -> int) -> 'a t -> 'a t
val shuffle : ?rng:Stdlib.Random.State.t -> 'a t -> 'a t
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
val to_seq : 'a t -> 'a Stdlib.Seq.t
val rseq : 'a t -> 'a Stdlib.Seq.t
(** [rseq v] iterates back to front — Clojure's [rseq]. *)

val rest : 'a t -> 'a Stdlib.Seq.t
(** [rest v] is the elements after the first — Clojure's [rest] returns a seq,
    empty on empty input. *)

val next : 'a t -> 'a Stdlib.Seq.t option
(** [next v] is [None] when {!rest} would be empty — Clojure's [next]. *)

val to_list : 'a t -> 'a list
val to_array : 'a t -> 'a array
val into : 'a t -> 'a Stdlib.Seq.t -> 'a t
(** [into v s] conjs every element of [s] onto [v]. *)

(** {1 Equality and comparison} *)

val equal : ?eq:('a -> 'a -> bool) -> 'a t -> 'a t -> bool
val compare : ?cmp:('a -> 'a -> int) -> 'a t -> 'a t -> int
