type 'a t = 'a Lazy.t

let delay f = Lazy.from_fun f
let force = Lazy.force
let deref = Lazy.force
let realized_ = Lazy.is_val
