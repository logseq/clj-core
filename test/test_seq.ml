open Clj_core
module S = Seq

let int_list = Alcotest.(list int)
let to_list s = Stdlib.List.of_seq s

let test_gen () =
  Alcotest.(check int_list) "of_list" [ 1; 2; 3 ] (to_list (S.of_list [ 1; 2; 3 ]));
  Alcotest.(check int_list) "of_array" [ 1; 2 ] (to_list (S.of_array [| 1; 2 |]));
  Alcotest.(check int_list) "of_string" [ 97; 98 ] (List.map Char.code (to_list (S.of_string "ab")));
  Alcotest.(check int_list) "unfold" [ 0; 1; 2 ] (to_list (S.unfold (fun x -> if x < 3 then Some (x, x + 1) else None) 0));
  Alcotest.(check int_list) "init" [ 0; 1; 4 ] (to_list (S.init 3 (fun i -> i * i)));
  Alcotest.(check int_list) "iterate" [ 1; 2; 4; 8 ] (to_list (S.take 4 (S.iterate (fun x -> x * 2) 1)));
  Alcotest.(check int_list) "repeat n" [ 5; 5; 5 ] (to_list (S.repeat ~n:3 5));
  Alcotest.(check int_list) "repeat" [ 9; 9 ] (to_list (S.take 2 (S.repeat 9)));
  Alcotest.(check int_list) "repeatedly" [ 1; 1 ] (to_list (S.repeatedly ~n:2 (fun () -> 1)));
  Alcotest.(check int_list) "cycle" [ 1; 2; 1; 2; 1 ] (to_list (S.take 5 (S.cycle (S.of_list [ 1; 2 ]))));
  Alcotest.(check int_list) "range" [ 0; 2; 4 ] (to_list (S.range ~step:2 6));
  Alcotest.(check int_list) "range default" [ 0; 1; 2 ] (to_list (S.range 3));
  Alcotest.(check int_list) "ints" [ 5; 6; 7 ] (to_list (S.take 3 (S.ints ~start:5 ())));
  Alcotest.(check int_list) "lazy_seq" [ 1; 2 ] (to_list (S.lazy_seq (fun () -> S.of_list [ 1; 2 ])))

let test_access () =
  let s = S.of_list [ 1; 2; 3 ] in
  Alcotest.(check (option (pair int int_list))) "uncons" (Some (1, [ 2; 3 ]))
    (Option.map (fun (x, xs) -> (x, to_list xs)) (S.uncons s));
  Alcotest.(check (option int_list)) "seq" (Some [ 1; 2; 3 ])
    (Option.map to_list (S.seq s));
  Alcotest.(check bool) "seq empty none" true (S.seq S.empty = None);
  Alcotest.(check (option int)) "first" (Some 1) (S.first s);
  Alcotest.(check int_list) "rest" [ 2; 3 ] (to_list (S.rest s));
  Alcotest.(check (option int_list)) "next" (Some [ 2; 3 ]) (Option.map to_list (S.next s));
  Alcotest.(check (option int)) "second" (Some 2) (S.second s);
  Alcotest.(check (option int)) "last" (Some 3) (S.last s);
  Alcotest.(check int_list) "butlast" [ 1; 2 ] (to_list (S.butlast s));
  Alcotest.(check int) "nth" 2 (S.nth s 1);
  Alcotest.(check (option int)) "nth_opt" None (S.nth_opt s 9);
  Alcotest.(check int_list) "nthrest" [ 3 ] (to_list (S.nthrest s 2));
  Alcotest.(check int) "count" 3 (S.count s);
  Alcotest.(check bool) "is_empty" false (S.is_empty s)

