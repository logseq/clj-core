open Clj_core

let int_list = Alcotest.(list int)

let test_fifo () =
  let q = Queue.empty |> fun q -> Queue.conj (Queue.conj (Queue.conj q 1) 2) 3 in
  Alcotest.(check int_list) "order" [ 1; 2; 3 ] (Queue.to_list q);
  Alcotest.(check (option int)) "peek" (Some 1) (Queue.peek q);
  let q2 = Queue.pop q in
  Alcotest.(check int_list) "pop" [ 2; 3 ] (Queue.to_list q2);
  Alcotest.(check int_list) "orig unchanged" [ 1; 2; 3 ] (Queue.to_list q);
  Alcotest.(check int_list) "pop empty raises or fails" []
    (match Queue.pop_opt Queue.empty with None -> [] | Some _ -> [ 1 ]);
  Alcotest.check_raises "pop empty" (Invalid_argument "Clj_core.Queue.pop: pop on empty queue")
    (fun () -> ignore (Queue.pop Queue.empty))

let test_drain_and_refill () =
  (* push into rear, drain front, keep enqueueing — exercises both halves *)
  let q = Queue.of_list [ 1; 2; 3 ] |> fun q -> Queue.conj (Queue.conj q 4) 5 in
  let a, q = Option.get (Queue.pop_full q) in
  let b, q = Option.get (Queue.pop_full q) in
  Alcotest.(check (pair int int)) "order" (1, 2) (a, b);
  Alcotest.(check int_list) "rest" [ 3; 4; 5 ] (Queue.to_list q);
  let q = Queue.conj q 6 in
  Alcotest.(check int_list) "refill" [ 3; 4; 5; 6 ] (Queue.to_list q);
  let rec drain q acc =
    match Queue.pop_full q with
    | Some (x, q') -> drain q' (x :: acc)
    | None -> List.rev acc
  in
  Alcotest.(check int_list) "drain all" [ 3; 4; 5; 6 ] (drain q [])

let test_basics () =
  Alcotest.(check int) "count" 3 (Queue.count (Queue.of_list [ 1; 2; 3 ]));
  Alcotest.(check bool) "empty_" true (Queue.empty_ Queue.empty);
  Alcotest.(check int_list) "queue ctor" [ 1; 2 ] (Queue.to_list (Queue.queue [ 1; 2 ]));
  Alcotest.(check (option int_list)) "next" (Some [ 2; 3 ])
    (Option.map Queue.to_list (Queue.next (Queue.of_list [ 1; 2; 3 ])));
  Alcotest.(check (option int_list)) "next singleton" None
    (Option.map Queue.to_list (Queue.next (Queue.of_list [ 1 ])));
  Alcotest.(check int_list) "rest" [ 2; 3 ] (Queue.to_list (Queue.rest (Queue.of_list [ 1; 2; 3 ])));
  Alcotest.(check int_list) "rest empty" [] (Queue.to_list (Queue.rest Queue.empty));
  Alcotest.(check int_list) "into" [ 1; 2; 3; 4 ] (Queue.to_list (Queue.into (Queue.of_list [ 1; 2 ]) (List.to_seq [ 3; 4 ])));
  Alcotest.(check int) "fold" 6 (Queue.fold ( + ) 0 (Queue.of_list [ 1; 2; 3 ]));
  Alcotest.(check int_list) "to_vec" [ 1; 2 ] (Vec.to_list (Queue.to_vec (Queue.of_list [ 1; 2 ])));
  Alcotest.(check bool) "equal" true (Queue.equal (Queue.of_list [ 1 ]) (Queue.of_list [ 1 ]));
  Alcotest.(check int_list) "of_seq" [ 1; 2 ] (Queue.to_list (Queue.of_seq (List.to_seq [ 1; 2 ])))

let () =
  Alcotest.run "Queue"
    [
      ("fifo", [ Alcotest.test_case "ops" `Quick test_fifo ]);
      ("drain+refill", [ Alcotest.test_case "ops" `Quick test_drain_and_refill ]);
      ("basics", [ Alcotest.test_case "ops" `Quick test_basics ]);
    ]
