open Clj_core

let m = Map.of_list [ ("a", 1); ("b", 2); ("c", 3) ]
let str_int_list = Alcotest.(list (pair string int))
let str_list = Alcotest.(list string)

let test_lookup () =
  Alcotest.(check (option int)) "get" (Some 2) (Map.get m "b");
  Alcotest.(check (option int)) "get missing" None (Map.get m "z");
  Alcotest.(check int) "get_or" 42 (Map.get_or 42 m "z");
  Alcotest.(check (option (pair string int))) "find" (Some ("a", 1)) (Map.find m "a");
  Alcotest.(check bool) "contains" true (Map.contains_ m "c");
  Alcotest.(check bool) "contains no" false (Map.contains_ m "z");
  Alcotest.(check int) "count" 3 (Map.count m);
  Alcotest.(check (option (pair string int))) "min_entry" (Some ("a", 1)) (Map.min_entry m);
  Alcotest.(check (option (pair string int))) "max_entry" (Some ("c", 3)) (Map.max_entry m);
  Alcotest.(check (option string)) "min_key" (Some "a") (Map.min_key m);
  Alcotest.(check (option string)) "max_key" (Some "c") (Map.max_key m)

let test_updates () =
  let m2 = Map.assoc m "d" 4 in
  Alcotest.(check str_int_list) "assoc sorted"
    [ ("a", 1); ("b", 2); ("c", 3); ("d", 4) ] (Map.to_list m2);
  Alcotest.(check str_int_list) "orig unchanged"
    [ ("a", 1); ("b", 2); ("c", 3) ] (Map.to_list m);
  Alcotest.(check str_int_list) "assoc overwrite" [ ("a", 9); ("b", 2); ("c", 3) ]
    (Map.to_list (Map.assoc m "a" 9));
  Alcotest.(check str_int_list) "dissoc" [ ("a", 1); ("c", 3) ] (Map.to_list (Map.dissoc m "b"));
  Alcotest.(check str_int_list) "dissoc missing" (Map.to_list m) (Map.to_list (Map.dissoc m "z"));
  Alcotest.(check str_int_list) "update" [ ("a", 10); ("b", 2); ("c", 3) ]
    (Map.to_list (Map.update m "a" (fun v -> Option.get v * 10)));
  Alcotest.(check str_int_list) "update missing" [ ("a", 1); ("b", 2); ("c", 3); ("z", 7) ]
    (Map.to_list (Map.update m "z" (fun _ -> 7)));
  Alcotest.(check str_int_list) "update_opt drop" [ ("b", 2); ("c", 3) ]
    (Map.to_list (Map.update_opt m "a" (fun _ -> None)));
  Alcotest.(check str_int_list) "conj" [ ("a", 1); ("b", 2); ("c", 3); ("d", 4) ]
    (Map.to_list (Map.conj m ("d", 4)))

let test_views () =
  Alcotest.(check str_list) "keys" [ "a"; "b"; "c" ] (Stdlib.List.of_seq (Map.keys m));
  Alcotest.(check (list int)) "vals" [ 1; 2; 3 ] (Stdlib.List.of_seq (Map.vals m));
  Alcotest.(check str_int_list) "entries" [ ("a", 1); ("b", 2); ("c", 3) ]
    (Map.entries m);
  Alcotest.(check str_int_list) "rseq" [ ("c", 3); ("b", 2); ("a", 1) ]
    (Stdlib.List.of_seq (Map.rseq m));
  Alcotest.(check str_int_list) "seq" [ ("a", 1); ("b", 2); ("c", 3) ] (Stdlib.List.of_seq (Map.seq m))

