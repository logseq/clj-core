(** clojure.core — the daily-use layer.

    Collection-generic operations work on the polymorphic variant {!coll},
    which lifts every persistent collection (plus arrays, strings and lazy
    seqs) into one view:

    {[
      open Clj_core
      Core.map succ (`Vec (Vec.of_list [1; 2; 3]))
      Core.filter even (`Set myset)
      Core.first (Core.coll_of_string "abc")  (* Some 'a' *)
      Core.first (Core.coll_of_map m)         (* Some (k, v) *)
    ]}

    Seq-producing functions return lazy ['a Stdlib.Seq.t] — force with
    {!into_vec}, {!into_list} or {!doall}. *)

(** {1 Collection view} *)

type 'a coll =
  [ `Vec of 'a Vec.t
  | `Lst of 'a list
  | `Arr of 'a array
  | `Seq of 'a Stdlib.Seq.t
  | `Set of 'a Set.t ]

val coll_of_map : ('k, 'v) Map.t -> ('k * 'v) coll
(** [coll_of_map m] views a map as a coll of [(key, value)] pairs. *)

val coll_of_string : string -> char coll
(** [coll_of_string s] views a string as a coll of characters. *)

val seq : 'a coll -> 'a Stdlib.Seq.t option
(** [seq c] is [None] when the collection is empty — Clojure's [seq]. *)

val to_seq : 'a coll -> 'a Stdlib.Seq.t
val count : 'a coll -> int
val empty_ : 'a coll -> bool
val is_empty : 'a coll -> bool
val first : 'a coll -> 'a option
val ffirst : 'a Stdlib.Seq.t coll -> 'a option
(** [ffirst c] is [first] of the first element — Clojure's [ffirst]. *)

val rest : 'a coll -> 'a Stdlib.Seq.t
val next : 'a coll -> 'a Stdlib.Seq.t option
val second : 'a coll -> 'a option
val last : 'a coll -> 'a option
val nth : 'a coll -> int -> 'a
val nth_opt : 'a coll -> int -> 'a option
val mem : 'a -> 'a coll -> bool
(** [mem x c] linear search — Clojure's [(some #(= x %) c)]. *)

val map : ('a -> 'b) -> 'a coll -> 'b Stdlib.Seq.t
val filter : ('a -> bool) -> 'a coll -> 'a Stdlib.Seq.t
val remove : ('a -> bool) -> 'a coll -> 'a Stdlib.Seq.t
val filter_map : ('a -> 'b option) -> 'a coll -> 'b Stdlib.Seq.t
val keep : ('a -> 'b option) -> 'a coll -> 'b Stdlib.Seq.t
val keep_indexed : (int -> 'a -> 'b option) -> 'a coll -> 'b Stdlib.Seq.t
val map_indexed : (int -> 'a -> 'b) -> 'a coll -> 'b Stdlib.Seq.t
val mapcat : ('a -> 'b coll) -> 'a coll -> 'b Stdlib.Seq.t
val flat_map : ('a -> 'b coll) -> 'a coll -> 'b Stdlib.Seq.t
val concat : 'a coll coll -> 'a Stdlib.Seq.t
val take : int -> 'a coll -> 'a Stdlib.Seq.t
val drop : int -> 'a coll -> 'a Stdlib.Seq.t
val take_while : ('a -> bool) -> 'a coll -> 'a Stdlib.Seq.t
val drop_while : ('a -> bool) -> 'a coll -> 'a Stdlib.Seq.t
val take_nth : int -> 'a coll -> 'a Stdlib.Seq.t
val interpose : 'a -> 'a coll -> 'a Stdlib.Seq.t
val dedupe : 'a coll -> 'a Stdlib.Seq.t
val distinct : 'a coll -> 'a Stdlib.Seq.t
val partition_all : int -> 'a coll -> 'a Stdlib.Seq.t Stdlib.Seq.t
val partition_by : ('a -> 'b) -> 'a coll -> 'a Stdlib.Seq.t Stdlib.Seq.t
val reductions : ('acc -> 'a -> 'acc) -> 'acc -> 'a coll -> 'acc Stdlib.Seq.t

val reduce : ('acc -> 'a -> 'acc) -> 'acc -> 'a coll -> 'acc
val reduce_r : ('acc -> 'a -> 'acc Reduced.t) -> 'acc -> 'a coll -> 'acc
val fold : ('acc -> 'a -> 'acc) -> 'acc -> 'a coll -> 'acc
val iter : ('a -> unit) -> 'a coll -> unit
val every_ : ('a -> bool) -> 'a coll -> bool
val some : ('a -> bool) -> 'a coll -> 'a option
val not_any_ : ('a -> bool) -> 'a coll -> bool
val not_every_ : ('a -> bool) -> 'a coll -> bool
val find : ('a -> bool) -> 'a coll -> 'a option
val find_map : ('a -> 'b option) -> 'a coll -> 'b option

val reverse : 'a coll -> 'a Stdlib.Seq.t
val sort : ?cmp:('a -> 'a -> int) -> 'a coll -> 'a Stdlib.Seq.t
val sort_by : ?cmp:('b -> 'b -> int) -> ('a -> 'b) -> 'a coll -> 'a Stdlib.Seq.t
val shuffle : ?rng:Stdlib.Random.State.t -> 'a coll -> 'a Stdlib.Seq.t
val group_by :
  ?cmp:('k -> 'k -> int) -> ('a -> 'k) -> 'a coll -> ('k, 'a Vec.t) Map.t

val frequencies : ?cmp:('a -> 'a -> int) -> 'a coll -> ('a, int) Map.t
val min_key : ('a -> 'b) -> 'a coll -> 'a option
val max_key : ('a -> 'b) -> 'a coll -> 'a option
(** [min_key f c] is the element minimizing [f] — Clojure's [min-key]. *)

(** {1 Realization} *)

val doall : 'a Stdlib.Seq.t -> 'a list
val dorun : 'a Stdlib.Seq.t -> unit
val into_vec : 'a coll -> 'a Vec.t
val into_list : 'a coll -> 'a list
val into_set : ?cmp:('a -> 'a -> int) -> 'a coll -> 'a Set.t
val into_map : ?cmp:('k -> 'k -> int) -> ('k * 'v) coll -> ('k, 'v) Map.t
(** [into_map c] collects a pair seq into a {!Map.t} — Clojure's
    [(into {} ...)]. *)

(** {1 Generators} *)

val iterate : ('a -> 'a) -> 'a -> 'a Stdlib.Seq.t
val repeat : ?n:int -> 'a -> 'a Stdlib.Seq.t
val repeatedly : ?n:int -> (unit -> 'a) -> 'a Stdlib.Seq.t
val cycle : 'a coll -> 'a Stdlib.Seq.t
val range : ?start:int -> ?step:int -> int -> int Stdlib.Seq.t
val lazy_seq : (unit -> 'a Stdlib.Seq.t) -> 'a Stdlib.Seq.t

(** {1 Combinators} *)

val identity : 'a -> 'a
val constantly : 'a -> 'b -> 'a
val comp : ('b -> 'c) -> ('a -> 'b) -> 'a -> 'c
val comp3 : ('c -> 'd) -> ('b -> 'c) -> ('a -> 'b) -> 'a -> 'd
val complement : ('a -> bool) -> 'a -> bool
val fnil : ('a -> 'b) -> 'b -> 'a option -> 'b
val juxt : ('a -> 'b) -> ('a -> 'c) -> 'a -> 'b * 'c
val juxt3 : ('a -> 'b) -> ('a -> 'c) -> ('a -> 'd) -> 'a -> 'b * 'c * 'd
val memoize : ('a -> 'b) -> 'a -> 'b
val if_ : bool -> (unit -> 'a) -> (unit -> 'a) -> 'a
val when_ : bool -> (unit -> unit) -> unit
val when_some : 'a option -> ('a -> unit) -> unit
val cond : (bool * (unit -> 'a)) list -> 'a option
val or_else : 'a option -> 'a -> 'a
(** [or_else opt default] — Clojure's [(or x default)]. *)

val nil_ : 'a option -> bool
val some_ : 'a option -> bool
val is_none : 'a option -> bool

(** {1 Numbers} *)

val inc : int -> int
val dec : int -> int
val zero_ : int -> bool
val pos_ : int -> bool
val neg_ : int -> bool
val even_ : int -> bool
val odd_ : int -> bool
val abs : int -> int
val quot : int -> int -> int
val rem : int -> int -> int
val mod_ : int -> int -> int
(** [mod_] is floored modulo — sign follows the divisor, like Clojure's
    [mod] (unlike {!rem}, which follows the dividend). *)

val rand : ?rng:Stdlib.Random.State.t -> unit -> float
val rand_int : ?rng:Stdlib.Random.State.t -> int -> int
val rand_nth : ?rng:Stdlib.Random.State.t -> 'a coll -> 'a
val min2 : int -> int -> int
val max2 : int -> int -> int
val sum : int coll -> int
val product : int coll -> int
val sumf : float coll -> float

(** {1 Strings and printing} *)

val str : string coll -> string
(** [str (`Lst ["a"; "b"])] concatenates — strings only (OCaml has no
    universal [toString]); use {!Str.str} on string seqs. *)

val print : string -> unit
val println : string -> unit
val prn : string -> unit

(** {1 Reference types} *)

type 'a derefable =
  [ `Atom of 'a Atom.t
  | `Delay of 'a Delay.t
  | `Volatile of 'a Volatile.t
  | `Ref of 'a ref ]

val deref : 'a derefable -> 'a
val atom : 'a -> 'a Atom.t
val delay : (unit -> 'a) -> 'a Delay.t
val realized_ : 'a Delay.t -> bool

(** {1 Errors} *)

exception Ex_info of string * (string, string) Map.t

val ex_info : string -> (string, string) Map.t -> exn
val ex_data : exn -> (string, string) Map.t option
val ex_message : exn -> string
