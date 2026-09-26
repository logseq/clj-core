open Clj_core

let int_list = Alcotest.(list int)
let to_list = Stdlib.List.of_seq

let test_coll () =
  let v = `Vec (Vec.of_list [ 1; 2; 3 ]) in
  Alcotest.(check int) "count vec" 3 (Core.count v);
  Alcotest.(check int) "count list" 2 (Core.count (`Lst [ 1; 2 ]));
  Alcotest.(check int) "count arr" 1 (Core.count (`Arr [| 7 |]));
  Alcotest.(check int) "count set" 3 (Core.count (`Set (Set.of_list [ 1; 2; 3 ])));
  Alcotest.(check int) "count str" 3 (Core.count (Core.coll_of_string "abc"));
  Alcotest.(check (option int)) "first vec" (Some 1) (Core.first v);
  Alcotest.(check (option char)) "first str" (Some 'a') (Core.first (Core.coll_of_string "abc"));
  Alcotest.(check (option (pair string int))) "first map" (Some ("a", 1))
    (Core.first (Core.coll_of_map (Map.of_list [ ("a", 1) ])));
  Alcotest.(check bool) "empty_ seq none" true (Core.seq (`Lst []) = None);
  Alcotest.(check (option int)) "second" (Some 2) (Core.second v);
  Alcotest.(check (option int)) "last" (Some 3) (Core.last v);
  Alcotest.(check int) "nth" 2 (Core.nth v 1);
  Alcotest.(check bool) "mem" true (Core.mem 2 v);
  Alcotest.(check int_list) "rest" [ 2; 3 ] (to_list (Core.rest v))

let test_coll_ops () =
  let v = `Vec (Vec.of_list [ 1; 2; 3; 4; 5 ]) in
  Alcotest.(check int_list) "map" [ 2; 4; 6; 8; 10 ] (to_list (Core.map (fun x -> x * 2) v));
  Alcotest.(check int_list) "filter" [ 2; 4 ] (to_list (Core.filter (fun x -> x mod 2 = 0) v));
  Alcotest.(check int_list) "remove" [ 1; 3; 5 ] (to_list (Core.remove (fun x -> x mod 2 = 0) v));
  Alcotest.(check int_list) "keep" [ 2; 4 ] (to_list (Core.keep (fun x -> if x mod 2 = 0 then Some x else None) v));
  Alcotest.(check int_list) "mapcat" [ 1; 1; 2; 2 ] (to_list (Core.mapcat (fun x -> `Lst [ x; x ]) (`Lst [ 1; 2 ])));
  Alcotest.(check int_list) "concat" [ 1; 2; 3 ] (to_list (Core.concat (`Lst [ `Lst [ 1 ]; `Lst [ 2; 3 ] ])));
  Alcotest.(check int_list) "take" [ 1; 2 ] (to_list (Core.take 2 v));
  Alcotest.(check int_list) "drop" [ 3; 4; 5 ] (to_list (Core.drop 2 v));
  Alcotest.(check int_list) "take_nth" [ 1; 3; 5 ] (to_list (Core.take_nth 2 v));
  Alcotest.(check int_list) "interpose" [ 1; 0; 2 ] (to_list (Core.interpose 0 (`Lst [ 1; 2 ])));
  Alcotest.(check int_list) "dedupe" [ 1; 2; 1 ] (to_list (Core.dedupe (`Lst [ 1; 1; 2; 1 ])));
  Alcotest.(check int_list) "distinct" [ 1; 2 ] (to_list (Core.distinct (`Lst [ 1; 1; 2; 1 ])));
  Alcotest.(check int_list) "reverse" [ 5; 4; 3; 2; 1 ] (to_list (Core.reverse v));
  Alcotest.(check int_list) "sort" [ 1; 2; 3 ] (to_list (Core.sort (`Lst [ 3; 1; 2 ])));
  Alcotest.(check int_list) "sort_by" [ 3; 2; 1 ] (to_list (Core.sort_by ~cmp:Stdlib.compare (fun x -> -x) (`Lst [ 1; 3; 2 ])));
  Alcotest.(check (list int_list)) "partition_all" [ [ 1; 2 ]; [ 3 ] ]
    (List.map to_list (to_list (Core.partition_all 2 (`Lst [ 1; 2; 3 ]))));
  Alcotest.(check int_list) "reductions" [ 0; 1; 3; 6 ] (to_list (Core.reductions ( + ) 0 (`Lst [ 1; 2; 3 ])))

let test_coll_folds () =
  let v = `Vec (Vec.of_list [ 1; 2; 3; 4 ]) in
  Alcotest.(check int) "reduce" 10 (Core.reduce ( + ) 0 v);
  Alcotest.(check bool) "every" true (Core.every_ (fun x -> x > 0) v);
  Alcotest.(check (option int)) "some" (Some 3) (Core.some (fun x -> x = 3) v);
  Alcotest.(check bool) "not_any" true (Core.not_any_ (fun x -> x > 9) v);
  Alcotest.(check (option int)) "find_map" (Some 6) (Core.find_map (fun x -> if x = 3 then Some 6 else None) v);
  Alcotest.(check int_list) "into_vec" [ 1; 2; 3 ] (Vec.to_list (Core.into_vec (`Lst [ 1; 2; 3 ])));
  Alcotest.(check int_list) "into_list" [ 1; 2 ] (Core.into_list (`Arr [| 1; 2 |]));
  Alcotest.(check int_list) "into_set" [ 1; 2 ] (Set.to_list (Core.into_set (`Lst [ 2; 1; 2 ])));
  Alcotest.(check (list (pair string int))) "into_map" [ ("a", 1) ]
    (Map.to_list (Core.into_map (`Lst [ ("a", 1) ])));
  let g = Core.group_by (fun x -> x mod 2) (`Lst [ 1; 2; 3 ]) in
  Alcotest.(check int_list) "group_by" [ 2 ] (Vec.to_list (Map.get g 0 |> Option.get));
  let f = Core.frequencies (`Lst [ 1; 1; 2 ]) in
  Alcotest.(check int) "frequencies" 2 (Map.get f 1 |> Option.get);
  Alcotest.(check (option int)) "min_key" (Some 2) (Core.min_key (fun x -> x) (`Lst [ 2; 3 ]));
  Alcotest.(check (option int)) "max_key" (Some 3) (Core.max_key (fun x -> x) (`Lst [ 2; 3 ]))

let test_combinators () =
  Alcotest.(check int) "identity" 1 (Core.identity 1);
  Alcotest.(check int) "constantly" 9 (Core.constantly 9 3);
  Alcotest.(check int) "comp" 6 (Core.comp succ (fun x -> x * 2) 2 |> fun x -> x + 1);
  Alcotest.(check bool) "complement" false (Core.complement Core.even_ 4);
  Alcotest.(check int) "fnil some" 2 (Core.fnil succ 0 (Some 1));
  Alcotest.(check int) "fnil none" 0 (Core.fnil succ 0 None);
  let a, b = Core.juxt succ pred 5 in
  Alcotest.(check (pair int int)) "juxt" (6, 4) (a, b);
  let a, b, c = Core.juxt3 succ pred Core.identity 5 in
  Alcotest.(check (triple int int int)) "juxt3" (6, 4, 5) (a, b, c);
  let calls = ref 0 in
  let mf = Core.memoize (fun x -> incr calls; x * 2) in
  ignore (mf 3);
  ignore (mf 3);
  Alcotest.(check int) "memoized once" 1 !calls;
  Alcotest.(check int) "if_" 1 (Core.if_ true (fun () -> 1) (fun () -> 2));
  let hit = ref false in
  Core.when_ true (fun () -> hit := true);
  Alcotest.(check bool) "when_" true !hit;
  let seen = ref None in
  Core.when_some (Some 7) (fun x -> seen := Some x);
  Alcotest.(check (option int)) "when_some" (Some 7) !seen;
  Alcotest.(check (option int)) "cond" (Some 2) (Core.cond [ (false, fun () -> 1); (true, fun () -> 2) ]);
  Alcotest.(check (option int)) "cond none" None (Core.cond [ (false, fun () -> 1) ]);
  Alcotest.(check int) "or_else" 3 (Core.or_else (Some 3) 9);
  Alcotest.(check int) "or_else none" 9 (Core.or_else None 9);
  Alcotest.(check bool) "nil_" true (Core.nil_ None);
  Alcotest.(check bool) "some_" true (Core.some_ (Some 1))

let test_numbers () =
  Alcotest.(check int) "inc" 2 (Core.inc 1);
  Alcotest.(check int) "dec" 0 (Core.dec 1);
  Alcotest.(check bool) "even" true (Core.even_ 4);
  Alcotest.(check bool) "odd" true (Core.odd_ 3);
  Alcotest.(check bool) "zero" true (Core.zero_ 0);
  Alcotest.(check bool) "pos" true (Core.pos_ 1);
  Alcotest.(check bool) "neg" true (Core.neg_ (-1));
  Alcotest.(check int) "abs" 3 (Core.abs (-3));
  Alcotest.(check int) "quot" (-2) (Core.quot (-7) 3);
  Alcotest.(check int) "rem" (-1) (Core.rem (-7) 3);
  Alcotest.(check int) "mod floored" 2 (Core.mod_ (-7) 3);
  Alcotest.(check int) "mod pos" 1 (Core.mod_ 7 3);
  Alcotest.(check int) "sum" 10 (Core.sum (`Lst [ 1; 2; 3; 4 ]));
  Alcotest.(check int) "product" 24 (Core.product (`Lst [ 1; 2; 3; 4 ]));
  Alcotest.(check (float 0.)) "sumf" 6. (Core.sumf (`Lst [ 1.; 2.; 3. ]));
  Alcotest.(check int) "min2" 1 (Core.min2 1 2);
  Alcotest.(check int) "rand_nth in coll" 1
    (let x = Core.rand_nth ~rng:(Random.State.make [| 1 |]) (`Lst [ 1 ]) in
     if x = 1 then 1 else 0)

let test_strings_refs () =
  Alcotest.(check string) "str" "abc" (Core.str (`Lst [ "a"; "b"; "c" ]));
  let a = Core.atom 1 in
  Alcotest.(check int) "deref atom" 1 (Core.deref (`Atom a));
  let d = Core.delay (fun () -> 5) in
  Alcotest.(check int) "deref delay" 5 (Core.deref (`Delay d));
  Alcotest.(check bool) "realized" true (Core.realized_ d);
  let v = Volatile.volatile 2 in
  Alcotest.(check int) "deref volatile" 2 (Core.deref (`Volatile v));
  let r = ref 3 in
  Alcotest.(check int) "deref ref" 3 (Core.deref (`Ref r))

let test_errors () =
  let data = Map.of_list [ ("reason", "boom") ] in
  let e = Core.ex_info "boom" data in
  Alcotest.(check string) "ex_message" "boom" (Core.ex_message e);
  Alcotest.(check (option string)) "ex_data"
    (Some "boom")
    (Option.bind (Core.ex_data e) (fun m -> Map.get m "reason"));
  Alcotest.(check bool) "ex_data plain none" true (Core.ex_data (Failure "x") = None)

let test_coverage () =
  Alcotest.(check (option int)) "ffirst" (Some 1)
    (Core.ffirst (`Lst [ Seq.of_list [ 1; 2 ]; Seq.of_list [ 3 ] ]));
  Alcotest.(check (option int)) "ffirst empty" None (Core.ffirst (`Lst []));
  Alcotest.(check int_list) "flat_map" [ 1; 1; 2; 2 ]
    (to_list (Core.flat_map (fun x -> `Lst [ x; x ]) (`Lst [ 1; 2 ])));
  let f = Core.comp3 (fun x -> x * 10) (fun x -> x + 1) (fun x -> x * 2) in
  Alcotest.(check int) "comp3" 50 (f 2);
  Alcotest.(check bool) "is_none" true (Core.is_none None);
  Alcotest.(check bool) "is_none no" false (Core.is_none (Some 1));
  let rng = Random.State.make [| 42 |] in
  let r = Core.rand ~rng () in
  Alcotest.(check bool) "rand bounds" true (r >= 0. && r < 1.);
  let ri = Core.rand_int ~rng 10 in
  Alcotest.(check bool) "rand_int bounds" true (ri >= 0 && ri < 10);
  Alcotest.(check bool) "rand_nth" true
    (Core.rand_nth ~rng (`Lst [ 1; 2; 3 ]) |> fun x -> x >= 1 && x <= 3);
  Alcotest.(check int) "max2" 2 (Core.max2 1 2);
  Core.print "clj-core test";
  Core.println "";
  Core.prn "";
  Alcotest.(check bool) "print fns run" true true

let () =
  Alcotest.run "Core"
    [
      ("coll", [ Alcotest.test_case "ops" `Quick test_coll ]);
      ("coll-ops", [ Alcotest.test_case "ops" `Quick test_coll_ops ]);
      ("coll-folds", [ Alcotest.test_case "ops" `Quick test_coll_folds ]);
      ("combinators", [ Alcotest.test_case "ops" `Quick test_combinators ]);
      ("numbers", [ Alcotest.test_case "ops" `Quick test_numbers ]);
      ("strings+refs", [ Alcotest.test_case "ops" `Quick test_strings_refs ]);
      ("errors", [ Alcotest.test_case "ops" `Quick test_errors ]);
      ("coverage", [ Alcotest.test_case "ops" `Quick test_coverage ]);
    ]
