(** Volatiles: Clojure's [volatile!] — the cheapest possible mutable cell. *)

type 'a t

val volatile : 'a -> 'a t
(** [volatile v] creates a cell holding [v]. Clojure's [volatile!]. *)

val deref : 'a t -> 'a

val vreset_bang : 'a t -> 'a -> 'a
(** [vreset_bang v x] sets the cell to [x]. Clojure's [vreset!]. *)

val vswap_bang : 'a t -> ('a -> 'a) -> 'a
(** [vswap_bang v f] replaces the value with [f old]. Clojure's [vswap!]. *)
