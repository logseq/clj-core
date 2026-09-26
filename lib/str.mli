(** String helpers — the daily-use pieces of [clojure.string] plus [str]. *)

val str : string Stdlib.Seq.t -> string
(** [str ss] concatenates — Clojure's [(str a b ...)] for strings. *)

val join : ?sep:string -> string Stdlib.Seq.t -> string
(** [join ?sep ss] interposes [sep] (default [""]) — Clojure's
    [clojure.string/join]. *)

val join_list : ?sep:string -> string list -> string
(** [join_list ?sep xs] is {!join} over a list — clojure.string/join. *)

val subs : string -> int -> int -> string
(** [subs s start stop] — Clojure's [subs]; raises on bad bounds. *)

val blank_ : string -> bool
(** [blank_ s] is empty-or-whitespace-only — Clojure's [blank?]. *)

val trim : string -> string
(** [trim s] removes whitespace from both ends — clojure.string/trim. *)

val triml : string -> string
(** [triml s] removes leading whitespace — clojure.string/triml. *)

val trimr : string -> string
(** [trimr s] removes trailing whitespace — clojure.string/trimr. *)

val lower_case : string -> string
(** [lower_case s] lowercases (ASCII) — clojure.string/lower-case. *)

val upper_case : string -> string
(** [upper_case s] uppercases (ASCII) — clojure.string/upper-case. *)

val trim_newline : string -> string
(** [trim_newline s] removes trailing [\n] and [\r] characters —
    clojure.string/trim-newline. *)
val capitalize : string -> string
(** [capitalize s] lowers all but the first character — Clojure's
    [capitalize]. *)

val starts_with_ : string -> string -> bool
(** [starts_with_ s prefix] — clojure.string/starts-with?. *)

val ends_with_ : string -> string -> bool
(** [ends_with_ s suffix] — clojure.string/ends-with?. *)

val includes_ : string -> string -> bool
(** [includes_ s sub] — clojure.string/includes?. *)

val index_of : ?from:int -> string -> string -> int option
(** [index_of ?from s sub] is the index of the first occurrence of the
    literal [sub] at or after [from] (default 0); [None] when absent —
    clojure.string/index-of. *)

val last_index_of : string -> string -> int option
(** [last_index_of s sub] is the index of the last occurrence; [None] when
    absent — clojure.string/last-index-of. *)

val split : string -> on:string -> string list
(** [split s ~on] splits on every occurrence of the literal [on]. *)

val split_lines : string -> string list
(** [split_lines s] splits on '\n', stripping a trailing '\r' per line —
    clojure.string/split-lines. *)

val split_on_char : char -> string -> string list
(** [split_on_char c s] splits on every [c]. *)
val replace : string -> from:string -> by:string -> string
(** [replace s ~from ~by] substitutes every occurrence of the literal [from]. *)

val replace_first : string -> from:string -> by:string -> string
(** [replace_first s ~from ~by] substitutes the first occurrence of the
    literal [from] — clojure.string/replace-first. *)

val repeat : string -> int -> string
(** [repeat s n] is [s] concatenated [n] times — Clojure's [repeat] for
    strings. *)

val reverse : string -> string
(** [reverse s] reverses the bytes — clojure.string/reverse. *)

val pad_left : int -> ?with_:char -> string -> string
(** [pad_left n ?with_ s] pads [s] on the left with [with_] (default [' '])
    to length [n]; longer strings are returned unchanged. *)

val pad_right : int -> ?with_:char -> string -> string
(** [pad_right n ?with_ s] pads [s] on the right with [with_] (default
    [' ']). *)
val escape : string -> (char * string) list -> string
(** [escape s rules] maps each character through the given table —
    Clojure's [clojure.string/escape]. *)

val lines : string -> string list
(** Alias for {!split_lines}. *)

val empty_ : string -> bool
(** [empty_ s] is [String.length s = 0] — Clojure's [empty?] on strings. *)

val length : string -> int
(** [length s] is the byte length. *)
