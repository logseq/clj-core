type 'a t = Continue of 'a | Reduced of 'a

let continue x = Continue x
let reduced x = Reduced x
let unreduced = function Continue x | Reduced x -> x
let reduced_ = function Reduced _ -> true | Continue _ -> false