let test_lazy () =
  let s = S.of_list [ 1; 2; 3; 4; 5 ] in
  Alcotest.(check int_list) "map" [ 2; 4; 6 ] (to_list (S.map (fun x -> x * 2) (S.of_list [ 1; 2; 3 ])));
  Alcotest.(check int_list) "mapi" [ 1; 4; 9; 16; 25 ] (to_list (S.mapi (fun i x -> (i + 1) * x) s));
  Alcotest.(check int_list) "filter" [ 2; 4 ] (to_list (S.filter (fun x -> x mod 2 = 0) s));
  Alcotest.(check int_list) "remove" [ 1; 3; 5 ] (to_list (S.remove (fun x -> x mod 2 = 0) s));
  Alcotest.(check int_list) "keep" [ 2; 4 ] (to_list (S.keep (fun x -> if x mod 2 = 0 then Some x else None) s));
  Alcotest.(check int_list) "keep_indexed" [ 0; 2; 4 ] (to_list (S.keep_indexed (fun i x -> if i mod 2 = 0 then Some (x - 1) else None) s));
  Alcotest.(check int_list) "mapcat" [ 1; 1; 2; 2 ] (to_list (S.mapcat (fun x -> S.of_list [ x; x ]) (S.of_list [ 1; 2 ])));
  Alcotest.(check int_list) "take" [ 1; 2 ] (to_list (S.take 2 s));
  Alcotest.(check int_list) "drop" [ 3; 4; 5 ] (to_list (S.drop 2 s));
  Alcotest.(check int_list) "take_last" [ 4; 5 ] (S.take_last 2 s);
  Alcotest.(check int_list) "drop_last" [ 1; 2; 3 ] (to_list (S.drop_last 2 s));
  Alcotest.(check int_list) "take_while" [ 1; 2 ] (to_list (S.take_while (fun x -> x < 3) s));
  Alcotest.(check int_list) "drop_while" [ 3; 4; 5 ] (to_list (S.drop_while (fun x -> x < 3) s));
  Alcotest.(check int_list) "take_nth" [ 1; 3; 5 ] (to_list (S.take_nth 2 s));
  Alcotest.(check int_list) "interleave" [ 1; 9; 2; 8 ] (to_list (S.interleave (S.of_list [ 1; 2; 3 ]) (S.of_list [ 9; 8 ])));
  Alcotest.(check int_list) "interpose" [ 1; 0; 2 ] (to_list (S.interpose 0 (S.of_list [ 1; 2 ])));
  Alcotest.(check int_list) "concat" [ 1; 2; 3 ] (to_list (S.concat (S.of_list [ S.of_list [ 1 ]; S.of_list [ 2; 3 ] ])));
  Alcotest.(check int_list) "concat_list" [ 1; 2; 3 ] (to_list (S.concat_list [ S.of_list [ 1 ]; S.of_list [ 2; 3 ] ]));
  Alcotest.(check int_list) "append" [ 1; 2 ] (to_list (S.append (S.of_list [ 1 ]) (S.of_list [ 2 ])));
  Alcotest.(check int_list) "dedupe" [ 1; 2; 1 ] (to_list (S.dedupe (S.of_list [ 1; 1; 2; 1; 1 ])));
  Alcotest.(check int_list) "distinct" [ 1; 2 ] (to_list (S.distinct (S.of_list [ 1; 1; 2; 1 ])))

let test_eager () =
  let s = S.of_list [ 3; 1; 2 ] in
  Alcotest.(check int_list) "sort" [ 1; 2; 3 ] (to_list (S.sort s));
  Alcotest.(check int_list) "sort_by" [ 3; 2; 1 ] (to_list (S.sort_by ~cmp:Stdlib.compare (fun x -> -x) s));
  Alcotest.(check int_list) "reverse" [ 2; 1; 3 ] (to_list (S.reverse s));
  Alcotest.(check int_list) "shuffle is perm" [ 1; 2; 3 ]
    (to_list (S.sort (S.shuffle ~rng:(Random.State.make [| 1 |]) s)));
  let g = S.group_by (fun x -> x mod 2) (S.of_list [ 1; 2; 3; 4 ]) in
  Alcotest.(check int_list) "group_by" [ 1; 3 ] (Vec.to_list (Map.get g 1 |> Option.get));
  let f = S.frequencies (S.of_list [ 1; 1; 2 ]) in
  Alcotest.(check int) "frequencies" 2 (Map.get f 1 |> Option.get);
  Alcotest.(check (option int)) "min_key" (Some 3) (S.min_key (fun x -> -x) s);
  Alcotest.(check (option int)) "max_key" (Some 3) (S.max_key (fun x -> x) s)

