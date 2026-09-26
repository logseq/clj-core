(** Persistent maps — Clojure's map API on a sorted, structure-sharing
    [(key, value) Vec.t].

    Iteration order is ascending by the stored comparator (Clojure
    [sorted-map] semantics); lookups are O(log32 n) binary search, [assoc] and
    [dissoc] are O(log32 n) with structural sharing. The default comparator is
    [Stdlib.compare] — keys must not contain functions or [nan]. *)

type 'k comparator = 'k -> 'k -> int

type ('k, 'v) t
(** A persistent map sorted by [cmp] on keys, with unique keys. *)

(** {1 Construction} *)

val empty : ?cmp:'k comparator -> unit -> ('k, 'v) t
val singleton : ?cmp:'k comparator -> 'k -> 'v -> ('k, 'v) t
val of_list : ?cmp:'k comparator -> ('k * 'v) list -> ('k, 'v) t
(** Later entries overwrite earlier ones, like repeated [assoc]. *)

val of_array : ?cmp:'k comparator -> ('k * 'v) array -> ('k, 'v) t
val of_seq : ?cmp:'k comparator -> ('k * 'v) Stdlib.Seq.t -> ('k, 'v) t
val sorted_map : ?cmp:'k comparator -> ('k * 'v) list -> ('k, 'v) t
val hash_map : ?cmp:'k comparator -> ('k * 'v) list -> ('k, 'v) t
val array_map : ?cmp:'k comparator -> ('k * 'v) list -> ('k, 'v) t
(** [sorted_map]/[hash_map]/[array_map] are constructors for [of_list] matching
    the Clojure names. Iteration is always sorted. *)

val zipmap : ?cmp:'k comparator -> 'k list -> 'v list -> ('k, 'v) t
(** [zipmap ks vs] pairs keys with values positionally, stopping at the
    shorter input. *)

val cmp : ('k, 'v) t -> 'k comparator
(** The comparator a map was built with. *)

(** {1 Predicates and size} *)

val count : ('k, 'v) t -> int
val empty_ : ('k, 'v) t -> bool
val is_empty : ('k, 'v) t -> bool
val contains_ : ('k, 'v) t -> 'k -> bool
(** [contains_ m k] — Clojure's [(contains? m k)]. *)

(** {1 Access} *)

val get : ('k, 'v) t -> 'k -> 'v option
val get_or : 'v -> ('k, 'v) t -> 'k -> 'v
(** [get_or default m k] — Clojure's [(get m k default)]. *)

val find : ('k, 'v) t -> 'k -> ('k * 'v) option
(** [find m k] is the [(k, v)] entry — Clojure's [find]. *)

val min_entry : ('k, 'v) t -> ('k * 'v) option
val max_entry : ('k, 'v) t -> ('k * 'v) option
val min_key : ('k, 'v) t -> 'k option
val max_key : ('k, 'v) t -> 'k option
val keys : ('k, 'v) t -> 'k Stdlib.Seq.t
val vals : ('k, 'v) t -> 'v Stdlib.Seq.t
val entries : ('k, 'v) t -> ('k * 'v) list

(** {1 Update (persistent)} *)

val conj : ('k, 'v) t -> 'k * 'v -> ('k, 'v) t
val assoc : ('k, 'v) t -> 'k -> 'v -> ('k, 'v) t
val dissoc : ('k, 'v) t -> 'k -> ('k, 'v) t
val update : ('k, 'v) t -> 'k -> ('v option -> 'v) -> ('k, 'v) t
(** [update m k f] stores [f (get m k)] under [k]. The [option] argument
    replaces Clojure's nil. *)

val update_opt : ('k, 'v) t -> 'k -> ('v option -> 'v option) -> ('k, 'v) t
(** [update_opt m k f] dissocs [k] when [f] returns [None]. *)

val update_vals : ('k, 'v) t -> ('v -> 'v2) -> ('k, 'v2) t
(** Clojure 1.11's [update-vals]: maps every value, keys unchanged. *)

val update_keys :
  ?cmp:'k2 comparator ->
  ('k, 'v) t ->
  ('k -> 'k2) ->
  ('k2, 'v) t
(** Clojure 1.11's [update-keys]: maps every key; later duplicates win. *)

val map : ('v -> 'v2) -> ('k, 'v) t -> ('k, 'v2) t
val map_kv : ('k -> 'v -> 'v2) -> ('k, 'v) t -> ('k, 'v2) t
val filter : ('k -> 'v -> bool) -> ('k, 'v) t -> ('k, 'v) t
val remove : ('k -> 'v -> bool) -> ('k, 'v) t -> ('k, 'v) t
val select_keys : ('k, 'v) t -> 'k list -> ('k, 'v) t
val merge : ('k, 'v) t -> ('k, 'v) t -> ('k, 'v) t
(** [merge a b] is [a] with all of [b]'s bindings; [b] wins on conflicts.
    The result uses [a]'s comparator. *)

val merge_with :
  ('v -> 'v -> 'v) -> ('k, 'v) t -> ('k, 'v) t -> ('k, 'v) t
(** [merge_with f a b] combines conflicting values with [f a_v b_v]. *)

val into : ('k, 'v) t -> ('k * 'v) Stdlib.Seq.t -> ('k, 'v) t

(** {1 Iteration} *)

val iter : ('k -> 'v -> unit) -> ('k, 'v) t -> unit
val fold : ('acc -> 'k -> 'v -> 'acc) -> 'acc -> ('k, 'v) t -> 'acc
val fold_kv : ('acc -> 'k -> 'v -> 'acc) -> 'acc -> ('k, 'v) t -> 'acc
val reduce_kv : ('acc -> 'k -> 'v -> 'acc) -> 'acc -> ('k, 'v) t -> 'acc
val every_ : ('k -> 'v -> bool) -> ('k, 'v) t -> bool
val some : ('k -> 'v -> bool) -> ('k, 'v) t -> ('k * 'v) option
val find_map : ('k -> 'v -> 'r option) -> ('k, 'v) t -> 'r option
val count_matching : ('k -> 'v -> bool) -> ('k, 'v) t -> int

(** {1 Slices (comparator-ordered)} *)

val slice : ?from_:'k -> ?to_:'k -> ('k, 'v) t -> ('k, 'v) t
(** [slice ?from_ ?to_ m] keeps entries with [from_ <= k < to_]. *)

val slice_seq : ?from_:'k -> ?to_:'k -> ('k, 'v) t -> ('k * 'v) Stdlib.Seq.t

(** {1 Conversions} *)

val seq : ('k, 'v) t -> ('k * 'v) Stdlib.Seq.t
val to_seq : ('k, 'v) t -> ('k * 'v) Stdlib.Seq.t
val rseq : ('k, 'v) t -> ('k * 'v) Stdlib.Seq.t
(** Descending order. *)

val to_list : ('k, 'v) t -> ('k * 'v) list
val to_vec : ('k, 'v) t -> ('k * 'v) Vec.t

(** {1 Equality and comparison} *)

val equal : ?eq:('v -> 'v -> bool) -> ('k, 'v) t -> ('k, 'v) t -> bool
(** Maps are equal when they contain the same keys bound to equal values;
    comparators need not match. *)
