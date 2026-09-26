(** Early termination markers for folds, like Clojure's [reduced].

    Fold-style functions taking a [Reduced.t]-returning step function stop as
    soon as the step returns [Reduced acc]. *)

type 'a t = Continue of 'a | Reduced of 'a
(** A step result: [Continue acc] keeps folding, [Reduced acc] stops with [acc]
    as the result. *)

val continue : 'a -> 'a t
(** Wrap a value to keep folding. *)

val reduced : 'a -> 'a t
(** Wrap a value to stop folding with that value as the result. *)

val unreduced : 'a t -> 'a
(** Unwrap either constructor to the carried value. *)

val reduced_ : 'a t -> bool
(** [reduced_ r] is [true] when [r] was built with {!reduced}. *)

val ensure_reduced : 'a t -> 'a t
(** [ensure_reduced r] wraps [Continue x] as [Reduced x]; already-reduced
    values pass through — Clojure's [ensure-reduced]. *)
