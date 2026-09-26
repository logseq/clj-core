open Clj_core

let int_list = Alcotest.(list int)

let v = Vec.of_list [ 1; 2; 3; 4; 5 ]

let test_basics () =
  Alcotest.(check int) "count" 5 (Vec.count v);
  Alcotest.(check int) "nth" 3 (Vec.nth v 2);
  Alcotest.(check (option int)) "nth_opt oob" None (Vec.nth_opt v 9);
  Alcotest.(check (option int)) "first" (Some 1) (Vec.first v);
  Alcotest.(check (option int)) "last" (Some 5) (Vec.last v);
  Alcotest.(check bool) "empty" true (Vec.empty_ Vec.empty);
  Alcotest.(check bool) "not empty" false (Vec.empty_ v);
  Alcotest.(check bool) "contains in" true (Vec.contains_ v 3);
  Alcotest.(check bool) "contains out" false (Vec.contains_ v 5);
  Alcotest.(check bool) "mem" true (Vec.mem 4 v)

let test_persistent_updates () =
  let v2 = Vec.conj v 6 in
  Alcotest.(check int_list) "conj" [ 1; 2; 3; 4; 5; 6 ] (Vec.to_list v2);
  Alcotest.(check int_list) "orig unchanged" [ 1; 2; 3; 4; 5 ] (Vec.to_list v);
  let v3 = Vec.assoc v 0 99 in
  Alcotest.(check int) "assoc" 99 (Vec.nth v3 0);
  Alcotest.(check int_list) "assoc append" [ 1; 2; 3; 4; 5; 9 ] (Vec.to_list (Vec.assoc v 5 9));
  Alcotest.(check int_list) "update" [ 1; 20; 3; 4; 5 ] (Vec.to_list (Vec.update v 1 (fun x -> x * 10)));
  Alcotest.(check int_list) "pop" [ 1; 2; 3; 4 ] (Vec.to_list (Vec.pop v));
  Alcotest.(check bool) "pop_opt empty" true (Vec.pop_opt Vec.empty = None);
  Alcotest.check_raises "pop empty" (Invalid_argument "Clj_core.Vec.pop: pop on empty vector")
    (fun () -> ignore (Vec.pop Vec.empty));
  Alcotest.(check int_list) "cons" [ 0; 1; 2; 3; 4; 5 ] (Vec.to_list (Vec.cons 0 v));
  Alcotest.(check int_list) "insert_at" [ 1; 9; 2; 3; 4; 5 ] (Vec.to_list (Vec.insert_at v 1 9));
  Alcotest.(check int_list) "remove_at" [ 1; 3; 4; 5 ] (Vec.to_list (Vec.remove_at v 1))

let test_slices () =
  Alcotest.(check int_list) "subvec" [ 2; 3 ] (Vec.to_list (Option.get (Vec.subvec v 1 3)));
  Alcotest.(check int_list) "subvec_exn" [ 2; 3 ] (Vec.to_list (Vec.subvec_exn v 1 3));
  Alcotest.(check int_list) "slice clamped" [ 4; 5 ] (Vec.to_list (Vec.slice v ~start:3 ~stop:99));
  Alcotest.(check int_list) "take" [ 1; 2 ] (Vec.to_list (Vec.take 2 v));
  Alcotest.(check int_list) "drop" [ 3; 4; 5 ] (Vec.to_list (Vec.drop 2 v));
  Alcotest.(check int_list) "take_last" [ 4; 5 ] (Vec.to_list (Vec.take_last 2 v));
  Alcotest.(check int_list) "drop_last" [ 1; 2; 3 ] (Vec.to_list (Vec.drop_last 2 v));
  Alcotest.(check int_list) "butlast" [ 1; 2; 3; 4 ] (Vec.to_list (Vec.butlast v));
  let a, b = Vec.split_at 2 v in
  Alcotest.(check int_list) "split_at a" [ 1; 2 ] (Vec.to_list a);
  Alcotest.(check int_list) "split_at b" [ 3; 4; 5 ] (Vec.to_list b);
  Alcotest.(check int_list) "take_while" [ 1; 2 ] (Vec.to_list (Vec.take_while (fun x -> x < 3) v));
  Alcotest.(check int_list) "drop_while" [ 3; 4; 5 ] (Vec.to_list (Vec.drop_while (fun x -> x < 3) v))