let test_transforms () =
  Alcotest.(check str_int_list) "map" [ ("a", 2); ("b", 4); ("c", 6) ]
    (Map.to_list (Map.map (fun v -> v * 2) m));
  Alcotest.(check str_int_list) "map_kv" [ ("a", 2); ("b", 3); ("c", 4) ]
    (Map.to_list (Map.map_kv (fun _ v -> v + 1) m));
  Alcotest.(check str_int_list) "update_vals" [ ("a", 11); ("b", 12); ("c", 13) ]
    (Map.to_list (Map.update_vals m (fun v -> v + 10)));
  Alcotest.(check str_int_list) "filter" [ ("b", 2) ]
    (Map.to_list (Map.filter (fun _ v -> v mod 2 = 0) m));
  Alcotest.(check str_int_list) "remove" [ ("a", 1); ("c", 3) ]
    (Map.to_list (Map.remove (fun _ v -> v mod 2 = 0) m));
  let m2 = Map.update_keys ~cmp:Stdlib.compare m String.uppercase_ascii in
  Alcotest.(check str_int_list) "update_keys" [ ("A", 1); ("B", 2); ("C", 3) ] (Map.to_list m2)

let test_builders () =
  Alcotest.(check str_int_list) "of_seq" [ ("a", 1); ("b", 2) ]
    (Map.to_list (Map.of_seq (Stdlib.List.to_seq [ ("b", 2); ("a", 1) ])));
  Alcotest.(check str_int_list) "of_array" [ ("x", 1) ]
    (Map.to_list (Map.of_array [| ("x", 1) |]));
  Alcotest.(check str_int_list) "hash_map" [ ("a", 1) ] (Map.to_list (Map.hash_map [ ("a", 1) ]));
  Alcotest.(check str_int_list) "sorted_map" [ ("a", 1) ] (Map.to_list (Map.sorted_map [ ("a", 1) ]));
  Alcotest.(check str_int_list) "zipmap" [ ("a", 1); ("b", 2) ]
    (Map.to_list (Map.zipmap [ "b"; "a" ] [ 2; 1 ]));
  Alcotest.(check str_int_list) "into" [ ("a", 1); ("b", 2); ("c", 3); ("z", 9) ]
    (Map.to_list (Map.into m (Stdlib.List.to_seq [ ("z", 9) ])))

let test_merge () =
  let m2 = Map.of_list [ ("b", 20); ("d", 4) ] in
  Alcotest.(check str_int_list) "merge" [ ("a", 1); ("b", 20); ("c", 3); ("d", 4) ]
    (Map.to_list (Map.merge m m2));
  Alcotest.(check str_int_list) "merge_with" [ ("a", 1); ("b", 22); ("c", 3); ("d", 4) ]
    (Map.to_list (Map.merge_with ( + ) m m2));
  Alcotest.(check str_int_list) "select_keys" [ ("a", 1); ("c", 3) ]
    (Map.to_list (Map.select_keys m [ "a"; "c"; "z" ]))

let test_iteration () =
  Alcotest.(check int) "fold" 6 (Map.fold (fun acc _ v -> acc + v) 0 m);
  Alcotest.(check bool) "every_" true (Map.every_ (fun _ v -> v > 0) m);
  Alcotest.(check (option (pair string int))) "some" (Some ("b", 2))
    (Map.some (fun _ v -> v = 2) m);
  Alcotest.(check (option string)) "find_map" (Some "b")
    (Map.find_map (fun k v -> if v = 2 then Some k else None) m);
  Alcotest.(check int) "count_matching" 2 (Map.count_matching (fun _ v -> v > 1) m);
  let acc = ref [] in
  Map.iter (fun k v -> acc := (k, v) :: !acc) m;
  Alcotest.(check str_int_list) "iter order" [ ("c", 3); ("b", 2); ("a", 1) ] !acc

let test_slice_equal () =
  Alcotest.(check str_int_list) "slice" [ ("b", 2) ] (Map.to_list (Map.slice m ~from_:"b" ~to_:"c"));
  Alcotest.(check str_int_list) "slice open" [ ("b", 2); ("c", 3) ] (Map.to_list (Map.slice m ~from_:"b"));
  Alcotest.(check bool) "equal" true (Map.equal m (Map.of_list [ ("c", 3); ("a", 1); ("b", 2) ]));
  Alcotest.(check bool) "equal diff val" false (Map.equal m (Map.of_list [ ("a", 1); ("b", 2); ("c", 4) ]));
  Alcotest.(check bool) "equal diff key" false (Map.equal m (Map.of_list [ ("a", 1); ("b", 2); ("d", 3) ]));
  let desc = Map.of_list ~cmp:(fun a b -> Stdlib.compare b a) [ ("a", 1); ("b", 2); ("c", 3) ] in
  Alcotest.(check str_int_list) "custom cmp order" [ ("c", 3); ("b", 2); ("a", 1) ] (Map.to_list desc)

