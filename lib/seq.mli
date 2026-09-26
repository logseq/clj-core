(** Lazy sequences — Clojure's seq abstraction over {!Stdlib.Seq.t}.

    A ['a Seq.t] is a [unit -> 'a node] thunk chain: it is lazy, possibly
    infinite, and pure only when its producer is. Following Clojure
    conventions, seq-taking functions put the sequence last ([map f s],
    [take n s]) so they chain with [|>]. *)

type 'a t = 'a Stdlib.Seq.t

type 'a node = 'a Stdlib.Seq.node = Nil | Cons of 'a * 'a t

(** {1 Construction} *)

val empty : 'a t
val singleton : 'a -> 'a t
val return : 'a -> 'a t
val cons : 'a -> 'a t -> 'a t
val of_list : 'a list -> 'a t
val of_array : 'a array -> 'a t
val of_string : string -> char t
val unfold : ('b -> ('a * 'b) option) -> 'b -> 'a t
val init : int -> (int -> 'a) -> 'a t
val lazy_seq : (unit -> 'a t) -> 'a t
(** [lazy_seq f] defers [f] until the result is consumed — Clojure's
    [lazy-seq]. *)

val iterate : ('a -> 'a) -> 'a -> 'a t
(** [iterate f x] is [x; f x; f (f x); ...] — infinite. *)

val repeat : ?n:int -> 'a -> 'a t
(** [repeat x] repeats [x] forever; [repeat ~n x] repeats [n] times. *)

val repeatedly : ?n:int -> (unit -> 'a) -> 'a t
(** [repeatedly f] calls [f] each step — infinite unless [~n] bounds it. *)

val cycle : 'a t -> 'a t
(** [cycle s] loops [s] forever — infinite; re-evaluates [s] each pass. *)

val range : ?start:int -> ?step:int -> int -> int t
(** [range ?start ?step stop] counts toward [stop] (exclusive), default
    [start=0], [step=1]. *)

val ints : ?start:int -> ?step:int -> unit -> int t
(** [ints ()] is [0; 1; 2; ...] — infinite. *)

val append : 'a t -> 'a t -> 'a t
val concat : 'a t t -> 'a t
(** [concat ss] flattens a sequence of sequences — Clojure's variadic
    [concat]. *)

val concat_list : 'a t list -> 'a t
val interleave : 'a t -> 'a t -> 'a t
val interpose : 'a -> 'a t -> 'a t
(** [interpose sep s] inserts [sep] between elements. *)

val zip : 'a t -> 'b t -> ('a * 'b) t
val map2 : ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'c t

(** {1 Access} *)

val uncons : 'a t -> ('a * 'a t) option
val seq : 'a t -> 'a t option
(** [seq s] is [None] on empty — Clojure's [seq]. *)

val first : 'a t -> 'a option
val rest : 'a t -> 'a t
(** [rest s] is the elements after the first; empty on empty. *)

val next : 'a t -> 'a t option
(** [next s] is [rest s] as a [seq] — [None] when no elements remain. *)

val second : 'a t -> 'a option
val last : 'a t -> 'a option
val butlast : 'a t -> 'a t
val nth : 'a t -> int -> 'a
val nth_opt : 'a t -> int -> 'a option
val nthrest : 'a t -> int -> 'a t
(** [nthrest s n] drops [n] elements — Clojure's [nthrest]. *)

val count : 'a t -> int
val length : 'a t -> int
val is_empty : 'a t -> bool
val empty_ : 'a t -> bool

(** {1 Lazy transforms} *)

val map : ('a -> 'b) -> 'a t -> 'b t
val mapi : (int -> 'a -> 'b) -> 'a t -> 'b t
val map_indexed : (int -> 'a -> 'b) -> 'a t -> 'b t
val filter : ('a -> bool) -> 'a t -> 'a t
val remove : ('a -> bool) -> 'a t -> 'a t
val filter_map : ('a -> 'b option) -> 'a t -> 'b t
val keep : ('a -> 'b option) -> 'a t -> 'b t
(** [keep f s] keeps the [Some] results of [f] — Clojure's [keep]. *)

val keep_indexed : (int -> 'a -> 'b option) -> 'a t -> 'b t
val mapcat : ('a -> 'b t) -> 'a t -> 'b t
val flat_map : ('a -> 'b t) -> 'a t -> 'b t
val take : int -> 'a t -> 'a t
val drop : int -> 'a t -> 'a t
val take_last : int -> 'a t -> 'a list
(** [take_last n s] is the last [n] elements (realized eagerly — an infinite
    sequence diverges). *)

val drop_last : int -> 'a t -> 'a t
val take_while : ('a -> bool) -> 'a t -> 'a t
val drop_while : ('a -> bool) -> 'a t -> 'a t
val take_nth : int -> 'a t -> 'a t
(** [take_nth n s] keeps every [n]th element — Clojure's [take-nth]. *)

val split_at : int -> 'a t -> 'a t * 'a t
val split_with : ('a -> bool) -> 'a t -> 'a t * 'a t
val partition : int -> 'a t -> 'a t t
(** [partition n s] groups into complete chunks of [n]; leftovers dropped. *)

val partition_all : int -> 'a t -> 'a t t
(** Like {!partition} but keeps the trailing partial chunk. *)

val partition_by : ('a -> 'b) -> 'a t -> 'a t t
(** [partition_by f s] starts a new chunk whenever [f x] changes —
    Clojure's [partition-by]. *)

val dedupe : 'a t -> 'a t
(** Collapses adjacent equal elements. *)

val distinct : 'a t -> 'a t
(** Keeps first occurrences; uses structural hashing, so it holds a
    growing memo table while consumed. *)

val reductions : ('acc -> 'a -> 'acc) -> 'acc -> 'a t -> 'acc t
(** [reductions f acc s] emits each intermediate accumulator —
    Clojure's [reductions]. *)

val reduce : ('acc -> 'a -> 'acc) -> 'acc -> 'a t -> 'acc
val fold_left : ('acc -> 'a -> 'acc) -> 'acc -> 'a t -> 'acc

val reduce_r : ('acc -> 'a -> 'acc Reduced.t) -> 'acc -> 'a t -> 'acc
(** [reduce_r f acc s] stops as soon as [f] returns [Reduced _]. *)

val iter : ('a -> unit) -> 'a t -> unit
val every_ : ('a -> bool) -> 'a t -> bool
val for_all : ('a -> bool) -> 'a t -> bool
val some : ('a -> bool) -> 'a t -> 'a option
val exists : ('a -> bool) -> 'a t -> bool
val not_any_ : ('a -> bool) -> 'a t -> bool
val not_every_ : ('a -> bool) -> 'a t -> bool
val find : ('a -> bool) -> 'a t -> 'a option
val find_map : ('a -> 'b option) -> 'a t -> 'b option
val mem : 'a -> 'a t -> bool

(** {1 Eager transforms (consume the whole sequence)} *)

val sort : ?cmp:('a -> 'a -> int) -> 'a t -> 'a t
val sort_by : ?cmp:('b -> 'b -> int) -> ('a -> 'b) -> 'a t -> 'a t
val reverse : 'a t -> 'a t
val shuffle : ?rng:Stdlib.Random.State.t -> 'a t -> 'a t
val min_key : ?cmp:('b -> 'b -> int) -> ('a -> 'b) -> 'a t -> 'a option
(** [min_key f s] is the element minimizing [f] — Clojure's [min-key]
    generalized to a sequence. *)

val max_key : ?cmp:('b -> 'b -> int) -> ('a -> 'b) -> 'a t -> 'a option
val group_by : ?cmp:('k -> 'k -> int) -> ('a -> 'k) -> 'a t -> ('k, 'a Vec.t) Map.t
(** [group_by f s] buckets elements by [f x] — Clojure's [group-by]
    returning key -> vector. *)

val frequencies : ?cmp:('a -> 'a -> int) -> 'a t -> ('a, int) Map.t
(** [frequencies s] counts occurrences — Clojure's [frequencies]. *)

(** {1 Realization} *)

val doall : 'a t -> 'a list
val dorun : 'a t -> unit
val to_list : 'a t -> 'a list
val to_vec : 'a t -> 'a Vec.t
val to_array : 'a t -> 'a array
val to_set : ?cmp:('a -> 'a -> int) -> 'a t -> 'a Set.t
val of_map : ('k, 'v) Map.t -> ('k * 'v) t
val of_vec : 'a Vec.t -> 'a t
val of_set : 'a Set.t -> 'a t
val of_queue : 'a Queue.t -> 'a t