let test_transforms () =
  Alcotest.(check int_list) "map" [ 2; 4; 6; 8; 10 ] (Vec.to_list (Vec.map (fun x -> x * 2) v));
  Alcotest.(check int_list) "mapi" [ 0; 2; 6; 12; 20 ] (Vec.to_list (Vec.mapi (fun i x -> i * x) v));
  Alcotest.(check int_list) "map_indexed" [ 1; 4; 9; 16; 25 ] (Vec.to_list (Vec.map_indexed (fun i x -> x * x) v));
  Alcotest.(check int_list) "filter" [ 2; 4 ] (Vec.to_list (Vec.filter (fun x -> x mod 2 = 0) v));
  Alcotest.(check int_list) "remove" [ 1; 3; 5 ] (Vec.to_list (Vec.remove (fun x -> x mod 2 = 0) v));
  Alcotest.(check int_list) "filter_map" [ 2; 4 ] (Vec.to_list (Vec.filter_map (fun x -> if x mod 2 = 0 then Some x else None) v));
  Alcotest.(check int_list) "keep" [ 2; 4 ] (Vec.to_list (Vec.keep (fun x -> if x mod 2 = 0 then Some x else None) v));
  Alcotest.(check int_list) "mapcat" [ 1; 1; 2; 2; 3; 3; 4; 4; 5; 5 ]
    (Vec.to_list (Vec.mapcat (fun x -> Vec.of_list [ x; x ]) v));
  Alcotest.(check int_list) "reverse" [ 5; 4; 3; 2; 1 ] (Vec.to_list (Vec.reverse v));
  Alcotest.(check int_list) "sort" [ 1; 1; 4; 5; 9 ] (Vec.to_list (Vec.sort (Vec.of_list [ 9; 1; 4; 1; 5 ])));
  Alcotest.(check int_list) "sort_by desc" [ 5; 4; 3; 2; 1 ]
    (Vec.to_list (Vec.sort_by ~cmp:Stdlib.compare (fun x -> -x) v));
  Alcotest.(check int_list) "distinct" [ 1; 2; 3 ] (Vec.to_list (Vec.distinct (Vec.of_list [ 1; 1; 2; 2; 3; 1 ])));
  Alcotest.(check int_list) "dedupe" [ 1; 2; 3; 1 ] (Vec.to_list (Vec.dedupe (Vec.of_list [ 1; 1; 2; 2; 3; 1 ])))

let test_folds () =
  Alcotest.(check int) "fold" 15 (Vec.fold_left ( + ) 0 v);
  Alcotest.(check int) "reduce" 15 (Vec.reduce ( + ) 0 v);
  Alcotest.(check int) "reduce_r early" 6
    (Vec.reduce_r
       (fun acc x -> if x > 3 then Reduced.reduced acc else Reduced.continue (acc + x))
       0 v);
  Alcotest.(check bool) "every_" true (Vec.every_ (fun x -> x > 0) v);
  Alcotest.(check bool) "every_ false" false (Vec.every_ (fun x -> x > 1) v);
  Alcotest.(check (option int)) "some" (Some 4) (Vec.some (fun x -> x > 3) v);
  Alcotest.(check bool) "not_any_" true (Vec.not_any_ (fun x -> x > 9) v);
  Alcotest.(check bool) "not_every_" true (Vec.not_every_ (fun x -> x > 1) v);
  Alcotest.(check (option int)) "find" (Some 4) (Vec.find (fun x -> x = 4) v)

let test_partitions_concat () =
  Alcotest.(check (list int_list)) "partition" [ [ 1; 2 ]; [ 3; 4 ] ]
    (Stdlib.List.map Vec.to_list (Vec.to_list (Vec.partition 2 v)));
  Alcotest.(check (list int_list)) "partition_all" [ [ 1; 2 ]; [ 3; 4 ]; [ 5 ] ]
    (Stdlib.List.map Vec.to_list (Vec.to_list (Vec.partition_all 2 v)));
  let a, b = Vec.split_by (fun x -> x < 3) v in
  Alcotest.(check int_list) "split_by a" [ 1; 2 ] (Vec.to_list a);
  Alcotest.(check int_list) "split_by b" [ 3; 4; 5 ] (Vec.to_list b);
  Alcotest.(check int_list) "concat" [ 1; 2; 3 ]
    (Vec.to_list (Vec.concat (Vec.of_list [ 1 ]) (Vec.of_list [ 2; 3 ])));
  Alcotest.(check int_list) "catvec" [ 1; 2; 3; 4 ]
    (Vec.to_list (Vec.catvec (Vec.of_list [ 1; 2 ]) (Vec.of_list [ 3; 4 ])));
  Alcotest.(check int_list) "append" [ 1; 2; 3; 4 ] (Vec.to_list (Vec.append (Vec.of_list [ 1; 2 ]) (Vec.of_list [ 3; 4 ])));
  Alcotest.(check int_list) "zip" [ 2; 4; 6; 8 ]
    (Stdlib.List.map (fun (a, b) -> a + b) (Vec.to_list (Vec.zip v (Vec.of_list [ 1; 2; 3; 4 ]))))

