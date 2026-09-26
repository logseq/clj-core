(** Symbols — Clojure's [name] and [ns/name] interned literals (no leading
    ':'), same shape as {!Keyword}. *)

type t = { ns : string option; name : string }

val symbol : ?ns:string -> string -> t
val of_string : string -> t
val name : t -> string
val namespace : t -> string option
val namespaced_ : t -> bool
val to_string : t -> string
val equal : t -> t -> bool
val compare : t -> t -> int
val hash : t -> int
