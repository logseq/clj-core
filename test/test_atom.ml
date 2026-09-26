open Clj_core

let test_atom () =
  let a = Atom.atom 0 in
  Alcotest.(check int) "deref" 0 (Atom.deref a);
  Alcotest.(check int) "reset" 5 (Atom.reset_bang a 5);
  Alcotest.(check int) "after reset" 5 (Atom.deref a);
  Alcotest.(check int) "swap" 6 (Atom.swap_bang a succ);
  Alcotest.(check (pair int int)) "reset_vals" (6, 9) (Atom.reset_vals_bang a 9);
  Alcotest.(check (pair int int)) "swap_vals" (9, 10) (Atom.swap_vals_bang a succ);
  let b = Atom.atom 1 in
  Alcotest.(check bool) "cas ok" true (Atom.compare_and_set_bang b 1 2);
  Alcotest.(check int) "cas applied" 2 (Atom.deref b);
  Alcotest.(check bool) "cas fail" false (Atom.compare_and_set_bang b 1 3);
  Alcotest.(check int) "cas unchanged" 2 (Atom.deref b)

let test_volatile () =
  let v = Volatile.volatile 0 in
  Alcotest.(check int) "deref" 0 (Volatile.deref v);
  ignore (Volatile.vreset_bang v 4);
  Alcotest.(check int) "vreset" 4 (Volatile.deref v);
  Alcotest.(check int) "vswap" 5 (Volatile.vswap_bang v succ);
  Alcotest.(check int) "vswap result" 5 (Volatile.deref v)

let test_delay () =
  let calls = ref 0 in
  let d = Delay.delay (fun () -> incr calls; 42) in
  Alcotest.(check bool) "not realized" false (Delay.realized_ d);
  Alcotest.(check int) "force" 42 (Delay.force d);
  Alcotest.(check bool) "realized" true (Delay.realized_ d);
  Alcotest.(check int) "deref" 42 (Delay.deref d);
  Alcotest.(check int) "memoized" 1 !calls

let test_reduced () =
  Alcotest.(check int) "unreduced" 3 (Reduced.unreduced (Reduced.reduced 3));
  Alcotest.(check int) "unreduced plain" 3 (Reduced.unreduced (Reduced.continue 3));
  Alcotest.(check bool) "reduced?" true (Reduced.reduced_ (Reduced.reduced 1));
  Alcotest.(check bool) "reduced? no" false (Reduced.reduced_ (Reduced.continue 1))

let () =
  Alcotest.run "Atom"
    [
      ("atom", [ Alcotest.test_case "ops" `Quick test_atom ]);
      ("volatile", [ Alcotest.test_case "ops" `Quick test_volatile ]);
      ("delay", [ Alcotest.test_case "ops" `Quick test_delay ]);
      ("reduced", [ Alcotest.test_case "ops" `Quick test_reduced ]);
    ]