let test_seqs () =
  Alcotest.(check int_list) "to_seq" [ 1; 2; 3; 4; 5 ] (Stdlib.List.of_seq (Vec.to_seq v));
  Alcotest.(check int_list) "rseq" [ 5; 4; 3; 2; 1 ] (Stdlib.List.of_seq (Vec.rseq v));
  Alcotest.(check int_list) "rest" [ 2; 3; 4; 5 ] (Stdlib.List.of_seq (Vec.rest v));
  Alcotest.(check (option int_list)) "next" (Some [ 2; 3; 4; 5 ])
    (Option.map Stdlib.List.of_seq (Vec.next v));
  Alcotest.(check (option int_list)) "next singleton" None
    (Option.map Stdlib.List.of_seq (Vec.next (Vec.singleton 1)));
  Alcotest.(check int_list) "into" [ 0; 1; 2; 3; 4; 5 ]
    (Vec.to_list (Vec.into (Vec.of_list [ 0 ]) (Stdlib.List.to_seq [ 1; 2; 3; 4; 5 ])))

let test_generators () =
  Alcotest.(check int_list) "range" [ 0; 2; 4; 6; 8 ] (Vec.to_list (Vec.range ~step:2 10));
  Alcotest.(check int_list) "range down" [ 5; 3; 1 ] (Vec.to_list (Vec.range ~start:5 ~step:(-2) 0));
  Alcotest.(check int_list) "repeat" [ 7; 7; 7 ] (Vec.to_list (Vec.repeat 3 7));
  Alcotest.(check int_list) "init" [ 0; 1; 4; 9 ] (Vec.to_list (Vec.init 4 (fun i -> i * i)));
  Alcotest.(check bool) "equal" true (Vec.equal v (Vec.of_list [ 1; 2; 3; 4; 5 ]));
  Alcotest.(check bool) "not equal" false (Vec.equal v (Vec.of_list [ 1; 2; 3 ]));
  Alcotest.(check int) "compare" (-1) (Vec.compare (Vec.of_list [ 1; 2 ]) v)

(* model test: Vec behaves like Stdlib.Array under random ops *)
let test_model () =
  let rng = Random.State.make [| 42 |] in
  let v = ref Vec.empty and a = ref [||] in
  for _ = 1 to 2000 do
    let len = Array.length !a in
    match Random.State.int rng 7 with
    | 0 ->
      let x = Random.State.int rng 1000 in
      v := Vec.conj !v x;
      a := Array.append !a [| x |]
    | 1 when len > 0 ->
      v := Vec.pop !v;
      a := Array.sub !a 0 (len - 1)
    | 2 when len > 0 ->
      let i = Random.State.int rng len and x = Random.State.int rng 1000 in
      v := Vec.assoc !v i x;
      !a.(i) <- x
    | 3 when len > 0 ->
      let i = Random.State.int rng len in
      v := Vec.remove_at !v i;
      a := Array.of_list (Stdlib.List.filteri (fun j _ -> j <> i) (Array.to_list !a))
    | 4 when len > 0 ->
      let i = Random.State.int rng len and x = Random.State.int rng 1000 in
      v := Vec.insert_at !v i x;
      let l = Array.to_list !a in
      a := Array.of_list
             (Stdlib.List.filteri (fun j _ -> j < i) l
              @ (x :: Stdlib.List.filteri (fun j _ -> j >= i) l))
    | 5 ->
      let x = Random.State.int rng 1000 in
      v := Vec.cons x !v;
      a := Array.append [| x |] !a
    | _ when len > 1 ->
      let i = Random.State.int rng len and j = Random.State.int rng len in
      let lo = min i j and hi = max i j in
      v := Option.get (Vec.subvec !v lo hi);
      a := Array.sub !a lo (hi - lo)
    | _ -> ()
  done;
  Alcotest.(check int_list) "model matches array" (Array.to_list !a) (Vec.to_list !v)

let () =
  Alcotest.run "Vec"
    [
      ("basics", [ Alcotest.test_case "access" `Quick test_basics ]);
      ("persistent", [ Alcotest.test_case "updates" `Quick test_persistent_updates ]);
      ("slices", [ Alcotest.test_case "ops" `Quick test_slices ]);
      ("transforms", [ Alcotest.test_case "ops" `Quick test_transforms ]);
      ("folds", [ Alcotest.test_case "ops" `Quick test_folds ]);
      ("partition", [ Alcotest.test_case "ops" `Quick test_partitions_concat ]);
      ("seqs", [ Alcotest.test_case "ops" `Quick test_seqs ]);
      ("generators", [ Alcotest.test_case "ops" `Quick test_generators ]);
      ("model", [ Alcotest.test_case "random vs array" `Slow test_model ]);
    ]
