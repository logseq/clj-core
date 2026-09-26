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

val sequence : 'a coll -> 'a Stdlib.Seq.t
(** Alias for {!to_seq} — Clojure's [sequence] (coll->seq arity only). *)

val count : 'a coll -> int
(** [count c] is the element count — Clojure's [(count c)]. *)

val bounded_count : int -> 'a coll -> int
(** [bounded_count n c] counts at most [n] elements — terminates on infinite
    seqs. Clojure's [bounded-count]. *)

val empty_ : 'a coll -> bool
(** [empty_ c] is [true] when [c] has no elements — Clojure's [empty?]. *)

val is_empty : 'a coll -> bool
(** Alias for {!empty_}. *)

val not_empty : 'a coll -> 'a coll option
(** [not_empty c] is [Some c] or [None] on empty — Clojure's [not-empty]. *)

val counted_ : 'a coll -> bool
(** [counted_ c] is [true] when [c] knows its size without traversal —
    everything except [`Seq]. Clojure's [counted?]. *)

val indexed_ : 'a coll -> bool
(** [indexed_ c] is [true] for [`Vec] and [`Arr] — Clojure's [indexed?]. *)

val reversible_ : 'a coll -> bool
(** [reversible_ c] is [true] when [c] supports reverse traversal —
    Clojure's [reversible?]. *)

val sorted_ : 'a coll -> bool
(** [sorted_ c] is [true] for [`Set] — Clojure's [sorted?]. *)

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

val fnext : 'a coll -> 'a option
(** [fnext c] is [first] of {!next} — Clojure's [fnext] (same as
    {!second}). *)

val nfirst : 'a Stdlib.Seq.t coll -> 'a Stdlib.Seq.t option
(** [nfirst c] is [next] of the first element — Clojure's [nfirst] on a
    coll of seqs. *)

val nnext : 'a coll -> 'a Stdlib.Seq.t option
(** [nnext c] is [next] of {!next} — Clojure's [nnext]. *)

val nth_next : 'a coll -> int -> 'a Stdlib.Seq.t option
(** [nth_next c n] is [next] of the nth [rest] — Clojure's [nthnext]. *)

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

val distinct_ : 'a coll -> bool
(** [distinct_ c] is [true] when all elements are distinct — Clojure's
    [distinct?]; realizes [c]. *)

val some_vals : 'a option coll -> 'a Stdlib.Seq.t
(** [some_vals c] keeps the [Some] values — Clojure's [some-vals] — lazy. *)

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

val run_ : ('a -> 'b) -> 'a coll -> unit
(** [run_ f c] applies [f] per element and discards the results — Clojure's
    [run!]. *)

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

val random_sample :
  ?prob:float -> ?rng:Stdlib.Random.State.t -> 'a coll -> 'a Stdlib.Seq.t
(** [random_sample ?prob ?rng c] keeps each element with probability [prob]
    (default [1.0]) — lazy, Clojure's [random-sample]. *)

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

val replicate : int -> 'a -> 'a Stdlib.Seq.t
(** [replicate n x] is [repeat ~n x] — Clojure's [replicate]. *)

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

val partial : ('a -> 'b -> 'c) -> 'a -> 'b -> 'c
(** [partial f a] is [f a] — partial application is native in OCaml; this
    spelling mirrors Clojure's [(partial f a)]. [partial2]/[partial3]
    capture two and three arguments. *)

val partial2 : ('a -> 'b -> 'c -> 'd) -> 'a -> 'b -> 'c -> 'd
val partial3 : ('a -> 'b -> 'c -> 'd -> 'e) -> 'a -> 'b -> 'c -> 'd -> 'e

val every_pred : ('a -> bool) -> 'a -> bool
val every_pred2 : ('a -> bool) -> ('a -> bool) -> 'a -> bool
val every_pred3 : ('a -> bool) -> ('a -> bool) -> ('a -> bool) -> 'a -> bool
(** [every_pred p] / [every_pred2 p q] / [every_pred3 p q r] return a
    predicate that is [true] when all components hold — Clojure's
    [every-pred]. *)

val some_fn : ('a -> 'b option) -> 'a -> 'b option
val some_fn2 : ('a -> 'b option) -> ('a -> 'b option) -> 'a -> 'b option
val some_fn3 :
  ('a -> 'b option) -> ('a -> 'b option) -> ('a -> 'b option) -> 'a -> 'b option
(** [some_fn f] / [some_fn2 f g] / [some_fn3 f g h] return a function that
    yields the first [Some _] produced — Clojure's [some-fn] specialized to
    [option]-returning functions. *)

type 'a bounce = Done of 'a | More of (unit -> 'a bounce)
(** Trampoline step: a finished [Done] or a [More] thunk producing the next
    step. *)

val trampoline : 'a bounce -> 'a
(** [trampoline b] runs a bounce chain without growing the stack —
    Clojure's [trampoline]. Mutually recursive functions return [More
    (fun () -> ...)] instead of calling each other. *)

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

val cond_ : 'x -> (('x -> bool) * ('x -> 'a)) list -> 'a option
(** [cond_ x clauses] applies [f x] of the first clause whose predicate
    [p x] holds — a function-form [cond->]. *)

val if_not : bool -> (unit -> 'a) -> (unit -> 'a) -> 'a
(** [if_not c then_ else_] is {!if_} with the branches swapped — Clojure's
    [if-not]. *)

val when_not : bool -> (unit -> unit) -> unit
(** [when_not c f] calls [f ()] when [c] is false — Clojure's [when-not]. *)

val if_none : 'a option -> (unit -> 'b) -> ('a -> 'b) -> 'b
(** [if_none opt then_ else_] dispatches on [None] vs [Some x] — the
    function form of Clojure's [if-let]. *)

val when_not_nil : 'a option -> ('a -> unit) -> unit
(** [when_not_nil opt f] calls [f x] on [Some x] — Clojure's
    [when-not-nil]. *)

val while_ : (unit -> bool) -> (unit -> unit) -> unit
(** [while_ p f] runs [f ()] while [p ()] holds — Clojure's [while]. *)

val condp : ('e -> 'x -> bool) -> 'x -> ('e * ('x -> 'a)) list -> 'a option
(** [condp p x clauses] applies [f x] of the first clause whose test
    expression [e] satisfies [p e x] — Clojure's [condp] as a function. *)

val or_else : 'a option -> 'a -> 'a
(** [or_else opt default] — Clojure's [(or x default)]. *)

val nil_ : 'a option -> bool
(** [nil_ opt] is [true] on [None] — Clojure's [nil?]. *)

val some_ : 'a option -> bool
(** [some_ opt] is [true] on [Some _] — Clojure's [some?]. *)

val time : (unit -> 'a) -> 'a
(** [time f] runs [f], prints ["Elapsed time: ... msecs"], and returns the
    result — Clojure's [time]. *)

val is_none : 'a option -> bool
(** Alias for {!nil_}. *)

(** {1 Comparison and logic} *)

val eq : 'a -> 'a -> bool
(** [eq a b] is structural equality — Clojure's [=]. *)

val equal : 'a -> 'a -> bool
(** Alias for {!eq}. *)

val not_eq : 'a -> 'a -> bool
(** [not_eq a b] is [not (eq a b)] — Clojure's [not=]. *)

val identical_ : 'a -> 'a -> bool
(** [identical_ a b] is physical equality — Clojure's [identical?]. *)

val lt : 'a -> 'a -> bool
val le : 'a -> 'a -> bool
val gt : 'a -> 'a -> bool
val ge : 'a -> 'a -> bool
(** [lt]/[le]/[gt]/[ge] are [(<)]/[(<=)]/[(>)]/[(>=)] — Clojure's two-arg
    [<], [<=], [>], [>=]. *)

val compare : 'a -> 'a -> int
(** [compare a b] is [Stdlib.compare] — Clojure's [compare]. *)

val not : bool -> bool
(** [not b] — Clojure's [not]. *)

val true_ : bool -> bool
(** [true_ x] is [x = true] — Clojure's [true?]. *)

val false_ : bool -> bool
(** [false_ x] is [x = false] — Clojure's [false?]. *)

val or_ : bool -> bool -> bool
val and_ : bool -> bool -> bool
(** [or_ a b] / [and_ a b] are [(||)]/[(&&)] as functions — both sides are
    already evaluated (no short-circuit). *)

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

val add : int -> int -> int
val sub : int -> int -> int
val mul : int -> int -> int
val div : int -> int -> int
(** [add]/[sub]/[mul]/[div] are the int operators — Clojure's two-arg
    [+], [-], [*], [/]. *)

val min : 'a -> 'a -> 'a
val max : 'a -> 'a -> 'a
(** [min]/[max] are [Stdlib.min]/[Stdlib.max] — Clojure's two-arg
    [min]/[max]. *)

val pos_int_ : int -> bool
val neg_int_ : int -> bool
val nat_int_ : int -> bool
(** [pos_int_]/[neg_int_]/[nat_int_] test int sign — Clojure's [pos-int?],
    [neg-int?], [nat-int?]. *)

val nan_ : float -> bool
(** [nan_ x] is [true] when [x] is NaN — Clojure's [NaN?]. *)

val infinite_ : float -> bool
(** [infinite_ x] is [true] when [x] is infinite — Clojure's [infinite?]. *)

val unchecked_add : int -> int -> int
val unchecked_subtract : int -> int -> int
val unchecked_multiply : int -> int -> int
val unchecked_inc : int -> int
val unchecked_dec : int -> int
val unchecked_negate : int -> int
(** The [unchecked-*] family — in OCaml integer arithmetic never checks for
    overflow, so these are aliases of the checked variants. *)

(** {1 Bitwise} *)

val bit_not : int -> int
val bit_and : int -> int -> int
val bit_or : int -> int -> int
val bit_xor : int -> int -> int
val bit_and_not : int -> int -> int
(** The [bit-*] family on ints — Clojure's [bit-not], [bit-and], [bit-or],
    [bit-xor], [bit-and-not]. *)

val bit_shift_left : int -> int -> int
val bit_shift_right : int -> int -> int
val unsigned_bit_shift_right : int -> int -> int
(** Clojure's [bit-shift-left], [bit-shift-right] (arithmetic) and
    [unsigned-bit-shift-right] (logical). *)

val bit_set : int -> int -> int
val bit_clear : int -> int -> int
val bit_flip : int -> int -> int
val bit_test : int -> int -> bool
(** [bit_set x i]/[bit_clear]/[bit_flip]/[bit_test] act on bit [i] —
    Clojure's [bit-set], [bit-clear], [bit-flip], [bit-test]. *)

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

(** {1 Random and parsing} *)

val random_uuid : ?rng:Stdlib.Random.State.t -> unit -> string
(** [random_uuid ?rng ()] is a random type-4 UUID string — Clojure's
    [random-uuid]. *)

val uuid_ : string -> bool
(** [uuid_ s] is [true] when [s] parses as a UUID ([8-4-4-4-12] hex) —
    Clojure's [uuid?] applied to strings. *)

val parse_boolean : string -> bool option
val parse_int : string -> int option
val parse_float : string -> float option
(** Clojure's [parse-boolean], [parse-long] (as int), [parse-double] (as
    float); [None] on invalid input. *)

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

val format : ('a, unit, string) format -> 'a
(** [format fmt ...] is [Printf.sprintf] — Clojure's [format]. *)

val printf : ('a, out_channel, unit) format -> 'a
(** [printf fmt ...] is [Printf.printf] — Clojure's [printf]. *)

val newline : unit -> unit
(** [newline ()] writes a newline — Clojure's [newline]. *)

val flush : unit -> unit
(** [flush ()] flushes stdout — Clojure's [flush]. *)

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
