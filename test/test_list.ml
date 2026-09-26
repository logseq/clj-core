open Clj_core
module L = List

let l = [ 1; 2; 3; 4; 5 ]
let int_list = Alcotest.(list int)

let test_basics () =
  Alcotest.(check int) "count" 5 (L.count l);
  Alcotest.(check (option int)) "first" (Some 1) (L.first l);
  Alcotest.(check (option int)) "first empty" None (L.first []);
  Alcotest.(check int_list) "rest" [ 2; 3; 4; 5 ] (L.rest l);
  Alcotest.(check int_list) "rest empty" [] (L.rest []);
  Alcotest.(check (option int_list)) "next" (Some [ 2; 3; 4; 5 ]) (L.next l);
  Alcotest.(check (option int_list)) "next singleton" None (L.next [ 1 ]);
  Alcotest.(check (option int)) "second" (Some 2) (L.second l);
  Alcotest.(check (option int)) "last" (Some 5) (L.last l);
  Alcotest.(check int_list) "butlast" [ 1; 2; 3; 4 ] (L.butlast l);
  Alcotest.(check int) "nth" 3 (L.nth l 2);
  Alcotest.(check (option int)) "nth_opt" None (L.nth_opt l 9);
  Alcotest.(check int_list) "pop" [ 2; 3; 4; 5 ] (L.pop l);
  Alcotest.check_raises "pop empty" (Failure "Clj_core.List.pop: pop on empty list") (fun () -> ignore (L.pop []));
  Alcotest.(check int_list) "conj prepends" [ 0; 1; 2; 3; 4; 5 ] (L.conj l 0);
  Alcotest.(check int_list) "into reversed at front" [ 9; 8; 1; 2; 3; 4; 5 ] (L.into l (Stdlib.List.to_seq [ 8; 9 ]));
  Alcotest.(check bool) "mem" true (L.mem 3 l)

let test_transforms () =
  Alcotest.(check int_list) "map" [ 2; 4; 6; 8; 10 ] (L.map (fun x -> x * 2) l);
  Alcotest.(check int_list) "filter" [ 2; 4 ] (L.filter (fun x -> x mod 2 = 0) l);
  Alcotest.(check int_list) "remove" [ 1; 3; 5 ] (L.remove (fun x -> x mod 2 = 0) l);
  Alcotest.(check int_list) "keep" [ 2; 4 ] (L.keep (fun x -> if x mod 2 = 0 then Some x else None) l);
  Alcotest.(check int_list) "mapcat" [ 1; 1; 2; 2; 3; 3; 4; 4; 5; 5 ] (L.mapcat (fun x -> [ x; x ]) l);
  Alcotest.(check int_list) "concat" [ 1; 2; 3 ] (L.concat [ [ 1 ]; [ 2; 3 ] ]);
  Alcotest.(check int_list) "zip sum" [ 2; 4; 6; 8 ] (Stdlib.List.map (fun (a, b) -> a + b) (L.zip l [ 1; 2; 3; 4 ]));
  Alcotest.(check int_list) "map2" [ 2; 4; 6; 8; 10 ] (L.map2 ( + ) l [ 1; 2; 3; 4; 5 ]);
  Alcotest.(check int_list) "rev" [ 5; 4; 3; 2; 1 ] (L.rev l);
  Alcotest.(check int_list) "sort" [ 1; 2; 5; 9 ] (L.sort [ 5; 1; 9; 2 ]);
  Alcotest.(check int_list) "sort_by" [ 5; 4; 3; 2; 1 ] (L.sort_by ~cmp:Stdlib.compare (fun x -> -x) l);
  Alcotest.(check int_list) "distinct" [ 1; 2; 3 ] (L.distinct [ 1; 1; 2; 3; 2 ]);
  Alcotest.(check int_list) "dedupe" [ 1; 2; 3; 1 ] (L.dedupe [ 1; 1; 2; 2; 3; 1 ])

let test_folds () =
  Alcotest.(check int) "fold" 15 (L.fold ( + ) 0 l);
  Alcotest.(check int) "reduce" 15 (L.reduce ( + ) 0 l);
  Alcotest.(check int) "fold_right" 15 (L.fold_right ( + ) l 0);
  Alcotest.(check int) "reduce_r early" 6
    (L.reduce_r (fun acc x -> if x > 3 then Reduced.reduced acc else Reduced.continue (acc + x)) 0 l);
  Alcotest.(check bool) "every" true (L.every_ (fun x -> x > 0) l);
  Alcotest.(check (option int)) "some" (Some 4) (L.some (fun x -> x = 4) l);
  Alcotest.(check bool) "not_any" true (L.not_any_ (fun x -> x > 9) l);
  Alcotest.(check (option int)) "find_map" (Some 8) (L.find_map (fun x -> if x = 4 then Some (x * 2) else None) l)