let test_folds () =
  let s = S.of_list [ 1; 2; 3; 4 ] in
  Alcotest.(check int) "reduce" 10 (S.reduce ( + ) 0 s);
  Alcotest.(check int) "fold_left" 10 (S.fold_left ( + ) 0 s);
  Alcotest.(check int_list) "reductions" [ 0; 1; 3; 6; 10 ] (to_list (S.reductions ( + ) 0 s));
  Alcotest.(check int) "reduce_r early" 6
    (S.reduce_r (fun acc x -> if x > 3 then Reduced.reduced acc else Reduced.continue (acc + x)) 0 s);
  Alcotest.(check bool) "every_" true (S.every_ (fun x -> x > 0) s);
  Alcotest.(check (option int)) "some" (Some 3) (S.some (fun x -> x = 3) s);
  Alcotest.(check bool) "not_any_" true (S.not_any_ (fun x -> x > 9) s);
  Alcotest.(check bool) "not_every_" true (S.not_every_ (fun x -> x > 1) s);
  Alcotest.(check (option int)) "find_map" (Some 6) (S.find_map (fun x -> if x = 3 then Some 6 else None) s);
  Alcotest.(check bool) "mem" true (S.mem 2 s)

let test_partitions () =
  let s = S.of_list [ 1; 2; 3; 4; 5 ] in
  Alcotest.(check (list int_list)) "partition" [ [ 1; 2 ]; [ 3; 4 ] ]
    (List.map to_list (to_list (S.partition 2 s)));
  Alcotest.(check (list int_list)) "partition_all" [ [ 1; 2 ]; [ 3; 4 ]; [ 5 ] ]
    (List.map to_list (to_list (S.partition_all 2 s)));
  Alcotest.(check (list int_list)) "partition_by" [ [ 1; 1 ]; [ 2 ]; [ 3; 3 ] ]
    (List.map to_list (to_list (S.partition_by (fun x -> x mod 2) (S.of_list [ 1; 1; 2; 3; 3 ]))));
  let a, b = S.split_at 2 s in
  Alcotest.(check int_list) "split_at" [ 1; 2 ] (to_list a);
  Alcotest.(check int_list) "split_at b" [ 3; 4; 5 ] (to_list b);
  let a, b = S.split_with (fun x -> x < 3) s in
  Alcotest.(check int_list) "split_with" [ 1; 2 ] (to_list a);
  Alcotest.(check int_list) "split_with b" [ 3; 4; 5 ] (to_list b)

let test_conv () =
  let s = S.of_list [ 1; 2; 3 ] in
  Alcotest.(check int_list) "doall" [ 1; 2; 3 ] (S.doall s);
  S.dorun s;
  Alcotest.(check int_list) "to_vec" [ 1; 2; 3 ] (Vec.to_list (S.to_vec s));
  Alcotest.(check int_list) "to_set" [ 1; 2; 3 ] (Set.to_list (S.to_set s));
  Alcotest.(check int_list) "of_vec" [ 1; 2 ] (to_list (S.of_vec (Vec.of_list [ 1; 2 ])));
  Alcotest.(check (list (pair string int))) "of_map" [ ("a", 1) ]
    (to_list (S.of_map (Map.of_list [ ("a", 1) ])));
  Alcotest.(check int_list) "of_queue" [ 1; 2 ] (to_list (S.of_queue (Queue.of_list [ 1; 2 ])))

let () =
  Alcotest.run "Seq"
    [
      ("generators", [ Alcotest.test_case "ops" `Quick test_gen ]);
      ("access", [ Alcotest.test_case "ops" `Quick test_access ]);
      ("lazy", [ Alcotest.test_case "ops" `Quick test_lazy ]);
      ("eager", [ Alcotest.test_case "ops" `Quick test_eager ]);
      ("folds", [ Alcotest.test_case "ops" `Quick test_folds ]);
      ("partitions", [ Alcotest.test_case "ops" `Quick test_partitions ]);
      ("conv", [ Alcotest.test_case "ops" `Quick test_conv ]);
    ]
