(** Persistent sets — Clojure's set API on top of {!Map} (sorted, with
    structural sharing).

    Iteration order is ascending by the stored comparator, like Clojure's
    [sorted-set]. The default comparator is [Stdlib.compare]. *)

type 'a t

val empty : ?cmp:('a -> 'a -> int) -> unit -> 'a t
val singleton : ?cmp:('a -> 'a -> int) -> 'a -> 'a t
val of_list : ?cmp:('a -> 'a -> int) -> 'a list -> 'a t
val of_array : ?cmp:('a -> 'a -> int) -> 'a array -> 'a t
val of_seq : ?cmp:('a -> 'a -> int) -> 'a Stdlib.Seq.t -> 'a t
val set : ?cmp:('a -> 'a -> int) -> 'a list -> 'a t
val hash_set : ?cmp:('a -> 'a -> int) -> 'a list -> 'a t
val sorted_set : ?cmp:('a -> 'a -> int) -> 'a list -> 'a t
(** [set]/[hash_set]/[sorted_set] are [of_list] under the Clojure names. *)

val cmp : 'a t -> 'a -> 'a -> int
val count : 'a t -> int
val empty_ : 'a t -> bool
val is_empty : 'a t -> bool
val contains_ : 'a t -> 'a -> bool
val mem : 'a -> 'a t -> bool

val conj : 'a t -> 'a -> 'a t
val disj : 'a t -> 'a -> 'a t
val into : 'a t -> 'a Stdlib.Seq.t -> 'a t

val union : 'a t -> 'a t -> 'a t
val intersection : 'a t -> 'a t -> 'a t
val difference : 'a t -> 'a t -> 'a t
val subset_ : 'a t -> 'a t -> bool
val superset_ : 'a t -> 'a t -> bool

val select : ('a -> bool) -> 'a t -> 'a t
(** [select p s] keeps matching elements — Clojure's [select]. *)

val filter : ('a -> bool) -> 'a t -> 'a t
val remove : ('a -> bool) -> 'a t -> 'a t
val map : ?cmp:('b -> 'b -> int) -> ('a -> 'b) -> 'a t -> 'b t
(** [map f s] rebuilds a set of [f x]; duplicates collapse. *)

val min_elt : 'a t -> 'a option
val max_elt : 'a t -> 'a option
val first : 'a t -> 'a option
val last : 'a t -> 'a option

val slice : ?from_:'a -> ?to_:'a -> 'a t -> 'a t
(** [slice ?from_ ?to_ s] keeps elements with [from_ <= x < to_]. *)

val iter : ('a -> unit) -> 'a t -> unit
val fold : ('acc -> 'a -> 'acc) -> 'acc -> 'a t -> 'acc
val every_ : ('a -> bool) -> 'a t -> bool
val for_all : ('a -> bool) -> 'a t -> bool
val some : ('a -> bool) -> 'a t -> 'a option
val exists : ('a -> bool) -> 'a t -> bool
val find : ('a -> bool) -> 'a t -> 'a option
val count_matching : ('a -> bool) -> 'a t -> int

val seq : 'a t -> 'a Stdlib.Seq.t
val to_seq : 'a t -> 'a Stdlib.Seq.t
val rseq : 'a t -> 'a Stdlib.Seq.t
val to_list : 'a t -> 'a list
val to_vec : 'a t -> 'a Vec.t

val equal : 'a t -> 'a t -> bool
