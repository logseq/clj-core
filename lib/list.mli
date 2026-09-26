(** Persistent lists — Clojure's list API over OCaml's ['a list].

    [conj]/[cons] prepend (O(1)); [first]/[rest] match Clojure semantics. Seq
    operations put the list last so they chain under [|>]. *)

val empty : 'a list
val list : 'a list -> 'a list
val of_seq : 'a Stdlib.Seq.t -> 'a list
val of_array : 'a array -> 'a list
val of_vec : 'a Vec.t -> 'a list
val to_seq : 'a list -> 'a Stdlib.Seq.t
val seq : 'a list -> 'a Stdlib.Seq.t
val to_vec : 'a list -> 'a Vec.t
val to_array : 'a list -> 'a array

val count : 'a list -> int
val length : 'a list -> int
val empty_ : 'a list -> bool
val is_empty : 'a list -> bool
val mem : 'a -> 'a list -> bool

val first : 'a list -> 'a option
val rest : 'a list -> 'a list
val next : 'a list -> 'a list option
(** [next l] is [None] when {!rest} is empty — Clojure's [next]. *)

val second : 'a list -> 'a option
val last : 'a list -> 'a option
val butlast : 'a list -> 'a list
val nth : 'a list -> int -> 'a
val nth_opt : 'a list -> int -> 'a option
val peek : 'a list -> 'a option
(** [peek] is {!first}. *)

val pop : 'a list -> 'a list
(** [pop] is {!rest}; raises [Failure] on empty. *)

val pop_opt : 'a list -> 'a list option
val conj : 'a list -> 'a -> 'a list
(** [conj l x] prepends — Clojure's [(conj '(a) x)] is [(x a)]. *)

val cons : 'a -> 'a list -> 'a list
val into : 'a list -> 'a Stdlib.Seq.t -> 'a list
(** [into l s] conjs each element — as in Clojure, they land reversed at the
    front. *)

val map : ('a -> 'b) -> 'a list -> 'b list
val mapi : (int -> 'a -> 'b) -> 'a list -> 'b list
val map_indexed : (int -> 'a -> 'b) -> 'a list -> 'b list
val filter : ('a -> bool) -> 'a list -> 'a list
val remove : ('a -> bool) -> 'a list -> 'a list
val filter_map : ('a -> 'b option) -> 'a list -> 'b list
val keep : ('a -> 'b option) -> 'a list -> 'b list
val mapcat : ('a -> 'b list) -> 'a list -> 'b list
val flat_map : ('a -> 'b list) -> 'a list -> 'b list
val concat : 'a list list -> 'a list
val flatten : 'a list list -> 'a list
val zip : 'a list -> 'b list -> ('a * 'b) list
val map2 : ('a -> 'b -> 'c) -> 'a list -> 'b list -> 'c list
val iter : ('a -> unit) -> 'a list -> unit
val iteri : (int -> 'a -> unit) -> 'a list -> unit
val fold : ('acc -> 'a -> 'acc) -> 'acc -> 'a list -> 'acc
val reduce : ('acc -> 'a -> 'acc) -> 'acc -> 'a list -> 'acc
val fold_left : ('acc -> 'a -> 'acc) -> 'acc -> 'a list -> 'acc
val fold_right : ('a -> 'acc -> 'acc) -> 'a list -> 'acc -> 'acc

val reduce_r : ('acc -> 'a -> 'acc Reduced.t) -> 'acc -> 'a list -> 'acc

val every_ : ('a -> bool) -> 'a list -> bool
val for_all : ('a -> bool) -> 'a list -> bool
val some : ('a -> bool) -> 'a list -> 'a option
val not_any_ : ('a -> bool) -> 'a list -> bool
val not_every_ : ('a -> bool) -> 'a list -> bool
val find : ('a -> bool) -> 'a list -> 'a option
val find_map : ('a -> 'b option) -> 'a list -> 'b option

val take : int -> 'a list -> 'a list
val drop : int -> 'a list -> 'a list
val take_while : ('a -> bool) -> 'a list -> 'a list
val drop_while : ('a -> bool) -> 'a list -> 'a list
val take_last : int -> 'a list -> 'a list
val drop_last : int -> 'a list -> 'a list
val take_nth : int -> 'a list -> 'a list
val nthrest : 'a list -> int -> 'a list
val split_at : int -> 'a list -> 'a list * 'a list
val split_with : ('a -> bool) -> 'a list -> 'a list * 'a list
val partition : int -> 'a list -> 'a list list
val partition_all : int -> 'a list -> 'a list list
val partition_by : ('a -> 'b) -> 'a list -> 'a list list
val interleave : 'a list -> 'a list -> 'a list
val interpose : 'a -> 'a list -> 'a list
val dedupe : 'a list -> 'a list
val distinct : 'a list -> 'a list
val reverse : 'a list -> 'a list
val rev : 'a list -> 'a list
val sort : ?cmp:('a -> 'a -> int) -> 'a list -> 'a list
val sort_by : ?cmp:('b -> 'b -> int) -> ('a -> 'b) -> 'a list -> 'a list
val shuffle : ?rng:Stdlib.Random.State.t -> 'a list -> 'a list
val group_by : ?cmp:('k -> 'k -> int) -> ('a -> 'k) -> 'a list -> ('k, 'a Vec.t) Map.t
val frequencies : ?cmp:('a -> 'a -> int) -> 'a list -> ('a, int) Map.t
val equal : ?eq:('a -> 'a -> bool) -> 'a list -> 'a list -> bool
val compare : ?cmp:('a -> 'a -> int) -> 'a list -> 'a list -> int
