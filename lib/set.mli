(** Persistent sets — Clojure's set API on top of {!Map} (sorted, with
    structural sharing).

    Iteration order is ascending by the stored comparator, like Clojure's
    [sorted-set]. The default comparator is [Stdlib.compare]. *)

type 'a t
(** A persistent sorted set with unique elements. *)

(** {1 Construction} *)

val empty : ?cmp:('a -> 'a -> int) -> unit -> 'a t
(** [empty ?cmp ()] is an empty set ordered by [cmp] (default
    [Stdlib.compare]). *)

val singleton : ?cmp:('a -> 'a -> int) -> 'a -> 'a t
(** [singleton ?cmp x] is the one-element set [{x}]. *)

val of_list : ?cmp:(('a -> 'a -> int) @ local) -> 'a list @ local -> 'a t
(** [of_list ?cmp xs] builds a set; duplicates collapse. *)

val of_array : ?cmp:(('a -> 'a -> int) @ local) -> 'a array @ local -> 'a t
(** Like {!of_list} from an array. *)

val of_seq : ?cmp:(('a -> 'a -> int) @ local) -> 'a Stdlib.Seq.t @ local -> 'a t
(** Like {!of_list} from a sequence. *)

val set : ?cmp:(('a -> 'a -> int) @ local) -> 'a list @ local -> 'a t
val hash_set : ?cmp:(('a -> 'a -> int) @ local) -> 'a list @ local -> 'a t
val sorted_set : ?cmp:('a -> 'a -> int) -> 'a list -> 'a t
(** [set]/[hash_set]/[sorted_set] are [of_list] under the Clojure names. *)

val sorted_set_by : ('a -> 'a -> int) -> 'a list -> 'a t
(** [sorted_set_by cmp xs] is [of_list ~cmp] — Clojure's [sorted-set-by]. *)

val cmp : 'a t -> 'a -> 'a -> int
(** The comparator a set was built with. *)

(** {1 Predicates and size} *)

val count : 'a t @ local -> int
(** [count s] is the number of elements — Clojure's [(count s)]. *)

val empty_ : 'a t @ local -> bool
(** [empty_ s] is [true] when [s] has no elements — Clojure's [(empty? s)]. *)

val is_empty : 'a t @ local -> bool
(** Alias for {!empty_}. *)

val contains_ : 'a t @ local -> 'a @ local -> bool
(** [contains_ s x] is [true] when [x] is in [s] — Clojure's
    [(contains? s x)]. *)

val mem : 'a @ local -> 'a t @ local -> bool
(** [mem x s] is [contains_ s x] with flipped argument order. *)

(** {1 Update (persistent)} *)

val conj : 'a t -> 'a -> 'a t
(** [conj s x] adds [x] — Clojure's [(conj s x)]. *)

val disj : 'a t -> 'a -> 'a t
(** [disj s x] removes [x]; a missing element returns [s] — Clojure's
    [(disj s x)]. *)

val into : 'a t -> 'a Stdlib.Seq.t @ local -> 'a t
(** [into s xs] conjs every element of [xs] onto [s]. *)

(** {1 Set algebra} *)

val union : 'a t -> 'a t -> 'a t
(** [union a b] is the set union — clojure.set/union. Folds the smaller set
    into the larger; the result uses the larger set's comparator. *)

val intersection : 'a t -> 'a t -> 'a t
(** [intersection a b] is the set intersection — clojure.set/intersection.
    The result keeps [a]'s comparator. *)

val difference : 'a t -> 'a t -> 'a t
(** [difference a b] is [a] minus the elements of [b] — clojure.set/difference.
    The result keeps [a]'s comparator. *)

val subset_ : 'a t @ local -> 'a t @ local -> bool
(** [subset_ a b] is [true] when every element of [a] is in [b] —
    clojure.set/subset?. *)

val superset_ : 'a t @ local -> 'a t @ local -> bool
(** [superset_ a b] is [subset_ b a] — clojure.set/superset?. *)

(** {1 Transformations} *)

val select : ('a -> bool) -> 'a t -> 'a t
(** [select p s] keeps matching elements — Clojure's [select]. *)

val filter : ('a -> bool) -> 'a t -> 'a t
(** Alias for {!select}. *)

val remove : ('a -> bool) -> 'a t -> 'a t
(** [remove p s] drops matching elements — Clojure's [remove]. *)

val map : ?cmp:('b -> 'b -> int) -> ('a -> 'b) -> 'a t -> 'b t
(** [map f s] rebuilds a set of [f x]; duplicates collapse. *)

val slice : ?from_:'a -> ?to_:'a -> 'a t -> 'a t
(** [slice ?from_ ?to_ s] keeps elements with [from_ <= x < to_]. *)

val subseq : ?from_:'a -> ?to_:'a -> 'a t -> 'a Stdlib.Seq.t
(** [subseq ?from_ ?to_ s] is {!slice} as a sequence — Clojure's [subseq]
    range view. *)

val rsubseq : ?from_:'a -> ?to_:'a -> 'a t -> 'a Stdlib.Seq.t
(** Like {!subseq} but iterating descending — Clojure's [rsubseq]. *)

(** {1 Extremes} *)

val min_elt : 'a t @ local -> 'a option
(** The smallest element, [None] on empty. *)

val max_elt : 'a t @ local -> 'a option
(** The largest element, [None] on empty. *)

val first : 'a t @ local -> 'a option
(** Alias for {!min_elt} — Clojure's [(first s)]. *)

val last : 'a t @ local -> 'a option
(** Alias for {!max_elt} — Clojure's [(last s)]. *)

(** {1 Iteration} *)

val iter : ('a -> unit) @ local -> 'a t @ local -> unit
(** [iter f s] applies [f] to each element in ascending order. *)

val fold : ('acc -> 'a -> 'acc) @ local -> 'acc -> 'a t @ local -> 'acc
(** Left fold over elements in ascending order. *)

val every_ : ('a -> bool) @ local -> 'a t @ local -> bool
(** [every_ p s] is [true] when every element satisfies [p] — Clojure's
    [every?]. *)

val for_all : ('a -> bool) @ local -> 'a t @ local -> bool
(** Alias for {!every_}. *)

val some : ('a -> bool) @ local -> 'a t @ local -> 'a option
(** [some p s] is the first (smallest) element satisfying [p]. *)

val exists : ('a -> bool) @ local -> 'a t @ local -> bool
(** [exists p s] is [true] when some element satisfies [p]. *)

val find : ('a -> bool) @ local -> 'a t @ local -> 'a option
(** Alias for {!some}. *)

val count_matching : ('a -> bool) @ local -> 'a t @ local -> int
(** [count_matching p s] counts elements satisfying [p]. *)

(** {1 Conversions} *)

val seq : 'a t -> 'a Stdlib.Seq.t
(** [seq s] iterates elements in ascending order. *)

val to_seq : 'a t -> 'a Stdlib.Seq.t
(** Alias for {!seq}. *)

val rseq : 'a t -> 'a Stdlib.Seq.t
(** [rseq s] iterates elements in descending order — Clojure's [rseq]. *)

val to_list : 'a t @ local -> 'a list
(** [to_list s] is the sorted element list. *)

val to_vec : 'a t @ local -> 'a Vec.t
(** [to_vec s] is the sorted elements as a vector. *)

(** {1 Equality} *)

val equal : 'a t @ local -> 'a t @ local -> bool
(** Sets are equal when they contain the same elements; comparators need not
    match. *)

(* borrow variants *)
val to_seq_local : 'a t @ local -> 'a Stdlib.Seq.t @ local

