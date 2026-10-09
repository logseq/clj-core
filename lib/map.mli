(** Persistent maps — Clojure's map API on a sorted, structure-sharing
    [(key, value) Vec.t].

    Iteration order is ascending by the stored comparator (Clojure
    [sorted-map] semantics); lookups are O(log32 n) binary search, [assoc] and
    [dissoc] are O(log32 n) with structural sharing. The default comparator is
    [Stdlib.compare] — keys must not contain functions or [nan]. *)

type 'k comparator = 'k -> 'k -> int
(** A key ordering: negative, zero, or positive like [Stdlib.compare]. *)

type ('k, 'v) t
(** A persistent map sorted by [cmp] on keys, with unique keys. *)

(** {1 Construction} *)

val empty : ?cmp:'k comparator -> unit -> ('k, 'v) t
(** [empty ?cmp ()] is an empty map ordered by [cmp] (default
    [Stdlib.compare]). *)

val singleton : ?cmp:'k comparator -> 'k -> 'v -> ('k, 'v) t
(** [singleton ?cmp k v] is a map with one binding. *)

val of_list : ?cmp:'k comparator -> ('k * 'v) list -> ('k, 'v) t
(** Later entries overwrite earlier ones, like repeated [assoc]. *)

val of_array : ?cmp:'k comparator -> ('k * 'v) array -> ('k, 'v) t
(** Like {!of_list} from an array. *)

val of_seq : ?cmp:'k comparator -> ('k * 'v) Stdlib.Seq.t -> ('k, 'v) t
(** Like {!of_list} from a sequence. *)

