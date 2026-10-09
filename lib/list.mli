(** Persistent lists — Clojure's list API over OCaml's ['a list].

    [conj]/[cons] prepend (O(1)); [first]/[rest] match Clojure semantics. Seq
    operations put the list last so they chain under [|>]. *)

(** {1 Construction and conversions} *)

val empty : 'a list
(** The empty list. *)

val list : 'a list -> 'a list
(** [list xs] is the identity — Clojure's [(list ...)]. *)

val of_seq : 'a Stdlib.Seq.t -> 'a list
(** [of_seq s] realizes the sequence into a list, in order. *)

val of_array : 'a array -> 'a list
(** [of_array a] converts an array to a list. *)

val of_vec : 'a Vec.t -> 'a list
(** [of_vec v] converts a vector to a list. *)

val to_seq : 'a list -> 'a Stdlib.Seq.t
(** [to_seq l] views [l] as a sequence. *)

val seq : 'a list -> 'a Stdlib.Seq.t
(** Alias for {!to_seq}. *)

val to_vec : 'a list -> 'a Vec.t
(** [to_vec l] builds a vector from [l]. *)

val to_array : 'a list -> 'a array
(** [to_array l] builds an array from [l]. *)

(** {1 Predicates and size} *)

val count : 'a list -> int
(** [count l] is the length — Clojure's [(count l)]. O(n). *)

val length : 'a list -> int
(** Alias for {!count}. *)

val empty_ : 'a list -> bool
(** [empty_ l] is [l = []] — Clojure's [(empty? l)]. *)

val is_empty : 'a list -> bool
(** Alias for {!empty_}. *)

val mem : 'a @ local -> 'a list @ local -> bool
(** [mem x l] is [true] when [x] occurs in [l] (structural equality). *)

(** {1 Access} *)

val first : 'a list -> 'a option
(** [first l] is the head, [None] on empty — Clojure's [(first l)]. *)

val rest : 'a list -> 'a list
(** [rest l] is the tail, [[]] on empty — Clojure's [(rest l)]. *)

val next : 'a list -> 'a list option
(** [next l] is [None] when {!rest} is empty — Clojure's [next]. *)

val second : 'a list -> 'a option
(** [second l] is the second element — Clojure's [(second l)]. *)

val last : 'a list -> 'a option
(** [last l] is the last element — Clojure's [(last l)]. O(n). *)

val butlast : 'a list -> 'a list
(** [butlast l] drops the last element — Clojure's [butlast]. *)

val nth : 'a list -> int -> 'a
(** [nth l i] is the element at index [i]; raises when out of bounds. *)

val nth_opt : 'a list -> int -> 'a option
(** [nth_opt l i] is [Some (nth l i)] or [None] out of bounds. *)

val peek : 'a list -> 'a option
(** [peek] is {!first} — Clojure's [(peek l)] returns the head. *)

val pop : 'a list -> 'a list
(** [pop] is {!rest}; raises [Failure] on empty. *)

val pop_opt : 'a list -> 'a list option
(** [pop_opt l] is [Some (rest l)] or [None] on empty. *)

(** {1 Update} *)

val conj : 'a list -> 'a -> 'a list
(** [conj l x] prepends — Clojure's [(conj '(a) x)] is [(x a)]. *)

val cons : 'a -> 'a list -> 'a list
(** [cons x l] prepends — Clojure's [(cons x l)]. *)

val into : 'a list -> 'a Stdlib.Seq.t -> 'a list
(** [into l s] conjs each element — as in Clojure, they land reversed at the
    front. *)

(** {1 Transformations} *)

val map : ('a -> 'b) -> 'a list -> 'b list
(** [map f l] applies [f] to each element, eagerly. *)

val mapi : (int -> 'a -> 'b) -> 'a list -> 'b list
(** [mapi f l] maps [f i x] over each element with its index. *)

val map_indexed : (int -> 'a -> 'b) -> 'a list -> 'b list
(** Alias for {!mapi} — Clojure's [map-indexed]. *)

val filter : ('a -> bool) -> 'a list -> 'a list
(** [filter p l] keeps elements satisfying [p], in order. *)

val remove : ('a -> bool) -> 'a list -> 'a list
(** [remove p l] drops elements satisfying [p] — Clojure's [remove]. *)

val filter_map : ('a -> 'b option) -> 'a list -> 'b list
(** [filter_map f l] maps [f] and drops [None] results. *)

val keep : ('a -> 'b option) -> 'a list -> 'b list
(** Alias for {!filter_map} — Clojure's [keep]. *)

val mapcat : ('a -> 'b list) -> 'a list -> 'b list
(** [mapcat f l] maps [f] and concatenates the result lists. *)

val flat_map : ('a -> 'b list) -> 'a list -> 'b list
(** Alias for {!mapcat}. *)

val concat : 'a list list -> 'a list
(** [concat xss] concatenates the lists in order — Clojure's [concat]. *)

val flatten : 'a list list -> 'a list
(** Alias for {!concat} — Clojure's [flatten] (one level only here). *)

val zip : 'a list -> 'b list -> ('a * 'b) list
(** [zip a b] pairs elements; stops at the shorter — Clojure semantics. *)

val map2 : ('a -> 'b -> 'c) -> 'a list -> 'b list -> 'c list
(** [map2 f a b] maps paired elements; stops at the shorter. *)

(** {1 Iteration and folding} *)

val iter : ('a -> unit) -> 'a list -> unit
(** [iter f l] applies [f] to each element in order, for effects. *)

val iteri : (int -> 'a -> unit) -> 'a list -> unit
(** [iteri f l] applies [f i x] with indices. *)

val fold : ('acc -> 'a -> 'acc) -> 'acc -> 'a list -> 'acc
(** Left fold over [l]. *)

val reduce : ('acc -> 'a -> 'acc) -> 'acc -> 'a list -> 'acc
(** Alias for {!fold} — Clojure's [(reduce f init coll)]. *)

val fold_left : ('acc -> 'a -> 'acc) -> 'acc -> 'a list -> 'acc
(** Alias for {!fold}. *)

val fold_right : ('a -> 'acc -> 'acc) -> 'a list -> 'acc -> 'acc
(** Right fold over [l]. *)

val reduce_r : ('acc -> 'a -> 'acc Reduced.t) -> 'acc -> 'a list -> 'acc
(** [reduce_r f acc l] stops early when [f] returns [Reduced.reduced _]. *)

val every_ : ('a -> bool) -> 'a list -> bool
(** [every_ p l] is [true] when every element satisfies [p] — Clojure's
    [every?]. *)

val for_all : ('a -> bool) -> 'a list -> bool
(** Alias for {!every_}. *)

val some : ('a -> bool) -> 'a list -> 'a option
(** [some p l] is the first element satisfying [p]. *)

val not_any_ : ('a -> bool) -> 'a list -> bool
(** [not_any_ p l] is [not (exists p l)] — Clojure's [not-any?]. *)

val not_every_ : ('a -> bool) -> 'a list -> bool
(** [not_every_ p l] is [not (for_all p l)] — Clojure's [not-every?]. *)

val find : ('a -> bool) -> 'a list -> 'a option
(** Alias for {!some}. *)

val find_map : ('a -> 'b option) -> 'a list -> 'b option
(** [find_map f l] is the first [Some _] produced by [f]. *)

(** {1 Slicing and splitting} *)

val take : int -> 'a list -> 'a list
(** [take n l] keeps the first [n] elements (clamped). *)

val drop : int -> 'a list -> 'a list
(** [drop n l] drops the first [n] elements (clamped). *)

val take_while : ('a -> bool) -> 'a list -> 'a list
(** [take_while p l] is the longest prefix satisfying [p]. *)

val drop_while : ('a -> bool) -> 'a list -> 'a list
(** [drop_while p l] drops the longest prefix satisfying [p]. *)

val take_last : int -> 'a list -> 'a list
(** [take_last n l] keeps the last [n] elements (clamped). *)

val drop_last : int -> 'a list -> 'a list
(** [drop_last n l] drops the last [n] elements (clamped). *)

val take_nth : int -> 'a list -> 'a list
(** [take_nth n l] keeps every [n]th element starting at index 0 —
    Clojure's [take-nth]. *)

val nthrest : 'a list -> int -> 'a list
(** [nthrest l n] drops [n] elements — Clojure's [nthrest]. *)

val split_at : int -> 'a list -> 'a list * 'a list
(** [split_at n l] is [(take n l, drop n l)] — Clojure's [split-at]. *)

val split_with : ('a -> bool) -> 'a list -> 'a list * 'a list
(** [split_with p l] is [(take_while p l, drop_while p l)] — Clojure's
    [split-with]. *)

val partition : int -> 'a list -> 'a list list
(** [partition n l] groups consecutive elements into chunks of exactly [n];
    leftover elements are dropped — Clojure's [partition]. *)

val partition_all : int -> 'a list -> 'a list list
(** [partition_all n l] is {!partition} but keeps the trailing partial chunk —
    Clojure's [partition-all]. *)

val partition_by : ('a -> 'b) -> 'a list -> 'a list list
(** [partition_by f l] splits [l] into runs where [f] returns the same value —
    Clojure's [partition-by]. *)

val interleave : 'a list -> 'a list -> 'a list
(** [interleave a b] alternates elements; stops at the shorter. *)

val interpose : 'a -> 'a list -> 'a list
(** [interpose sep l] inserts [sep] between elements — Clojure's
    [interpose]. *)

val dedupe : 'a list -> 'a list
(** Collapses runs of equal adjacent elements — Clojure's [dedupe]. *)

val distinct : 'a list -> 'a list
(** Removes duplicates, keeping first occurrences — Clojure's [distinct]. *)

val reverse : 'a list -> 'a list
(** [reverse l] is [l] in reverse order — Clojure's [reverse]. *)

val rev : 'a list -> 'a list
(** Alias for {!reverse}. *)

val sort : ?cmp:('a -> 'a -> int) -> 'a list -> 'a list
(** [sort ?cmp l] sorts ascending by [cmp] (default [Stdlib.compare]). *)

val sort_by : ?cmp:('b -> 'b -> int) -> ('a -> 'b) -> 'a list -> 'a list
(** [sort_by ?cmp f l] sorts ascending by the keys [f x] — Clojure's
    [sort-by]. *)

val shuffle : ?rng:Stdlib.Random.State.t -> 'a list -> 'a list
(** [shuffle ?rng l] randomly permutes [l] — Clojure's [shuffle]. *)

val group_by : ?cmp:('k -> 'k -> int) -> ('a -> 'k) -> 'a list -> ('k, 'a Vec.t) Map.t
(** [group_by f l] groups elements into a map of key to vector, preserving
    order — Clojure's [group-by]. *)

val frequencies : ?cmp:('a -> 'a -> int) -> 'a list -> ('a, int) Map.t
(** [frequencies l] counts occurrences into a map — Clojure's
    [frequencies]. *)

(** {1 Equality and comparison} *)

val equal : ?eq:('a -> 'a -> bool) -> 'a list -> 'a list -> bool
(** [equal ?eq a b] compares element-wise with [eq] (default [(=)]). *)

val compare : ?cmp:('a -> 'a -> int) -> 'a list -> 'a list -> int
(** [compare ?cmp a b] lexicographic comparison with [cmp]. *)
