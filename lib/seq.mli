(** Lazy sequences — Clojure's seq abstraction over {!Stdlib.Seq.t}.

    A ['a Seq.t] is a [unit -> 'a node] thunk chain: it is lazy, possibly
    infinite, and pure only when its producer is. Following Clojure
    conventions, seq-taking functions put the sequence last ([map f s],
    [take n s]) so they chain with [|>]. *)

type 'a t = 'a Stdlib.Seq.t
(** A lazy sequence: a thunk chain producing elements on demand. *)

type 'a node = 'a Stdlib.Seq.node = Nil | Cons of 'a * 'a t
(** The step result: [Nil] ends the sequence, [Cons (x, rest)] yields [x]. *)

(** {1 Construction} *)

val empty : 'a t
(** The empty sequence. *)

val singleton : 'a -> 'a t
(** [singleton x] is the one-element sequence [[x]]. *)

val return : 'a -> 'a t
(** Alias for {!singleton}. *)

val cons : 'a -> 'a t -> 'a t
(** [cons x s] prepends [x] — Clojure's [(cons x s)]. *)

val of_list : 'a list -> 'a t
(** [of_list xs] iterates the list in order. *)

val of_array : 'a array -> 'a t
(** [of_array a] iterates the array in order. *)

val of_string : string -> char t
(** [of_string s] iterates characters. *)

val unfold : ('b -> ('a * 'b) option) -> 'b -> 'a t
(** [unfold f seed] produces [(x, seed')] steps until [f] returns [None]. *)

val init : int -> (int -> 'a) -> 'a t
(** [init n f] is [f 0; f 1; ...; f (n-1)] — lazy. *)
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
(** [cycle s] loops [s] forever — infinite, empty on empty. The first pass
    is realized into a buffer and replayed, matching Clojure: an effectful
    source sequence is evaluated only once. *)

val range : ?start:int -> ?step:int -> int -> int t
(** [range ?start ?step stop] counts toward [stop] (exclusive), default
    [start=0], [step=1]. *)

val ints : ?start:int -> ?step:int -> unit -> int t
(** [ints ()] is [0; 1; 2; ...] — infinite. *)

val append : 'a t -> 'a t -> 'a t
(** [append a b] is [a] followed by [b] — lazy. *)

val concat : 'a t t -> 'a t
(** [concat ss] flattens a sequence of sequences — Clojure's variadic
    [concat]. *)

val concat_list : 'a t list -> 'a t
(** Like {!concat} over a list of sequences. *)

val interleave : 'a t -> 'a t -> 'a t
(** [interleave a b] alternates elements; ends when either is exhausted. *)

val interpose : 'a -> 'a t -> 'a t
(** [interpose sep s] inserts [sep] between elements. *)

val zip : 'a t -> 'b t -> ('a * 'b) t
(** [zip a b] pairs elements; ends at the shorter — lazy. *)

val map2 : ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'c t
(** [map2 f a b] maps pairs; ends at the shorter — lazy, like Clojure's
    variadic [map]. *)

(** {1 Access} *)

val uncons : 'a t -> ('a * 'a t) option
(** [uncons s] is [Some (x, rest)] or [None] on empty. *)
val seq : 'a t -> 'a t option
(** [seq s] is [None] on empty — Clojure's [seq]. *)

val first : 'a t -> 'a option
(** [first s] is the head, [None] on empty — Clojure's [(first s)]. *)
val rest : 'a t -> 'a t
(** [rest s] is the elements after the first; empty on empty. *)

val next : 'a t -> 'a t option
(** [next s] is [rest s] as a [seq] — [None] when no elements remain. *)

val second : 'a t -> 'a option
(** [second s] is the second element — Clojure's [(second s)]. *)

val last : 'a t -> 'a option
(** [last s] is the final element (realizes the whole sequence — an infinite
    sequence diverges) — Clojure's [(last s)]. *)

val butlast : 'a t -> 'a t
(** [butlast s] is [s] without the final element — lazy, Clojure's
    [butlast]. *)

val nth : 'a t -> int -> 'a
(** [nth s i] is the element at index [i]; raises when out of bounds. *)

val nth_opt : 'a t -> int -> 'a option
(** [nth_opt s i] is [Some (nth s i)] or [None] out of bounds. *)
val nthrest : 'a t -> int -> 'a t
(** [nthrest s n] drops [n] elements — Clojure's [nthrest]. *)

val nth_next : 'a t -> int -> 'a t option
(** [nth_next s n] is [next] of {!nthrest} — Clojure's [nthnext]. *)

val fnext : 'a t -> 'a option
(** [fnext s] is [first] of {!next} — Clojure's [fnext]. *)

val nfirst : 'a t t -> 'a t option
(** [nfirst s] is [next] of {!first} — Clojure's [nfirst] on a seq of
    seqs. *)

val nnext : 'a t -> 'a t option
(** [nnext s] is [next] of {!next} — Clojure's [nnext]. *)

val count : 'a t -> int
(** [count s] realizes [s] and returns its length — Clojure's [(count s)].
    An infinite sequence diverges. *)

val bounded_count : int -> 'a t -> int
(** [bounded_count n s] counts up to [n] elements — realizes at most [n] of
    them, so it terminates on infinite seqs. Clojure's [bounded-count]. *)

val not_empty : 'a t -> 'a t option
(** [not_empty s] is [Some s] or [None] on empty — Clojure's [not-empty]. *)

val distinct_ : 'a t -> bool
(** [distinct_ s] is [true] when all elements are structurally distinct —
    realizes [s] once, holding a memo table while consumed. *)

val sequence : 'a t -> 'a t
(** [sequence s] is [s] — the coll->seq entry point lives at {!Core.sequence}
    (the transducer arity is not ported). *)

val length : 'a t -> int
(** Alias for {!count}. *)

val is_empty : 'a t -> bool
(** [is_empty s] forces one step and reports whether [s] is [Nil]. *)

val empty_ : 'a t -> bool
(** Alias for {!is_empty} — Clojure's [empty?]. *)

(** {1 Lazy transforms} *)

val map : ('a -> 'b) -> 'a t -> 'b t
(** [map f s] applies [f] per element, lazily — Clojure's [map]. *)

val mapi : (int -> 'a -> 'b) -> 'a t -> 'b t
(** [mapi f s] maps [f i x] with the index — lazy. *)

val map_indexed : (int -> 'a -> 'b) -> 'a t -> 'b t
(** Alias for {!mapi} — Clojure's [map-indexed]. *)

val filter : ('a -> bool) -> 'a t -> 'a t
(** [filter p s] keeps elements satisfying [p] — lazy. *)

val remove : ('a -> bool) -> 'a t -> 'a t
(** [remove p s] drops elements satisfying [p] — lazy, Clojure's [remove]. *)

val filter_map : ('a -> 'b option) -> 'a t -> 'b t
(** [filter_map f s] maps [f] and drops [None] results — lazy. *)

val keep : ('a -> 'b option) -> 'a t -> 'b t
(** [keep f s] keeps the [Some] results of [f] — Clojure's [keep]. *)

val keep_indexed : (int -> 'a -> 'b option) -> 'a t -> 'b t
(** [keep_indexed f s] maps [f i x] and drops [None] — lazy, Clojure's
    [keep-indexed]. *)

val mapcat : ('a -> 'b t) -> 'a t -> 'b t
(** [mapcat f s] maps [f] and flattens the result sequences — lazy. *)

val flat_map : ('a -> 'b t) -> 'a t -> 'b t
(** Alias for {!mapcat}. *)

val take : int -> 'a t -> 'a t
(** [take n s] keeps the first [n] elements — lazy. *)

val drop : int -> 'a t -> 'a t
(** [drop n s] skips the first [n] elements — lazy. *)
val take_last : int -> 'a t -> 'a list
(** [take_last n s] is the last [n] elements (realized eagerly — an infinite
    sequence diverges). *)

val drop_last : int -> 'a t -> 'a t
(** [drop_last n s] drops the last [n] elements — Clojure's [drop-last].
    Lazy, but must buffer [n] elements ahead. *)

val take_while : ('a -> bool) -> 'a t -> 'a t
(** [take_while p s] takes while [p] holds — lazy. *)

val drop_while : ('a -> bool) -> 'a t -> 'a t
(** [drop_while p s] drops while [p] holds — lazy. *)
val take_nth : int -> 'a t -> 'a t
(** [take_nth n s] keeps every [n]th element — Clojure's [take-nth]. *)

val split_at : int -> 'a t -> 'a t * 'a t
(** [split_at n s] is [(take n s, drop n s)] — Clojure's [split-at]. The
    shared prefix is realized twice unless [s] memoizes. *)

val split_with : ('a -> bool) -> 'a t -> 'a t * 'a t
(** [split_with p s] is [(take_while p s, drop_while p s)] — Clojure's
    [split-with]; the shared prefix is realized twice unless [s] memoizes. *)
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
(** Left fold — Clojure's [(reduce f init coll)]. *)

val fold_left : ('acc -> 'a -> 'acc) -> 'acc -> 'a t -> 'acc
(** Alias for {!reduce}. *)

val reduce_r : ('acc -> 'a -> 'acc Reduced.t) -> 'acc -> 'a t -> 'acc
(** [reduce_r f acc s] stops as soon as [f] returns [Reduced _]. *)

val iter : ('a -> unit) -> 'a t -> unit
(** [iter f s] applies [f] per element, for effects — realizes [s]. *)

val run_ : ('a -> 'b) -> 'a t -> unit
(** [run_ f s] applies [f] per element and discards the results — Clojure's
    [run!]. *)

val some_vals : 'a option t -> 'a t
(** [some_vals s] keeps the [Some] values — Clojure's [some-vals] — lazy. *)

val random_sample : ?prob:float -> ?rng:Stdlib.Random.State.t -> 'a t -> 'a t
(** [random_sample ?prob ?rng s] keeps each element with probability [prob]
    (default [1.0]) — lazy, Clojure's [random-sample]. *)

val replicate : int -> 'a -> 'a t
(** [replicate n x] is [repeat ~n x] — Clojure's [replicate]. *)

val every_ : ('a -> bool) -> 'a t -> bool
(** [every_ p s] is [true] when every element satisfies [p] — Clojure's
    [every?]. *)

val for_all : ('a -> bool) -> 'a t -> bool
(** Alias for {!every_}. *)

val some : ('a -> bool) -> 'a t -> 'a option
(** [some p s] is the first element satisfying [p]. *)

val exists : ('a -> bool) -> 'a t -> bool
(** [exists p s] is [true] when some element satisfies [p]. *)

val not_any_ : ('a -> bool) -> 'a t -> bool
(** [not_any_ p s] is [not (exists p s)] — Clojure's [not-any?]. *)

val not_every_ : ('a -> bool) -> 'a t -> bool
(** [not_every_ p s] is [not (every_ p s)] — Clojure's [not-every?]. *)

val find : ('a -> bool) -> 'a t -> 'a option
(** Alias for {!some}. *)

val find_map : ('a -> 'b option) -> 'a t -> 'b option
(** [find_map f s] is the first [Some _] produced by [f]. *)

val mem : 'a -> 'a t -> bool
(** [mem x s] is [true] when [x] occurs in [s] (structural equality). *)

(** {1 Eager transforms (consume the whole sequence)} *)

val sort : ?cmp:('a -> 'a -> int) -> 'a t -> 'a t
(** [sort ?cmp s] sorts ascending by [cmp] (default [Stdlib.compare]) —
    realizes [s] eagerly, then emits the sorted elements. *)

val sort_by : ?cmp:('b -> 'b -> int) -> ('a -> 'b) -> 'a t -> 'a t
(** [sort_by ?cmp f s] sorts ascending by the keys [f x] — Clojure's
    [sort-by]. *)

val reverse : 'a t -> 'a t
(** [reverse s] is [s] in reverse order — realizes [s] eagerly. *)

val shuffle : ?rng:Stdlib.Random.State.t -> 'a t -> 'a t
(** [shuffle ?rng s] randomly permutes [s] — realizes [s] eagerly. *)
val min_key : ?cmp:('b -> 'b -> int) -> ('a -> 'b) -> 'a t -> 'a option
(** [min_key f s] is the element minimizing [f] — Clojure's [min-key]
    generalized to a sequence. *)

val max_key : ?cmp:('b -> 'b -> int) -> ('a -> 'b) -> 'a t -> 'a option
(** [max_key f s] is the element maximizing [f] — Clojure's [max-key]. *)
val group_by : ?cmp:('k -> 'k -> int) -> ('a -> 'k) -> 'a t -> ('k, 'a Vec.t) Map.t
(** [group_by f s] buckets elements by [f x] — Clojure's [group-by]
    returning key -> vector. *)

val frequencies : ?cmp:('a -> 'a -> int) -> 'a t -> ('a, int) Map.t
(** [frequencies s] counts occurrences — Clojure's [frequencies]. *)

(** {1 Realization} *)

val doall : 'a t -> 'a list
(** [doall s] forces every element and returns them as a list — Clojure's
    [doall]. *)

val dorun : 'a t -> unit
(** [dorun s] forces every element, discarding results — Clojure's
    [dorun]. *)

val to_list : 'a t -> 'a list
(** Alias for {!doall}. *)

val to_vec : 'a t -> 'a Vec.t
(** [to_vec s] realizes [s] into a vector. *)

val to_array : 'a t -> 'a array
(** [to_array s] realizes [s] into a fresh array. *)

val to_set : ?cmp:('a -> 'a -> int) -> 'a t -> 'a Set.t
(** [to_set ?cmp s] realizes [s] into a set — Clojure's [(set s)]. *)

val of_map : ('k, 'v) Map.t -> ('k * 'v) t
(** [of_map m] iterates [(k, v)] entries in key order — Clojure's [(seq m)]. *)

val of_vec : 'a Vec.t -> 'a t
(** [of_vec v] iterates front-to-back — Clojure's [(seq v)]. *)

val of_set : 'a Set.t -> 'a t
(** [of_set s] iterates in ascending order — Clojure's [(seq s)]. *)

val of_queue : 'a Queue.t -> 'a t
(** [of_queue q] iterates front-to-back — Clojure's [(seq q)]. *)
