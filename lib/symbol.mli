(** Symbols — Clojure's [name] and [ns/name] interned literals (no leading
    ':'), same shape as {!Keyword}. *)

type t = { ns : string option; name : string }
(** A symbol with an optional namespace. *)

val symbol : ?ns:string -> string -> t
(** [symbol "name"] or [symbol ~ns:"ns" "name"] — Clojure's [symbol]. *)

val of_string : string -> t
(** [of_string s] parses ["ns/name"] or ["name"]; a leading ':' is stripped. *)

val name : t -> string
(** The name part — Clojure's [(name sym)]. *)

val namespace : t -> string option
(** The namespace part, [None] when absent — Clojure's [(namespace sym)]. *)

val namespaced_ : t -> bool
(** [namespaced_ s] is [true] when [s] has a namespace. *)

val to_string : t -> string
(** [to_string s] renders the reader form, e.g. ["ns/name"]. *)

val equal : t -> t -> bool
(** Structural equality on [ns] and [name]. *)

val compare : t -> t -> int
(** [compare a b] orders by namespace first, then name; a namespace-less
    symbol sorts before any namespaced one — matching Clojure's [compare]. *)

val hash : t -> int
(** Structural hash — usable as {!Map} keys via [Stdlib.compare]. *)
