(** Delays: memoized lazy computations. Clojure's [delay]/[force]/[realized?]
    over {!Lazy.t}. *)

type 'a t = 'a Lazy.t
(** A deferred computation, forced at most once. *)

val delay : (unit -> 'a) -> 'a t
(** [delay f] defers [f] until the first {!force}; the result is memoized. *)

val force : 'a t -> 'a
(** [force d] runs the deferred computation once; later calls return the
    memoized value — Clojure's [force]. *)

val deref : 'a t -> 'a
(** [force]/[deref] run the deferred computation once and return its value. *)

val realized_ : 'a t -> bool
(** [realized_ d] is [true] when [d] has already been forced. *)
