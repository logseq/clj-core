open Clj_core
module S = Str

let test_concat () =
  Alcotest.(check string) "str" "abc" (S.str (List.to_seq [ "a"; "b"; "c" ]));
  Alcotest.(check string) "join" "a,b,c" (S.join ~sep:"," (List.to_seq [ "a"; "b"; "c" ]));
  Alcotest.(check string) "join nosep" "abc" (S.join (List.to_seq [ "a"; "b"; "c" ]));
  Alcotest.(check string) "join_list" "a-b" (S.join_list ~sep:"-" [ "a"; "b" ]);
  Alcotest.(check string) "join empty" "" (S.join Stdlib.Seq.empty)

let test_predicates () =
  Alcotest.(check bool) "blank empty" true (S.blank_ "");
  Alcotest.(check bool) "blank ws" true (S.blank_ "  \t\n ");
  Alcotest.(check bool) "blank no" false (S.blank_ " a ");
  Alcotest.(check bool) "empty" true (S.empty_ "");
  Alcotest.(check bool) "starts" true (S.starts_with_ "foobar" "foo");
  Alcotest.(check bool) "starts no" false (S.starts_with_ "foobar" "bar");
  Alcotest.(check bool) "ends" true (S.ends_with_ "foobar" "bar");
  Alcotest.(check bool) "includes" true (S.includes_ "foobar" "oba");
  Alcotest.(check bool) "includes empty" true (S.includes_ "abc" "");
  Alcotest.(check bool) "includes no" false (S.includes_ "abc" "d")

let test_transforms () =
  Alcotest.(check string) "trim" "a" (S.trim "  a  ");
  Alcotest.(check string) "triml" "a  " (S.triml "  a  ");
  Alcotest.(check string) "trimr" "  a" (S.trimr "  a  ");
  Alcotest.(check string) "lower" "abc" (S.lower_case "AbC");
  Alcotest.(check string) "upper" "ABC" (S.upper_case "AbC");
  Alcotest.(check string) "capitalize" "Abc" (S.capitalize "aBC");
  Alcotest.(check string) "subs" "bc" (S.subs "abcd" 1 3);
  Alcotest.(check string) "reverse" "cba" (S.reverse "abc");
  Alcotest.(check string) "repeat" "abab" (S.repeat "ab" 2);
  Alcotest.(check string) "pad_left" "  x" (S.pad_left 3 "x");
  Alcotest.(check string) "pad_right" "x  " (S.pad_right 3 "x");
  Alcotest.(check string) "pad_left char" "00x" (S.pad_left 3 ~with_:'0' "x");
  Alcotest.(check string) "escape" "\\\"a\\\" \\\\b" (S.escape "\"a\" \\b" [ ('\"', "\\\""); ('\\', "\\\\") ])

let test_split_find () =
  Alcotest.(check (list string)) "split" [ "a"; "b"; "c" ] (S.split "a,b,c" ~on:",");
  Alcotest.(check (list string)) "split multi" [ "a"; "b" ] (S.split "a--b" ~on:"--");
  Alcotest.(check (list string)) "split edge" [ ""; "a"; "" ] (S.split ",a," ~on:",");
  Alcotest.(check (list string)) "split_lines" [ "a"; "b" ] (S.split_lines "a\nb");
  Alcotest.(check (list string)) "split_on_char" [ "a"; "b" ] (S.split_on_char ',' "a,b");
  Alcotest.(check (option int)) "index_of" (Some 3) (S.index_of "foobar" "bar");
  Alcotest.(check (option int)) "index_of from" (Some 3) (S.index_of "ababa" ~from:2 "ba");
  Alcotest.(check (option int)) "index_of missing" None (S.index_of "abc" "d");
  Alcotest.(check (option int)) "last_index_of" (Some 3) (S.last_index_of "ababa" "ba");
  Alcotest.(check string) "replace" "aXbXc" (S.replace "a,b,c" ~from:"," ~by:"X");
  Alcotest.(check string) "replace_first" "aXb,c" (S.replace_first "a,b,c" ~from:"," ~by:"X");
  Alcotest.(check string) "replace missing" "abc" (S.replace "abc" ~from:"z" ~by:"X")

let () =
  Alcotest.run "Str"
    [
      ("concat", [ Alcotest.test_case "ops" `Quick test_concat ]);
      ("predicates", [ Alcotest.test_case "ops" `Quick test_predicates ]);
      ("transforms", [ Alcotest.test_case "ops" `Quick test_transforms ]);
      ("split+find", [ Alcotest.test_case "ops" `Quick test_split_find ]);
    ]
