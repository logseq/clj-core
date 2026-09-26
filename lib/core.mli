(** clojure.core — the daily-use layer.

    Collection-generic operations work on the polymorphic variant {!coll},
    which lifts every persistent collection (plus arrays, strings and lazy
    seqs) into one view:

    {[
      open Clj_core
      Core.map succ (`Vec (Vec.of_list [1; 2; 3]))
      Core.filter even (`Set myset)
      Core.first (Core.coll_of_string "abc")  (* Some 'a' *)
      Core.first (Core.coll_of_map m)         (* Some (k, v) *)
    ]}

    Seq-producing functions return lazy ['a Stdlib.Seq.t] — force with
    {!into_vec}, {!into_list} or {!doall}. *)

(** {1 Collection view} *)

type 'a coll =
  [ `Vec of 'a Vec.t
  | `Lst of 'a list
  | `Arr of 'a array
  | `Seq of 'a Stdlib.Seq.t
  | `Set of 'a Set.t ]
(** A collection viewed as a sequence-able value: vectors, lists, arrays,
    lazy seqs and sets; maps and strings enter via {!coll_of_map} and
    {!coll_of_string}. *)

val coll_of_map : ('k, 'v) Map.t -> ('k * 'v) coll
(** [coll_of_map m] views a map as a coll of [(key, value)] pairs. *)

val coll_of_string : string -> char coll
(** [coll_of_string s] views a string as a coll of characters. *)

val seq : 'a coll -> 'a Stdlib.Seq.t option
(** [seq c] is [None] when the collection is empty — Clojure's [seq]. *)

val to_seq : 'a coll -> 'a Stdlib.Seq.t
(** [to_seq c] iterates [c] in order (ascending for sets), returning a lazy
    sequence. *)

val count : 'a coll -> int
(** [count c] is the element count — Clojure's [(count c)]. *)

val empty_ : 'a coll -> bool
(** [empty_ c] is [true] when [c] has no elements — Clojure's [empty?]. *)

val is_empty : 'a coll -> bool
(** Alias for {!empty_}. *)

val first : 'a coll -> 'a option
(** [first c] is the first element, [None] on empty — Clojure's [first]. *)

val ffirst : 'a Stdlib.Seq.t coll -> 'a option
(** [ffirst c] is [first] of the first element — Clojure's [ffirst]. *)

val rest : 'a coll -> 'a Stdlib.Seq.t
(** [rest c] is the elements after the first; empty on empty — Clojure's
    [rest]. *)

val next : 'a coll -> 'a Stdlib.Seq.t option
(** [next c] is [rest c] as a {!seq} — [None] when no elements remain. *)

val second : 'a coll -> 'a option
(** [second c] is the second element — Clojure's [second]. *)

val last : 'a coll -> 'a option
(** [last c] is the last element — Clojure's [last]; diverges on infinite
    seqs. *)

val nth : 'a coll -> int -> 'a
(** [nth c i] is the element at index [i]; raises when out of bounds. *)

val nth_opt : 'a coll -> int -> 'a option
(** [nth_opt c i] is [Some (nth c i)] or [None] out of bounds. *)

val mem : 'a -> 'a coll -> bool
(** [mem x c] linear search — Clojure's [(some #(= x %) c)]. *)

(** {1 Seq transforms (lazy)} *)

val map : ('a -> 'b) -> 'a coll -> 'b Stdlib.Seq.t
(** [map f c] applies [f] per element, lazily — Clojure's [map]. *)

val filter : ('a -> bool) -> 'a coll -> 'a Stdlib.Seq.t
(** [filter p c] keeps elements satisfying [p] — lazy. *)

val remove : ('a -> bool) -> 'a coll -> 'a Stdlib.Seq.t
(** [remove p c] drops elements satisfying [p] — lazy, Clojure's [remove]. *)

val filter_map : ('a -> 'b option) -> 'a coll -> 'b Stdlib.Seq.t
(** [filter_map f c] maps [f] and drops [None] results — lazy. *)

val keep : ('a -> 'b option) -> 'a coll -> 'b Stdlib.Seq.t
(** Alias for {!filter_map} — Clojure's [keep]. *)

val keep_indexed : (int -> 'a -> 'b option) -> 'a coll -> 'b Stdlib.Seq.t
(** [keep_indexed f c] maps [f i x] and drops [None] — Clojure's
    [keep-indexed]. *)

val map_indexed : (int -> 'a -> 'b) -> 'a coll -> 'b Stdlib.Seq.t
(** [map_indexed f c] maps [f i x] with the index — Clojure's
    [map-indexed]. *)

val mapcat : ('a -> 'b coll) -> 'a coll -> 'b Stdlib.Seq.t
(** [mapcat f c] maps [f] and flattens the result colls — lazy, Clojure's
    [mapcat]. *)

val flat_map : ('a -> 'b coll) -> 'a coll -> 'b Stdlib.Seq.t
(** Alias for {!mapcat}. *)

val concat : 'a coll coll -> 'a Stdlib.Seq.t
(** [concat cs] flattens a coll of colls — lazy, Clojure's [concat]. *)

val take : int -> 'a coll -> 'a Stdlib.Seq.t
(** [take n c] keeps the first [n] elements — lazy. *)

val drop : int -> 'a coll -> 'a Stdlib.Seq.t
(** [drop n c] skips the first [n] elements — lazy. *)

val take_while : ('a -> bool) -> 'a coll -> 'a Stdlib.Seq.t
(** [take_while p c] takes while [p] holds — lazy. *)

val drop_while : ('a -> bool) -> 'a coll -> 'a Stdlib.Seq.t
(** [drop_while p c] drops while [p] holds — lazy. *)

val take_nth : int -> 'a coll -> 'a Stdlib.Seq.t
(** [take_nth n c] keeps every [n]th element — Clojure's [take-nth]. *)

val interpose : 'a -> 'a coll -> 'a Stdlib.Seq.t
(** [interpose sep c] inserts [sep] between elements — Clojure's
    [interpose]. *)

val dedupe : 'a coll -> 'a Stdlib.Seq.t
(** Collapses runs of equal adjacent elements — Clojure's [dedupe]. *)

val distinct : 'a coll -> 'a Stdlib.Seq.t
(** Keeps first occurrences — Clojure's [distinct]; holds a growing memo
    table while consumed. *)

val partition_all : int -> 'a coll -> 'a Stdlib.Seq.t Stdlib.Seq.t
(** [partition_all n c] groups into chunks of at most [n], keeping the
    trailing partial chunk — Clojure's [partition-all]. *)

val partition_by : ('a -> 'b) -> 'a coll -> 'a Stdlib.Seq.t Stdlib.Seq.t
(** [partition_by f c] starts a new chunk whenever [f x] changes —
    Clojure's [partition-by]. *)

val reductions : ('acc -> 'a -> 'acc) -> 'acc -> 'a coll -> 'acc Stdlib.Seq.t
(** [reductions f acc c] emits each intermediate accumulator — Clojure's
    [reductions]. *)

(** {1 Folding and searching} *)

val reduce : ('acc -> 'a -> 'acc) -> 'acc -> 'a coll -> 'acc
(** Left fold — Clojure's [(reduce f init coll)]. *)

val reduce_r : ('acc -> 'a -> 'acc Reduced.t) -> 'acc -> 'a coll -> 'acc
(** [reduce_r f acc c] stops early when [f] returns [Reduced.reduced _] —
    Clojure's [reduced]. *)

val fold : ('acc -> 'a -> 'acc) -> 'acc -> 'a coll -> 'acc
(** Alias for {!reduce}. *)

val iter : ('a -> unit) -> 'a coll -> unit
(** [iter f c] applies [f] per element, for effects. *)

val every_ : ('a -> bool) -> 'a coll -> bool
(** [every_ p c] is [true] when every element satisfies [p] — Clojure's
    [every?]. *)

val some : ('a -> bool) -> 'a coll -> 'a option
(** [some p c] is the first element satisfying [p]. *)

val not_any_ : ('a -> bool) -> 'a coll -> bool
(** [not_any_ p c] is [not (some p c)] — Clojure's [not-any?]. *)

val not_every_ : ('a -> bool) -> 'a coll -> bool
(** [not_every_ p c] is [not (every_ p c)] — Clojure's [not-every?]. *)

val find : ('a -> bool) -> 'a coll -> 'a option
(** Alias for {!some}. *)

val find_map : ('a -> 'b option) -> 'a coll -> 'b option
(** [find_map f c] is the first [Some _] produced by [f]. *)

(** {1 Eager transforms} *)

val reverse : 'a coll -> 'a Stdlib.Seq.t
(** [reverse c] is [c] in reverse order — realizes [c] eagerly, Clojure's
    [reverse]. *)

val sort : ?cmp:('a -> 'a -> int) -> 'a coll -> 'a Stdlib.Seq.t
(** [sort ?cmp c] sorts ascending by [cmp] (default [Stdlib.compare]) —
    realizes [c] eagerly. *)

val sort_by : ?cmp:('b -> 'b -> int) -> ('a -> 'b) -> 'a coll -> 'a Stdlib.Seq.t
(** [sort_by ?cmp f c] sorts ascending by the keys [f x] — Clojure's
    [sort-by]. *)

val shuffle : ?rng:Stdlib.Random.State.t -> 'a coll -> 'a Stdlib.Seq.t
(** [shuffle ?rng c] randomly permutes [c] — realizes [c] eagerly. *)

val group_by :
  ?cmp:('k -> 'k -> int) -> ('a -> 'k) -> 'a coll -> ('k, 'a Vec.t) Map.t
(** [group_by f c] buckets elements by [f x] into a map of key to vector —
    Clojure's [group-by]. *)

val frequencies : ?cmp:('a -> 'a -> int) -> 'a coll -> ('a, int) Map.t
(** [frequencies c] counts occurrences — Clojure's [frequencies]. *)

val min_key : ('a -> 'b) -> 'a coll -> 'a option
val max_key : ('a -> 'b) -> 'a coll -> 'a option
(** [min_key f c] is the element minimizing [f] — Clojure's [min-key];
    [max_key] maximizes. *)

(** {1 Realization} *)

val doall : 'a Stdlib.Seq.t -> 'a list
(** [doall s] forces every element and returns them as a list — Clojure's
    [doall]. *)

val dorun : 'a Stdlib.Seq.t -> unit
(** [dorun s] forces every element, discarding results — Clojure's
    [dorun]. *)

val into_vec : 'a coll -> 'a Vec.t
(** [into_vec c] collects [c] into a vector — Clojure's [(into [] ...)]. *)

val into_list : 'a coll -> 'a list
(** [into_list c] collects [c] into a list, preserving order —
    Clojure's [(into '() ...)] reverses; this function does not. *)

val into_set : ?cmp:('a -> 'a -> int) -> 'a coll -> 'a Set.t
(** [into_set c] collects [c] into a set — Clojure's [(into #{} ...)]. *)

val into_map : ?cmp:('k -> 'k -> int) -> ('k * 'v) coll -> ('k, 'v) Map.t
(** [into_map c] collects a pair seq into a {!Map.t} — Clojure's
    [(into {} ...)]. *)

(** {1 Generators} *)

val iterate : ('a -> 'a) -> 'a -> 'a Stdlib.Seq.t
(** [iterate f x] is [x; f x; f (f x); ...] — infinite. *)

val repeat : ?n:int -> 'a -> 'a Stdlib.Seq.t
(** [repeat x] repeats [x] forever; [repeat ~n x] repeats [n] times. *)

val repeatedly : ?n:int -> (unit -> 'a) -> 'a Stdlib.Seq.t
(** [repeatedly f] calls [f] each step — infinite unless [~n] bounds it. *)

val cycle : 'a coll -> 'a Stdlib.Seq.t
(** [cycle c] loops [c] forever — infinite, empty on empty; the first pass
    is realized and replayed. *)

val range : ?start:int -> ?step:int -> int -> int Stdlib.Seq.t
(** [range ?start ?step stop] counts toward [stop] (exclusive), default
    [start=0], [step=1]. *)

val lazy_seq : (unit -> 'a Stdlib.Seq.t) -> 'a Stdlib.Seq.t
(** [lazy_seq f] defers [f] until the result is consumed — Clojure's
    [lazy-seq]. *)

(** {1 Combinators} *)

val identity : 'a -> 'a
(** [identity x] is [x] — Clojure's [identity]. *)

val constantly : 'a -> 'b -> 'a
(** [constantly x] is a function ignoring its argument — Clojure's
    [constantly]. *)

val comp : ('b -> 'c) -> ('a -> 'b) -> 'a -> 'c
(** [comp f g] is [fun x -> f (g x)] — Clojure's [comp]. *)

val comp3 : ('c -> 'd) -> ('b -> 'c) -> ('a -> 'b) -> 'a -> 'd
(** [comp3 f g h] is [fun x -> f (g (h x))]. *)

val complement : ('a -> bool) -> 'a -> bool
(** [complement p] is [fun x -> not (p x)] — Clojure's [complement]. *)

val fnil : ('a -> 'b) -> 'b -> 'a option -> 'b
(** [fnil f default] lifts [f] to take [None] as [default] — Clojure's
    [fnil]. *)

val juxt : ('a -> 'b) -> ('a -> 'c) -> 'a -> 'b * 'c
(** [juxt f g] is [fun x -> (f x, g x)] — Clojure's [juxt]. *)

val juxt3 : ('a -> 'b) -> ('a -> 'c) -> ('a -> 'd) -> 'a -> 'b * 'c * 'd
(** Three-way {!juxt}. *)

val memoize : ('a -> 'b) -> 'a -> 'b
(** [memoize f] caches [f] results by structural equality — Clojure's
    [memoize]. *)

val if_ : bool -> (unit -> 'a) -> (unit -> 'a) -> 'a
(** [if_ c then_ else_] calls the chosen thunk — lazy if/then/else. *)

val when_ : bool -> (unit -> unit) -> unit
(** [when_ c f] calls [f ()] when [c] is true. *)

val when_some : 'a option -> ('a -> unit) -> unit
(** [when_some opt f] calls [f x] when [opt] is [Some x] — Clojure's
    [when-some]. *)

val cond : (bool * (unit -> 'a)) list -> 'a option
(** [cond clauses] evaluates the thunk of the first true clause — [None]
    when none match (Clojure returns nil). *)

val or_else : 'a option -> 'a -> 'a
(** [or_else opt default] — Clojure's [(or x default)]. *)

val nil_ : 'a option -> bool
(** [nil_ opt] is [true] on [None] — Clojure's [nil?]. *)

val some_ : 'a option -> bool
(** [some_ opt] is [true] on [Some _] — Clojure's [some?]. *)

val is_none : 'a option -> bool
(** Alias for {!nil_}. *)

(** {1 Numbers} *)

val inc : int -> int
(** [inc x] is [x + 1] — Clojure's [inc]. *)

val dec : int -> int
(** [dec x] is [x - 1] — Clojure's [dec]. *)

val zero_ : int -> bool
(** [zero_ x] — Clojure's [zero?]. *)

val pos_ : int -> bool
(** [pos_ x] — Clojure's [pos?]. *)

val neg_ : int -> bool
(** [neg_ x] — Clojure's [neg?]. *)

val even_ : int -> bool
(** [even_ x] — Clojure's [even?]. *)

val odd_ : int -> bool
(** [odd_ x] — Clojure's [odd?]. *)

val abs : int -> int
(** [abs x] — Clojure's [abs]. *)

val quot : int -> int -> int
(** [quot a b] truncating quotient — Clojure's [quot]. *)

val rem : int -> int -> int
(** [rem a b] truncating remainder; sign follows the dividend — Clojure's
    [rem]. *)

val mod_ : int -> int -> int
(** [mod_] is floored modulo — sign follows the divisor, like Clojure's
    [mod] (unlike {!rem}, which follows the dividend). *)

val rand : ?rng:Stdlib.Random.State.t -> unit -> float
(** [rand ?rng ()] is a uniform float in [\[0., 1.)] — Clojure's [rand]. *)

val rand_int : ?rng:Stdlib.Random.State.t -> int -> int
(** [rand_int ?rng n] is uniform in [\[0, n)] — Clojure's [rand-int]. *)

val rand_nth : ?rng:Stdlib.Random.State.t -> 'a coll -> 'a
(** [rand_nth ?rng c] picks a random element; raises on empty — Clojure's
    [rand-nth]. *)

val min2 : int -> int -> int
(** [min2 a b] is the smaller — Clojure's [(min a b)]. *)

val max2 : int -> int -> int
(** [max2 a b] is the larger — Clojure's [(max a b)]. *)

val sum : int coll -> int
(** [sum c] is [reduce (+) 0 c]. *)

val product : int coll -> int
(** [product c] is [reduce ( * ) 1 c]. *)

val sumf : float coll -> float
(** [sumf c] is [reduce (+.) 0. c]. *)

(** {1 Strings and printing} *)

val str : string coll -> string
(** [str (`Lst ["a"; "b"])] concatenates — strings only (OCaml has no
    universal [toString]); use {!Str.str} on string seqs. *)

