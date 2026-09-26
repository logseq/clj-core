(** Atoms: Clojure's [atom] reference cell.

    Implemented on top of a plain [ref], so updates are not safe across OCaml
    5 domains (and on Melange there is only ever one thread anyway). *)

type 'a t
(** A mutable reference cell. *)

val atom : 'a -> 'a t
(** [atom v] creates a cell holding [v]. *)

val deref : 'a t -> 'a
(** [deref a] is Clojure's [@a] / [(deref a)]. *)

val reset_bang : 'a t -> 'a -> 'a
(** [reset_bang a v] sets the cell to [v] and returns [v]. Clojure's [reset!]. *)

val swap_bang : 'a t -> ('a -> 'a) -> 'a
(** [swap_bang a f] replaces the value with [f old] and returns the new value.
    Clojure's [swap!]. *)

val compare_and_set_bang : 'a t -> 'a -> 'a -> bool
(** [compare_and_set_bang a old new_v] sets [a] to [new_v] only when its current
    value is [== old] (physical equality). Clojure's [compare-and-set!]. *)

val reset_vals_bang : 'a t -> 'a -> 'a * 'a
(** [reset_vals_bang a v] sets [a] to [v] and returns [(old, new)]. *)

val swap_vals_bang : 'a t -> ('a -> 'a) -> 'a * 'a
(** [swap_vals_bang a f] applies [f] and returns [(old, new)]. *)
