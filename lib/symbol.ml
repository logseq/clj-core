type t = { ns : string option; name : string }

let symbol ?ns name = { ns; name }

let of_string s =
  match String.index_opt s '/' with
  | Some i ->
    {
      ns = Some (String.sub s 0 i);
      name = String.sub s (i + 1) (String.length s - i - 1);
    }
  | None -> { ns = None; name = s }

let name s = s.name
let namespace s = s.ns
let namespaced_ s = Option.is_some s.ns
let to_string s =
  match s.ns with Some ns -> ns ^ "/" ^ s.name | None -> s.name

let equal a b = a.ns = b.ns && a.name = b.name

let compare a b =
  match Stdlib.compare a.name b.name with
  | 0 -> Stdlib.compare a.ns b.ns
  | c -> c

let hash s = Hashtbl.hash (s.ns, s.name)