val print : string -> unit
(** [print s] writes [s] to stdout — Clojure's [print]. *)

val println : string -> unit
(** [println s] writes [s] plus a newline — Clojure's [println]. *)

val prn : string -> unit
(** Alias for {!println} — Clojure's [prn] for strings. *)

(** {1 Reference types} *)

type 'a derefable =
  [ `Atom of 'a Atom.t
  | `Delay of 'a Delay.t
  | `Volatile of 'a Volatile.t
  | `Ref of 'a ref ]
(** Anything dereferenceable — the shared shape behind Clojure's [@x]. *)

val deref : 'a derefable -> 'a
(** [deref x] reads the current value — Clojure's [@x]; forces delays. *)

val atom : 'a -> 'a Atom.t
(** [atom v] creates an atom — Clojure's [atom]. *)

val delay : (unit -> 'a) -> 'a Delay.t
(** [delay f] defers [f] until forced — Clojure's [delay]. *)

val realized_ : 'a Delay.t -> bool
(** [realized_ d] is [true] when [d] has been forced — Clojure's
    [realized?]. *)

(** {1 Errors} *)

exception Ex_info of string * (string, string) Map.t
(** The exception produced by {!ex_info}, carrying a message and a data
    map — Clojure's [ex-info]. *)

val ex_info : string -> (string, string) Map.t -> exn
(** [ex_info msg data] builds an {!Ex_info} exception — Clojure's
    [ex-info]. *)

val ex_data : exn -> (string, string) Map.t option
(** [ex_data e] is the data map of an {!Ex_info} — Clojure's [ex-data]. *)

val ex_message : exn -> string
(** [ex_message e] is the message — Clojure's [ex-message]. *)