(* model test: random assoc/dissoc vs sorted association list *)
let test_model () =
  let rng = Random.State.make [| 7 |] in
  let m = ref (Map.empty ()) and model = ref [] in
  let model_get k = Stdlib.List.assoc_opt k !model in
  let model_to_list () = Stdlib.List.sort compare !model in
  for _ = 1 to 5000 do
    let k = Random.State.int rng 50 in
    match Random.State.int rng 4 with
    | 0 | 1 | 2 ->
      let v = Random.State.int rng 1000 in
      m := Map.assoc !m k v;
      model := (k, v) :: Stdlib.List.remove_assoc k !model
    | _ ->
      m := Map.dissoc !m k;
      model := Stdlib.List.remove_assoc k !model
  done;
  Alcotest.(check (list (pair int int))) "to_list" (model_to_list ()) (Map.to_list !m);
  for k = 0 to 49 do
    Alcotest.(check (option int)) (Printf.sprintf "get %d" k) (model_get k) (Map.get !m k)
  done;
  Alcotest.(check int) "count" (Stdlib.List.length (model_to_list ())) (Map.count !m);
  let lo, hi = (10, 20) in
  let expected = Stdlib.List.filter (fun (k, _) -> k >= lo && k < hi) (model_to_list ()) in
  Alcotest.(check (list (pair int int))) "slice" expected (Map.to_list (Map.slice !m ~from_:lo ~to_:hi))

let test_coverage () =
  let am = Map.array_map [ ("x", 1); ("y", 2) ] in
  Alcotest.(check (option int)) "array_map" (Some 2) (Map.get am "y");
  Alcotest.(check (list (pair string int))) "array_map sorted" [ ("x", 1); ("y", 2) ] (Map.to_list am);
  Alcotest.(check int) "fold_kv" 6 (Map.fold_kv (fun acc _ v -> acc + v) 0 m);
  Alcotest.(check (list string)) "fold_kv keys" [ "c"; "b"; "a" ]
    (Map.fold_kv (fun acc k _ -> k :: acc) [] m);
  Alcotest.(check int) "reduce_kv" 6 (Map.reduce_kv (fun acc _ v -> acc + v) 0 m);
  Alcotest.(check (list (pair string int))) "slice_seq" [ ("b", 2); ("c", 3) ]
    (Stdlib.List.of_seq (Map.slice_seq m ~from_:"b"));
  Alcotest.(check (list (pair string int))) "slice_seq to" [ ("a", 1) ]
    (Stdlib.List.of_seq (Map.slice_seq m ~to_:"b"));
  Alcotest.(check (list (pair string int))) "slice inverted" []
    (Map.to_list (Map.slice m ~from_:"c" ~to_:"a"))

let () =
  Alcotest.run "Map"
    [
      ("lookup", [ Alcotest.test_case "ops" `Quick test_lookup ]);
      ("updates", [ Alcotest.test_case "ops" `Quick test_updates ]);
      ("views", [ Alcotest.test_case "ops" `Quick test_views ]);
      ("transforms", [ Alcotest.test_case "ops" `Quick test_transforms ]);
      ("builders", [ Alcotest.test_case "ops" `Quick test_builders ]);
      ("merge", [ Alcotest.test_case "ops" `Quick test_merge ]);
      ("iteration", [ Alcotest.test_case "ops" `Quick test_iteration ]);
      ("slice+equal", [ Alcotest.test_case "ops" `Quick test_slice_equal ]);
      ("coverage", [ Alcotest.test_case "ops" `Quick test_coverage ]);
      ("model", [ Alcotest.test_case "random vs assoc list" `Slow test_model ]);
    ]
