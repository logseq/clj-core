(** Persistent FIFO queues — Clojure's [PersistentQueue].

    [conj] pushes at the rear, [peek]/[pop] take from the front. All
    operations are persistent. *)

type 'a t
(** A persistent first-in-first-out queue. *)

(** {1 Construction} *)

val empty : 'a t
(** The empty queue — Clojure's [PersistentQueue/EMPTY]. *)

val queue : 'a list -> 'a t
(** [queue xs] builds a queue whose front is the head of [xs]. *)

val of_list : 'a list -> 'a t
(** Alias for {!queue}. *)

val of_seq : 'a Stdlib.Seq.t -> 'a t
(** Like {!of_list} from a sequence. *)

(** {1 Predicates and size} *)

val count : 'a t -> int
(** [count q] is the number of elements — Clojure's [(count q)]. *)

val empty_ : 'a t -> bool
(** [empty_ q] is [true] when [q] has no elements — Clojure's [(empty? q)]. *)

val is_empty : 'a t -> bool
(** Alias for {!empty_}. *)

(** {1 Update (persistent)} *)

val conj : 'a t -> 'a -> 'a t
(** [conj q x] enqueues [x] at the rear — Clojure's [(conj q x)]. *)

val into : 'a t -> 'a Stdlib.Seq.t -> 'a t
(** [into q xs] conjs each element onto the rear of [q]. *)

(** {1 Access} *)

val peek : 'a t -> 'a option
(** [peek q] is the front element — Clojure's [(peek q)] returns nil on
    empty. *)

val pop : 'a t -> 'a t
(** [pop q] dequeues the front element. Raises [Invalid_argument] on empty —
    like Clojure's [(pop q)]. *)

val pop_opt : 'a t -> 'a t option
(** [pop_opt q] is [Some q'] or [None] on empty. *)

val pop_full : 'a t -> ('a * 'a t) option
(** [pop_full q] is the dequeued element plus the remainder. *)

val first : 'a t -> 'a option
(** Alias for {!peek} — Clojure's [(first q)]. *)

val rest : 'a t -> 'a t
(** [rest q] drops the front; returns the empty queue when empty —
    Clojure's [(rest q)] never throws. *)

val next : 'a t -> 'a t option
(** [next q] is [None] when {!rest} is empty — Clojure's [next]. *)

(** {1 Iteration and conversions} *)

val iter : ('a -> unit) -> 'a t -> unit
(** [iter f q] applies [f] front-to-back. *)

val fold : ('acc -> 'a -> 'acc) -> 'acc -> 'a t -> 'acc
(** Left fold front-to-back. *)

val seq : 'a t -> 'a Stdlib.Seq.t
(** [seq q] iterates front-to-back. *)

val to_seq : 'a t -> 'a Stdlib.Seq.t
(** Alias for {!seq}. *)

val to_list : 'a t -> 'a list
(** [to_list q] is the elements front-to-back as a list. *)

val to_vec : 'a t -> 'a Vec.t
(** [to_vec q] is the elements front-to-back as a vector. *)

(** {1 Equality} *)

val equal : ?eq:('a -> 'a -> bool) -> 'a t -> 'a t -> bool
(** [equal ?eq a b] compares element-wise front-to-back with [eq] (default
    [(=)]). *)
