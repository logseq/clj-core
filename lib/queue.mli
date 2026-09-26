(** Persistent FIFO queues — Clojure's [PersistentQueue].

    [conj] pushes at the rear, [peek]/[pop] take from the front. All
    operations are persistent. *)

type 'a t

val empty : 'a t
val queue : 'a list -> 'a t
val of_list : 'a list -> 'a t
val of_seq : 'a Stdlib.Seq.t -> 'a t

val count : 'a t -> int
val empty_ : 'a t -> bool
val is_empty : 'a t -> bool

val conj : 'a t -> 'a -> 'a t
(** [conj q x] enqueues [x] at the rear. *)

val peek : 'a t -> 'a option
(** [peek q] is the front element — Clojure's [(peek q)] returns nil on
    empty. *)

val pop : 'a t -> 'a t
(** [pop q] dequeues the front element. Raises [Invalid_argument] on empty —
    like Clojure's [(pop q)]. *)

val pop_opt : 'a t -> 'a t option
val pop_full : 'a t -> ('a * 'a t) option
(** [pop_full q] is the dequeued element plus the remainder. *)

val first : 'a t -> 'a option
val rest : 'a t -> 'a t
val next : 'a t -> 'a t option

val into : 'a t -> 'a Stdlib.Seq.t -> 'a t

val iter : ('a -> unit) -> 'a t -> unit
val fold : ('acc -> 'a -> 'acc) -> 'acc -> 'a t -> 'acc
val seq : 'a t -> 'a Stdlib.Seq.t
val to_seq : 'a t -> 'a Stdlib.Seq.t
val to_list : 'a t -> 'a list
val to_vec : 'a t -> 'a Vec.t

val equal : ?eq:('a -> 'a -> bool) -> 'a t -> 'a t -> bool
