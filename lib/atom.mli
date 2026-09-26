(** Atoms: Clojure's [atom] reference cell.

    Implemented on top of a mutable record, so updates are not safe across
    OCaml 5 domains (and on Melange there is only ever one thread anyway). *)

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

(** {1 Watches and validation} *)

val add_watch : 'a t -> 'k -> ('k -> 'a t -> 'a -> 'a -> unit) -> unit
(** [add_watch a k f] registers [f k a old new_] to run after every state
    change — Clojure's [add-watch]. Keys of different types may coexist. *)

val remove_watch : 'a t -> 'k -> unit
(** [remove_watch a k] removes the watch registered under key [k] —
    Clojure's [remove-watch]. *)

val set_validator_bang : 'a t -> ('a -> bool) option -> unit
(** [set_validator_bang a f] installs a validator ([None] clears it):
    every attempted new value must satisfy [f] or the update raises —
    Clojure's [set-validator!]. *)

val get_validator : 'a t -> ('a -> bool) option
(** [get_validator a] is the installed validator — Clojure's
    [get-validator]. *)
