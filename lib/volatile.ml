type 'a t = { mutable value : 'a }

let volatile v = { value = v }
let deref v = v.value

let vreset_bang v x =
  v.value <- x;
  x

let vswap_bang v f =
  let x = f v.value in
  v.value <- x;
  x
