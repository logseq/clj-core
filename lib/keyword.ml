type t = { ns : string option; name : string }

let keyword ?ns name = { ns; name }

let of_string s =
  let s =
    if String.length s > 0 && s.[0] = ':' then String.sub s 1 (String.length s - 1)
    else s
  in
  match String.index_opt s '/' with
  | Some i ->
    {
      ns = Some (String.sub s 0 i);
      name = String.sub s (i + 1) (String.length s - i - 1);
    }
  | None -> { ns = None; name = s }

let name k = k.name
let namespace k = k.ns
let namespaced_ k = Option.is_some k.ns
let to_symbol_string k =
  match k.ns with Some ns -> ns ^ "/" ^ k.name | None -> k.name

let to_string k = ":" ^ to_symbol_string k
let equal a b = a.ns = b.ns && a.name = b.name
let compare a b =
  match Stdlib.compare a.name b.name with
  | 0 -> Stdlib.compare a.ns b.ns
  | c -> c

let hash k = Hashtbl.hash (k.ns, k.name)
