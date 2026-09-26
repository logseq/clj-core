(lang dune 3.23)

(using melange 1.0)

(name clj-core)

(generate_opam_files true)

(source
 (github logseq/clj-core))

(authors "Tienson Qin <tiensonqin@gmail.com>")

(maintainers "Tienson Qin <tiensonqin@gmail.com>")

(license MIT)

(documentation https://github.com/logseq/clj-core)

(package
 (name clj-core)
 (synopsis "Clojure-style data structures and core API for OCaml")
 (description
  "clj-core ports the daily-use surface of clojure.core to OCaml: persistent vectors (backed by rrbvec), sorted maps and sets, lists, lazy sequences, queues, atoms, delays, keywords, and function combinators. Names follow the lg munging convention: ? -> _, ! -> _bang, - -> _.")
 (depends
  (ocaml
   (>= 5.1))
  (dune
   (>= 3.23))
  rrbvec
  (alcotest :with-test)))