let test_slices () =
  Alcotest.(check int_list) "take" [ 1; 2 ] (L.take 2 l);
  Alcotest.(check int_list) "take too many" l (L.take 9 l);
  Alcotest.(check int_list) "drop" [ 3; 4; 5 ] (L.drop 2 l);
  Alcotest.(check int_list) "take_while" [ 1; 2 ] (L.take_while (fun x -> x < 3) l);
  Alcotest.(check int_list) "drop_while" [ 3; 4; 5 ] (L.drop_while (fun x -> x < 3) l);
  Alcotest.(check int_list) "take_last" [ 4; 5 ] (L.take_last 2 l);
  Alcotest.(check int_list) "drop_last" [ 1; 2; 3 ] (L.drop_last 2 l);
  Alcotest.(check int_list) "take_nth" [ 1; 3; 5 ] (L.take_nth 2 l);
  Alcotest.(check int_list) "nthrest" [ 3; 4; 5 ] (L.nthrest l 2);
  let a, b = L.split_at 2 l in
  Alcotest.(check int_list) "split_at" [ 1; 2 ] a;
  Alcotest.(check int_list) "split_at b" [ 3; 4; 5 ] b;
  let a, b = L.split_with (fun x -> x < 3) l in
  Alcotest.(check int_list) "split_with" [ 1; 2 ] a;
  Alcotest.(check int_list) "split_with b" [ 3; 4; 5 ] b

let test_partitions () =
  Alcotest.(check (list int_list)) "partition" [ [ 1; 2 ]; [ 3; 4 ] ] (L.partition 2 l);
  Alcotest.(check (list int_list)) "partition_all" [ [ 1; 2 ]; [ 3; 4 ]; [ 5 ] ] (L.partition_all 2 l);
  Alcotest.(check (list int_list)) "partition_by" [ [ 1; 3 ]; [ 2; 4 ]; [ 5 ] ]
    (L.partition_by (fun x -> x mod 2) [ 1; 3; 2; 4; 5 ]);
  Alcotest.(check int_list) "interleave" [ 1; 6; 2; 7; 3; 8 ] (L.interleave [ 1; 2; 3; 4 ] [ 6; 7; 8 ]);
  Alcotest.(check int_list) "interpose" [ 1; 0; 2; 0; 3 ] (L.interpose 0 [ 1; 2; 3 ]);
  let g = L.group_by (fun x -> x mod 2) l in
  Alcotest.(check int_list) "group_by even" [ 2; 4 ] (Vec.to_list (Map.get g 0 |> Option.get));
  Alcotest.(check int_list) "group_by odd" [ 1; 3; 5 ] (Vec.to_list (Map.get g 1 |> Option.get));
  let f = L.frequencies [ 1; 1; 2; 3; 2; 1 ] in
  Alcotest.(check int) "frequencies" 3 (Map.get f 1 |> Option.get)

let test_conv () =
  Alcotest.(check int_list) "of_seq" [ 1; 2; 3 ] (L.of_seq (Stdlib.List.to_seq [ 1; 2; 3 ]));
  Alcotest.(check int_list) "of_vec" [ 1; 2 ] (L.of_vec (Vec.of_list [ 1; 2 ]));
  Alcotest.(check int_list) "to_vec" [ 1; 2; 3 ] (Vec.to_list (L.to_vec [ 1; 2; 3 ]));
  Alcotest.(check int_list) "of_array" [ 1; 2 ] (L.of_array [| 1; 2 |]);
  Alcotest.(check int) "to_array" 3 (L.to_array l).(2);
  Alcotest.(check bool) "equal" true (L.equal l [ 1; 2; 3; 4; 5 ]);
  Alcotest.(check bool) "equal no" false (L.equal l [ 1; 2; 3 ])

let test_coverage () =
  Alcotest.(check int_list) "flat_map" [ 1; 1; 2; 2 ] (L.flat_map (fun x -> [ x; x ]) [ 1; 2 ]);
  Alcotest.(check int_list) "flatten" [ 1; 2; 3; 4 ] (L.flatten [ [ 1; 2 ]; []; [ 3; 4 ] ]);
  let seen = ref [] in
  L.iteri (fun i x -> seen := (i, x) :: !seen) [ 10; 20 ];
  Alcotest.(check (list (pair int int))) "iteri" [ (1, 20); (0, 10) ] !seen;
  Alcotest.(check bool) "for_all" true (L.for_all (fun x -> x > 0) l);
  Alcotest.(check bool) "for_all no" false (L.for_all (fun x -> x > 3) l)

let () =
  Alcotest.run "List"
    [
      ("basics", [ Alcotest.test_case "ops" `Quick test_basics ]);
      ("transforms", [ Alcotest.test_case "ops" `Quick test_transforms ]);
      ("folds", [ Alcotest.test_case "ops" `Quick test_folds ]);
      ("slices", [ Alcotest.test_case "ops" `Quick test_slices ]);
      ("partitions", [ Alcotest.test_case "ops" `Quick test_partitions ]);
      ("conv", [ Alcotest.test_case "ops" `Quick test_conv ]);
      ("coverage", [ Alcotest.test_case "ops" `Quick test_coverage ]);
    ]
