(* Clojure's PersistentQueue: a front list served first and a rear vector
   collecting conjs; when the front drains, the rear flips to the front. *)
type 'a t = { front : 'a list; rear : 'a Vec.t }

let empty = { front = []; rear = Vec.empty }
let queue xs = { front = xs; rear = Vec.empty }
let of_list = queue
let of_seq s = Stdlib.Seq.fold_left (fun q x -> { q with rear = Vec.conj q.rear x }) empty s

let count q = Stdlib.List.length q.front + Vec.count q.rear
let empty_ q = q.front = [] && Vec.empty_ q.rear
let is_empty = empty_

let conj q x = { q with rear = Vec.conj q.rear x }

let peek q =
  match q.front with
  | x :: _ -> Some x
  | [] -> Vec.peek_front q.rear

let first = peek

let pop_full q =
  match q.front with
  | x :: xs -> Some (x, { q with front = xs })
  | [] -> (
      (* front drained: serve the rear once as a list *)
      match Vec.to_list q.rear with
      | [] -> None
      | x :: xs -> Some (x, { front = xs; rear = Vec.empty }))

let pop_opt q = Option.map snd (pop_full q)

let pop q =
  match pop_opt q with
  | Some q' -> q'
  | None -> invalid_arg "Clj_core.Queue.pop: pop on empty queue"

let rest q = match pop_opt q with Some q' -> q' | None -> q
let next q = match pop_full q with Some (_, q') when not (empty_ q') -> Some q' | _ -> None
let into q s = Stdlib.Seq.fold_left conj q s

let to_list q = q.front @ Vec.to_list q.rear
let to_seq q = Stdlib.List.to_seq (to_list q)
let seq = to_seq
let to_vec q = Vec.of_list (to_list q)

let iter f q = Stdlib.List.iter f (to_list q)
let fold f acc q = Stdlib.List.fold_left f acc (to_list q)
let equal ?(eq = ( = )) a b = Stdlib.List.equal eq (to_list a) (to_list b)
