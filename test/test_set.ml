open Clj_core

let s = Set.of_list [ 3; 1; 2 ]
let int_list = Alcotest.(list int)

let test_basics () =
  Alcotest.(check int_list) "sorted" [ 1; 2; 3 ] (Set.to_list s);
  Alcotest.(check int) "count" 3 (Set.count s);
  Alcotest.(check bool) "contains" true (Set.contains_ s 2);
  Alcotest.(check bool) "contains no" false (Set.contains_ s 9);
  Alcotest.(check bool) "mem" true (Set.mem 1 s);
  Alcotest.(check bool) "empty" true (Set.empty_ (Set.empty ()));
  Alcotest.(check (option int)) "min" (Some 1) (Set.min_elt s);
  Alcotest.(check (option int)) "max" (Some 3) (Set.max_elt s);
  Alcotest.(check int_list) "singleton" [ 5 ] (Set.to_list (Set.singleton 5))

let test_updates () =
  Alcotest.(check int_list) "conj" [ 1; 2; 3; 4 ] (Set.to_list (Set.conj s 4));
  Alcotest.(check int_list) "conj dup" [ 1; 2; 3 ] (Set.to_list (Set.conj s 2));
  Alcotest.(check int_list) "disj" [ 1; 3 ] (Set.to_list (Set.disj s 2));
  Alcotest.(check int_list) "into" [ 1; 2; 3; 4; 5 ] (Set.to_list (Set.into s (List.to_seq [ 4; 5; 4 ])))

let test_algebra () =
  let s2 = Set.of_list [ 2; 3; 4 ] in
  Alcotest.(check int_list) "union" [ 1; 2; 3; 4 ] (Set.to_list (Set.union s s2));
  Alcotest.(check int_list) "intersection" [ 2; 3 ] (Set.to_list (Set.intersection s s2));
  Alcotest.(check int_list) "difference" [ 1 ] (Set.to_list (Set.difference s s2));
  Alcotest.(check bool) "subset" true (Set.subset_ (Set.of_list [ 1; 2 ]) s);
  Alcotest.(check bool) "subset no" false (Set.subset_ s (Set.of_list [ 1; 2 ]));
  Alcotest.(check bool) "superset" true (Set.superset_ s (Set.of_list [ 1; 2 ]))

let test_transforms () =
  Alcotest.(check int_list) "select" [ 2 ] (Set.to_list (Set.select (fun x -> x mod 2 = 0) s));
  Alcotest.(check int_list) "filter" [ 1; 3 ] (Set.to_list (Set.filter (fun x -> x mod 2 <> 0) s));
  Alcotest.(check int_list) "remove" [ 2 ] (Set.to_list (Set.remove (fun x -> x mod 2 <> 0) s));
  Alcotest.(check int_list) "map" [ 2; 4; 6 ] (Set.to_list (Set.map (fun x -> x * 2) s));
  Alcotest.(check int_list) "map collapse" [ 0; 1 ] (Set.to_list (Set.map (fun x -> x mod 2) s))

let test_iteration () =
  Alcotest.(check int) "fold" 6 (Set.fold ( + ) 0 s);
  Alcotest.(check bool) "every" true (Set.every_ (fun x -> x > 0) s);
  Alcotest.(check (option int)) "some" (Some 2) (Set.some (fun x -> x = 2) s);
  Alcotest.(check int_list) "rseq" [ 3; 2; 1 ] (List.of_seq (Set.rseq s));
  Alcotest.(check int_list) "slice" [ 2 ] (Set.to_list (Set.slice s ~from_:2 ~to_:3));
  Alcotest.(check bool) "equal" true (Set.equal s (Set.of_list [ 3; 2; 1 ]));
  Alcotest.(check int_list) "to_vec" [ 1; 2; 3 ] (Vec.to_list (Set.to_vec s));
  let desc = Set.of_list ~cmp:(fun a b -> Stdlib.compare b a) [ 1; 3; 2 ] in
  Alcotest.(check int_list) "custom cmp" [ 3; 2; 1 ] (Set.to_list desc)

(* model test vs Stdlib.Set.Make *)
module IS = Stdlib.Set.Make (Int)


let test_sorted_views () =
  let desc a b = Stdlib.compare b a in
  let s = Set.sorted_set_by desc [ 1; 3; 2 ] in
  Alcotest.(check (list int)) "sorted_set_by" [ 3; 2; 1 ]
    (Set.to_list s);
  let s = Set.of_list [ 1; 2; 3; 4 ] in
  Alcotest.(check (list int)) "subseq" [ 2; 3 ]
    (Stdlib.List.of_seq (Set.subseq ~from_:2 ~to_:4 s));
  Alcotest.(check (list int)) "rsubseq" [ 3; 2 ]
    (Stdlib.List.of_seq (Set.rsubseq ~from_:2 ~to_:4 s));
  Alcotest.(check (list int)) "subseq open" [ 3; 4 ]
    (Stdlib.List.of_seq (Set.subseq ~from_:3 s))

let test_model () =
  let rng = Random.State.make [| 13 |] in
  let s = ref (Set.empty ()) and m = ref IS.empty in
  for _ = 1 to 3000 do
    let x = Random.State.int rng 100 in
    match Random.State.int rng 3 with
    | 0 | 1 ->
      s := Set.conj !s x;
      m := IS.add x !m
    | _ ->
      s := Set.disj !s x;
      m := IS.remove x !m
  done;
  Alcotest.(check int_list) "elements" (IS.elements !m) (Set.to_list !s);
  for x = 0 to 99 do
    Alcotest.(check bool) (Printf.sprintf "mem %d" x) (IS.mem x !m) (Set.mem x !s)
  done

let test_coverage () =
  Alcotest.(check int_list) "hash_set" [ 1; 2; 3 ] (Set.to_list (Set.hash_set [ 3; 1; 2; 1 ]));
  Alcotest.(check int_list) "sorted_set" [ 1; 2; 3 ] (Set.to_list (Set.sorted_set [ 3; 1; 2 ]));
  Alcotest.(check bool) "for_all" true (Set.for_all (fun x -> x > 0) s);
  Alcotest.(check bool) "for_all no" false (Set.for_all (fun x -> x > 1) s);
  Alcotest.(check bool) "exists" true (Set.exists (fun x -> x = 2) s);
  Alcotest.(check bool) "exists miss" false (Set.exists (fun x -> x = 9) s)

let () =
  Alcotest.run "Set"
    [
      ("basics", [ Alcotest.test_case "ops" `Quick test_basics ]);
      ("updates", [ Alcotest.test_case "ops" `Quick test_updates ]);
      ("algebra", [ Alcotest.test_case "ops" `Quick test_algebra ]);
      ("transforms", [ Alcotest.test_case "ops" `Quick test_transforms ]);
      ("iteration", [ Alcotest.test_case "ops" `Quick test_iteration ]);
      ("coverage", [ Alcotest.test_case "ops" `Quick test_coverage ]);
      ("sorted views", [ Alcotest.test_case "ops" `Quick test_sorted_views ]);
      ("model", [ Alcotest.test_case "random vs Stdlib.Set" `Slow test_model ]);
    ]
