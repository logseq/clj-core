(* Watches are keyed by an erased key ([Obj.t]) so keys of different types can
   coexist on one atom, like Clojure's keyed watches. *)

type 'a t = {
  mutable value : 'a;
  mutable watches : (Obj.t * ('a t -> 'a -> 'a -> unit)) list;
  mutable validator : ('a -> bool) option;
}

let atom v = { value = v; watches = []; validator = None }
let deref a = a.value

let set_validator_bang a f = a.validator <- f
let get_validator a = a.validator

let add_watch a k f = a.watches <- (Obj.repr k, f k) :: a.watches

let remove_watch a k =
  let k = Obj.repr k in
  a.watches <- Stdlib.List.filter (fun (k', _) -> k' <> k) a.watches

let validate a v =
  match a.validator with
  | Some f when not (f v) ->
    invalid_arg "Clj_core.Atom: validator rejected the new value"
  | _ -> ()

let notify a old new_ =
  Stdlib.List.iter (fun (_, f) -> f a old new_) a.watches

let set a v =
  validate a v;
  let old = a.value in
  a.value <- v;
  notify a old v;
  v

let reset_bang a v = set a v
let swap_bang a f = set a (f a.value)

let compare_and_set_bang a old new_v =
  if a.value == old then begin
    validate a new_v;
    a.value <- new_v;
    notify a old new_v;
    true
  end
  else false

let reset_vals_bang a v =
  validate a v;
  let old = a.value in
  a.value <- v;
  notify a old v;
  (old, v)

let swap_vals_bang a f =
  let old = a.value in
  let new_v = f old in
  validate a new_v;
  a.value <- new_v;
  notify a old new_v;
  (old, new_v)