val sorted_map : ?cmp:'k comparator -> ('k * 'v) list -> ('k, 'v) t
val sorted_map_by : 'k comparator -> ('k * 'v) list -> ('k, 'v) t
(** [sorted_map_by cmp pairs] is [of_list ~cmp] — Clojure's [sorted-map-by]. *)

val hash_map : ?cmp:'k comparator -> ('k * 'v) list -> ('k, 'v) t
val array_map : ?cmp:'k comparator -> ('k * 'v) list -> ('k, 'v) t
(** [sorted_map]/[hash_map]/[array_map] are constructors for [of_list] matching
    the Clojure names. Iteration is always sorted. *)

val key : 'k * 'v -> 'k
(** [key (k, v)] is [fst] — Clojure's [(key entry)]. *)

val value : 'k * 'v -> 'v
(** [value (k, v)] is [snd] — Clojure's [(val entry)]. *)

val zipmap : ?cmp:'k comparator -> 'k list -> 'v list -> ('k, 'v) t
(** [zipmap ks vs] pairs keys with values positionally, stopping at the
    shorter input. *)

val cmp : ('k, 'v) t -> 'k comparator
(** The comparator a map was built with. *)

(** {1 Predicates and size} *)

val count : ('k, 'v) t @ local -> int
(** [count m] is the number of bindings — Clojure's [(count m)]. *)

val empty_ : ('k, 'v) t @ local -> bool
(** [empty_ m] is [true] when [m] has no bindings — Clojure's [(empty? m)]. *)

val is_empty : ('k, 'v) t @ local -> bool
(** Alias for {!empty_}. *)
val contains_ : ('k, 'v) t -> 'k -> bool
(** [contains_ m k] — Clojure's [(contains? m k)]. *)

(** {1 Access} *)

val get : ('k, 'v) t -> 'k -> 'v option
(** [get m k] is [Some v] when [k] is bound, else [None] — Clojure's
    [(get m k)]. *)
val get_or : 'v -> ('k, 'v) t -> 'k -> 'v
(** [get_or default m k] — Clojure's [(get m k default)]. *)

val find : ('k, 'v) t -> 'k -> ('k * 'v) option
(** [find m k] is the [(k, v)] entry — Clojure's [find]. *)

val min_entry : ('k, 'v) t -> ('k * 'v) option
(** [min_entry m] is the entry with the smallest key, [None] on empty. *)

val max_entry : ('k, 'v) t -> ('k * 'v) option
(** [max_entry m] is the entry with the largest key, [None] on empty. *)

val min_key : ('k, 'v) t -> 'k option
(** [min_key m] is [fst] of {!min_entry}. *)

val max_key : ('k, 'v) t -> 'k option
(** [max_key m] is [fst] of {!max_entry}. *)

val keys : ('k, 'v) t -> 'k Stdlib.Seq.t
(** [keys m] iterates keys in ascending order — Clojure's [(keys m)]. *)

val vals : ('k, 'v) t -> 'v Stdlib.Seq.t
(** [vals m] iterates values in key order — Clojure's [(vals m)]. *)

val entries : ('k, 'v) t -> ('k * 'v) list
(** [entries m] is the sorted entry list. *)

(** {1 Update (persistent)} *)

val conj : ('k, 'v) t -> 'k * 'v -> ('k, 'v) t
(** [conj m (k, v)] is {!assoc} — Clojure's [(conj m [k v])]. *)

val assoc : ('k, 'v) t -> 'k -> 'v -> ('k, 'v) t
(** [assoc m k v] binds [k] to [v], replacing any existing binding —
    Clojure's [(assoc m k v)]. *)

val dissoc : ('k, 'v) t -> 'k -> ('k, 'v) t
(** [dissoc m k] removes [k]; a missing key returns [m] — Clojure's
    [(dissoc m k)]. *)
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
(** Alias for {!update_vals}. *)

val map_kv : ('k -> 'v -> 'v2) -> ('k, 'v) t -> ('k, 'v2) t
(** [map_kv f m] maps [f k v] over every value, keys unchanged. *)

val filter : ('k -> 'v -> bool) -> ('k, 'v) t -> ('k, 'v) t
(** [filter f m] keeps entries where [f k v] holds. *)

val remove : ('k -> 'v -> bool) -> ('k, 'v) t -> ('k, 'v) t
(** [remove f m] drops entries where [f k v] holds — Clojure's [remove]. *)

val select_keys : ('k, 'v) t -> 'k list -> ('k, 'v) t
(** [select_keys m ks] keeps the entries whose keys occur in [ks] — Clojure's
    [select-keys]. *)

val merge : ('k, 'v) t -> ('k, 'v) t -> ('k, 'v) t
(** [merge a b] is [a] with all of [b]'s bindings; [b] wins on conflicts.
    The result uses [a]'s comparator. *)

val merge_with :
  ('v -> 'v -> 'v) -> ('k, 'v) t -> ('k, 'v) t -> ('k, 'v) t
(** [merge_with f a b] combines conflicting values with [f a_v b_v]. *)

val into : ('k, 'v) t -> ('k * 'v) Stdlib.Seq.t -> ('k, 'v) t
(** [into m entries] conjs each [(k, v)] onto [m]. *)

(** {1 Iteration} *)

val iter : ('k -> 'v -> unit) -> ('k, 'v) t -> unit
val iter_local : ('k @ local -> 'v @ local -> unit) @ local -> ('k, 'v) t @ local -> unit
(** [iter f m] applies [f k v] to each entry in key order. *)

val fold : ('acc -> 'k -> 'v -> 'acc) -> 'acc -> ('k, 'v) t -> 'acc
val fold_local : ('acc -> 'k @ local -> 'v @ local -> 'acc) @ local -> 'acc -> ('k, 'v) t @ local -> 'acc
(** Left fold [f acc k v] over entries in key order. *)

val fold_kv : ('acc -> 'k -> 'v -> 'acc) -> 'acc -> ('k, 'v) t -> 'acc
val fold_kv_local : ('acc -> 'k @ local -> 'v @ local -> 'acc) @ local -> 'acc -> ('k, 'v) t @ local -> 'acc
(** Alias for {!fold}. *)

val reduce_kv : ('acc -> 'k -> 'v -> 'acc) -> 'acc -> ('k, 'v) t -> 'acc
val reduce_kv_local : ('acc -> 'k @ local -> 'v @ local -> 'acc) @ local -> 'acc -> ('k, 'v) t @ local -> 'acc
(** Alias for {!fold} — Clojure's [reduce-kv]. *)

val every_ : ('k -> 'v -> bool) -> ('k, 'v) t -> bool
val every_local : ('k @ local -> 'v @ local -> bool) @ local -> ('k, 'v) t @ local -> bool
(** [every_ f m] is [true] when [f k v] holds for every entry — Clojure's
    [every?]. *)

val some : ('k -> 'v -> bool) -> ('k, 'v) t -> ('k * 'v) option
(** [some f m] is the first entry where [f k v] holds. *)

val find_map : ('k -> 'v -> 'r option) -> ('k, 'v) t -> 'r option
val find_map_local : ('k @ local -> 'v @ local -> 'r option) @ local -> ('k, 'v) t @ local -> 'r option
(** [find_map f m] is the first [Some _] produced by [f k v]. *)

val count_matching : ('k -> 'v -> bool) -> ('k, 'v) t -> int
val count_matching_local : ('k @ local -> 'v @ local -> bool) @ local -> ('k, 'v) t @ local -> int
(** [count_matching f m] counts entries where [f k v] holds. *)

(** {1 Slices (comparator-ordered)} *)

val slice : ?from_:'k -> ?to_:'k -> ('k, 'v) t -> ('k, 'v) t
(** [slice ?from_ ?to_ m] keeps entries with [from_ <= k < to_]. *)

val slice_seq : ?from_:'k -> ?to_:'k -> ('k, 'v) t -> ('k * 'v) Stdlib.Seq.t
(** Like {!slice} but returns a sequence. *)

val subseq : ?from_:'k -> ?to_:'k -> ('k, 'v) t -> ('k * 'v) Stdlib.Seq.t
(** Alias for {!slice_seq} — Clojure's [subseq] range view. *)

val rsubseq : ?from_:'k -> ?to_:'k -> ('k, 'v) t -> ('k * 'v) Stdlib.Seq.t
(** Like {!subseq} but iterating descending — Clojure's [rsubseq]. *)

(** {1 Conversions} *)

val seq : ('k, 'v) t -> ('k * 'v) Stdlib.Seq.t
(** [seq m] iterates [(k, v)] entries in ascending key order. *)

val to_seq : ('k, 'v) t -> ('k * 'v) Stdlib.Seq.t
(** Alias for {!seq}. *)
val rseq : ('k, 'v) t -> ('k * 'v) Stdlib.Seq.t
(** Descending order. *)

val to_list : ('k, 'v) t -> ('k * 'v) list

val to_list_local : ('k, 'v) t @ local -> ('k * 'v) list @ local
(** [to_list_local] borrows [m]; the result pairs share [m]'s region. *)
(** [to_list m] is the sorted entry list — same as {!entries}. *)

val to_vec : ('k, 'v) t -> ('k * 'v) Vec.t
(** [to_vec m] is the sorted entries as a vector — structural sharing with
    the map's storage. *)

(** {1 Nested maps} *)

type ('k, 'v) nest = Leaf of 'v | Nest of ('k, ('k, 'v) nest) t
(** A nested-map tree: each map level's values are either a [Leaf] leaf value
    or a [Nest] deeper map. This is the OCaml encoding of Clojure's
    dynamically-typed nested maps for [get-in]/[assoc-in]/[update-in]. *)

val get_in : ('k, ('k, 'v) nest) t -> 'k list -> ('k, 'v) nest option
(** [get_in m ks] walks nested [Nest] values along the key path — Clojure's
    [get-in]. [get_in m []] is [Some (Nest m)]. A [Leaf] at a non-terminal
    position yields [None]. *)

val assoc_in : ('k, ('k, 'v) nest) t -> 'k list -> ('k, 'v) nest -> ('k, ('k, 'v) nest) t
(** [assoc_in m ks v] sets the value at the key path, creating intermediate
    maps — Clojure's [assoc-in]. A non-map value on the path is replaced.
    Raises [Invalid_argument] on an empty path (Clojure assoc's [nil] there —
    not reproducible with typed keys). *)

val update_in :
  ('k, ('k, 'v) nest) t ->
  'k list ->
  (('k, 'v) nest option -> ('k, 'v) nest) ->
  ('k, ('k, 'v) nest) t
(** [update_in m ks f] applies [f] to the value at the key path ([None] when
    absent), creating intermediate maps — Clojure's [update-in]. Raises
    [Invalid_argument] on an empty path. *)

(** {1 Equality and comparison} *)

val equal : ?eq:('v -> 'v -> bool) -> ('k, 'v) t -> ('k, 'v) t -> bool
(** Maps are equal when they contain the same keys bound to equal values;
    comparators need not match. *)

(* borrow variants *)

