(** String helpers — the daily-use pieces of [clojure.string] plus [str]. *)

val str : string Stdlib.Seq.t -> string
(** [str ss] concatenates — Clojure's [(str a b ...)] for strings. *)

val join : ?sep:string -> string Stdlib.Seq.t -> string
(** [join ?sep ss] interposes [sep] (default [""]) — Clojure's
    [clojure.string/join]. *)

val join_list : ?sep:string -> string list -> string

val subs : string -> int -> int -> string
(** [subs s start stop] — Clojure's [subs]; raises on bad bounds. *)

val blank_ : string -> bool
(** [blank_ s] is empty-or-whitespace-only — Clojure's [blank?]. *)

val trim : string -> string
val triml : string -> string
val trimr : string -> string
val lower_case : string -> string
val upper_case : string -> string
val capitalize : string -> string
(** [capitalize s] lowers all but the first character — Clojure's
    [capitalize]. *)

val starts_with_ : string -> string -> bool
val ends_with_ : string -> string -> bool
val includes_ : string -> string -> bool
val index_of : ?from:int -> string -> string -> int option
val last_index_of : string -> string -> int option

val split : string -> on:string -> string list
(** [split s ~on] splits on every occurrence of the literal [on]. *)

val split_lines : string -> string list
val split_on_char : char -> string -> string list
val replace : string -> from:string -> by:string -> string
(** [replace s ~from ~by] substitutes every occurrence of the literal [from]. *)

val replace_first : string -> from:string -> by:string -> string
val repeat : string -> int -> string
val reverse : string -> string
val pad_left : int -> ?with_:char -> string -> string
val pad_right : int -> ?with_:char -> string -> string
val escape : string -> (char * string) list -> string
(** [escape s rules] maps each character through the given table —
    Clojure's [clojure.string/escape]. *)

val lines : string -> string list
val empty_ : string -> bool
val length : string -> int
