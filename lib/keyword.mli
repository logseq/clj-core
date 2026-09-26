(** Keywords — Clojure's [:name] and [:ns/name] interned literals.

    Represented as a plain record so structural equality and hashing work
    (usable as {!Map} keys with the default comparator). *)

type t = { ns : string option; name : string }
(** A keyword with an optional namespace. *)

val keyword : ?ns:string -> string -> t
(** [keyword "name"] or [keyword ~ns:"ns" "name"] — Clojure's [keyword]. *)

val of_string : string -> t
(** [of_string s] parses ["ns/name"], [":name"], or ["name"] — a leading ':'
    is stripped. *)

val name : t -> string
(** The name part — Clojure's [(name k)]. *)

val namespace : t -> string option
(** The namespace part, [None] when absent — Clojure's [(namespace k)]. *)

val namespaced_ : t -> bool
(** [namespaced_ k] is [true] when [k] has a namespace. *)

val to_string : t -> string
(** [to_string k] renders the reader form, e.g. [":ns/name"]. *)

val to_symbol_string : t -> string
(** [to_symbol_string k] renders without the leading ':', e.g. ["ns/name"]. *)

val equal : t -> t -> bool
(** Structural equality on [ns] and [name]. *)

val compare : t -> t -> int
(** [compare a b] orders by namespace first, then name; a namespace-less
    keyword sorts before any namespaced one — matching Clojure's [compare]. *)

val hash : t -> int
(** Structural hash — usable as {!Map} keys via [Stdlib.compare]. *)
