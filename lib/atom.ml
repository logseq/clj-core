type 'a t = 'a ref

let atom v = ref v
let deref a = !a

let reset_bang a v =
  a := v;
  v

let swap_bang a f =
  let v = f !a in
  a := v;
  v

let compare_and_set_bang a old new_v =
  if !a == old then begin
    a := new_v;
    true
  end
  else false

let reset_vals_bang a v =
  let old = !a in
  a := v;
  (old, v)

let swap_vals_bang a f =
  let old = !a in
  let new_v = f old in
  a := new_v;
  (old, new_v)
