open Clj_core

let test_keyword () =
  let k = Keyword.of_string ":foo/bar" in
  Alcotest.(check (option string)) "ns" (Some "foo") (Keyword.namespace k);
  Alcotest.(check string) "name" "bar" (Keyword.name k);
  Alcotest.(check string) "to_string" ":foo/bar" (Keyword.to_string k);
  Alcotest.(check string) "to_symbol_string" "foo/bar" (Keyword.to_symbol_string k);
  Alcotest.(check bool) "namespaced" true (Keyword.namespaced_ k);
  let k2 = Keyword.of_string "baz" in
  Alcotest.(check (option string)) "no ns" None (Keyword.namespace k2);
  Alcotest.(check bool) "not namespaced" false (Keyword.namespaced_ k2);
  Alcotest.(check string) "colon name" ":baz" (Keyword.to_string k2);
  let k3 = Keyword.keyword ~ns:"my.ns" "x" in
  Alcotest.(check string) "constructor" ":my.ns/x" (Keyword.to_string k3);
  Alcotest.(check bool) "equal" true (Keyword.equal k (Keyword.of_string "foo/bar"));
  Alcotest.(check bool) "not equal" false (Keyword.equal k k2);
  Alcotest.(check int) "hash" (Keyword.hash k) (Keyword.hash (Keyword.of_string ":foo/bar"))

let test_keyword_as_key () =
  let m =
    Map.of_list
      [ (Keyword.of_string ":a", 1); (Keyword.of_string ":b", 2) ]
  in
  Alcotest.(check (option int)) "lookup" (Some 2) (Map.get m (Keyword.of_string "b"))

let test_symbol () =
  let s = Symbol.of_string "my.ns/foo" in
  Alcotest.(check (option string)) "ns" (Some "my.ns") (Symbol.namespace s);
  Alcotest.(check string) "name" "foo" (Symbol.name s);
  Alcotest.(check string) "to_string" "my.ns/foo" (Symbol.to_string s);
  Alcotest.(check bool) "namespaced" true (Symbol.namespaced_ s);
  let s2 = Symbol.of_string "x" in
  Alcotest.(check (option string)) "no ns" None (Symbol.namespace s2);
  Alcotest.(check bool) "equal" true (Symbol.equal s (Symbol.symbol ~ns:"my.ns" "foo"));
  Alcotest.(check int) "hash" (Symbol.hash s) (Symbol.hash (Symbol.of_string "my.ns/foo"))

let () =
  Alcotest.run "Keyword+Symbol"
    [
      ("keyword", [ Alcotest.test_case "ops" `Quick test_keyword ]);
      ("keyword-as-key", [ Alcotest.test_case "map key" `Quick test_keyword_as_key ]);
      ("symbol", [ Alcotest.test_case "ops" `Quick test_symbol ]);
    ]
