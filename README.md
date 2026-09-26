# clj-core

Clojure's data structures and core API for OCaml. `clj-core` ports the parts of
Clojure that make everyday code pleasant — persistent vectors, sorted maps and
sets, lazy seqs, atoms, delays, keywords — so OCaml code can use them with the
same names and argument order as `clojure.core`.

The library builds on [rrbvec](https://github.com/logseq/rrbvec) for the
persistent vector (log₂₃₂ lookup/append, O(1)-ish concat/slice) and layers
Clojure's semantics on top.

```ocaml
open Clj_core

let v = Vec.of_list [ 1; 2; 3 ]
let v' = Vec.conj v 4            (* [1 2 3 4] *)
let m = Map.of_list int_cmp [ ("a", 1) ]  (* see note on comparators below *)
let n = Core.(
  into_vec
    (map (fun x -> x * x)
       (filter (fun x -> x mod 2 = 0)
          (range 10))))
(* [0; 4; 16; 36; 64] *)
```

## Modules

Each collection type mirrors its Clojure counterpart; names follow the standard
OCaml munging (`?` → `_`, `!` → `_bang`, `-` → `_`):

| Module | Clojure | Contents |
|---|---|---|
| `Vec` | vector | persistent vector over `rrbvec`: `conj`, `pop`, `peek`, `nth`, `assoc`, `subvec`, `concat`, `map`, `filter`, `reduce`, `mapcat`, `into`, `seq`/`rseq` |
| `Map` | sorted map | persistent sorted map: `assoc`, `dissoc`, `get`, `contains_`, `update`, `merge`, `merge_with`, `select_keys`, `zipmap`, sorted iteration, `slice` |
| `Set` | sorted set | `type 'a Set.t = ('a, unit) Map.t` plus `union`, `intersection`, `difference`, `subset_`, `select` |
| `List` | list | `cons`, `conj` (prepends), `rest`, `map`, `filter`, `take`/`drop` family, `partition*`, `group_by`, `frequencies` |
| `Seq` | lazy seq | `'a Seq.t = 'a Stdlib.Seq.t`: lazy `map`/`filter`/`take`/`drop`, generators (`iterate`, `repeat`, `repeatedly`, `cycle`, `range`, `ints`), `reduce`/`reduce_r` with early `Reduced` termination |
| `Queue` | queue | `conj`, `pop`, `peek`, `into` |
| `Atom` | atom | `atom`, `deref`, `reset_bang`, `swap_bang`, `compare_and_set_bang`, `add_watch`/`remove_watch` (OCaml `ref` — single-domain; see caveats) |
| `Delay` | delay | `delay`, `force`, `realized_` |
| `Volatile` | volatile! | `volatile`, `vreset_bang`, `vswap_bang` |
| `Reduced` | reduced | `Reduced.t`, `reduced`, `reduced_`, `unreduced`, `deref` — early termination for `reduce` |
| `Keyword` / `Symbol` | keyword / symbol | interned-ish records: `keyword`, `of_string`, `to_string`, `ns`, `name` |
| `Str` | clojure.string | `blank_`, `join`, `trim*`, `capitalize`, `split`, `replace*`, `includes_`, `index_of`, `pad_*`, `escape` |
| `Core` | clojure.core | collection-generic ops over a `coll` view, `into_*` conversions, generators, combinators (`comp`, `juxt`, `partial`-ish `fnil`, `complement`, `constantly`), numeric predicates, `deref`, `ex_info` |

## Conventions

- **Argument order** follows Clojure so `->`/`->>` pipelines map to `|>`:
  update/access ops take the collection first (`Vec.conj v x`,
  `Map.assoc m k v`, `Map.update m k f`, `Vec.nth v i`); seq/transform ops take
  it last (`Seq.map f s`, `List.map f l`, `Core.map f coll`).
- **Option vs raise**: failable lookups return `option` (`get`, `nth_opt`,
  `peek_opt`, `seq`, `next`, `subvec`); `*_exn` variants raise — matching
  Clojure's nil-tolerant core where an equivalent exists.
- **`seq` returns `None` on empty** — Clojure's nil-punning.
- **Comparators**: `Map`/`Set` are sorted structures and take an explicit
  comparator (`int_cmp`, `str_cmp`, `poly_cmp`, or your own `cmp:` argument)
  instead of a functor, so maps with different key orderings interconvert.
- **`Seq.t`** is `Stdlib.Seq.t` — every collection exposes `to_seq`, and
  `Core`'s generic ops produce lazy `Seq.t`s that fuse without intermediate
  collections.
- **Multi-collection `map`/`zip`** stop at the shortest input, like Clojure.

## Not ported (yet)

- Transients, transducers, chunked seqs
- `get_in`/`assoc_in`/`update_in` (untypable over heterogeneous nesting in
  OCaml — use per-level `Map.get`/`update`)
- Metadata, protocols, multimethods
- `Atom` is an OCaml `ref`: swap semantics hold on a single domain; it does
  not provide Clojure's cross-thread atomicity. `Volatile` is documented
  similarly.

## Building

```sh
opam pin add -y rrbvec git+https://github.com/logseq/rrbvec.git#main
opam install . --deps-only
dune build
dune runtest        # alcotest suite: unit + randomized model tests
```

The library builds for native, bytecode, and Melange (`(modes native byte melange)`).
