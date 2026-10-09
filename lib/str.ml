module S = Stdlib.String

let str ss =
  let b = Buffer.create 64 in
  Stdlib.Seq.iter (fun x -> Buffer.add_string b x) ss;
  Buffer.contents b

let join ?(sep = "") ss =
  let b = Buffer.create 64 in
  let first = ref true in
  Stdlib.Seq.iter
    (fun s ->
      if not !first then Buffer.add_string b sep;
      first := false;
      Buffer.add_string b s)
    ss;
  Buffer.contents b

let join_list ?sep l = join ?sep (Stdlib.List.to_seq l)
let subs s start stop = S.sub s start (stop - start)
let length = S.length
let empty_ s = s = ""

let is_ws = function ' ' | '\t' | '\n' | '\r' | '\012' | '\011' -> true | _ -> false
let blank_ s = s = "" || Stdlib.Seq.for_all is_ws (S.to_seq s)
let trim = S.trim
let triml s =
  let rec go i = if i < S.length s && is_ws s.[i] then go (i + 1) else i in
  let i = go 0 in
  S.sub s i (S.length s - i)

let trimr s =
  let rec go i = if i >= 0 && is_ws s.[i] then go (i - 1) else i in
  S.sub s 0 (go (S.length s - 1) + 1)
let lower_case = S.lowercase_ascii
let upper_case = S.uppercase_ascii

let trim_newline s =
  let rec go i =
    if i >= 0 && (s.[i] = '\n' || s.[i] = '\r') then go (i - 1) else i
  in
  S.sub s 0 (go (S.length s - 1) + 1)

let capitalize s =
  if s = "" then s
  else S.uppercase_ascii (S.sub s 0 1) ^ S.lowercase_ascii (S.sub s 1 (S.length s - 1))

let starts_with_ s prefix =
  let n = S.length prefix in
  S.length s >= n && S.sub s 0 n = prefix

let ends_with_ s suffix =
  let n = S.length suffix and m = S.length s in
  m >= n && S.sub s (m - n) n = suffix

let index_of ?(from = 0) s needle =
  let n = S.length needle and m = S.length s in
  if n = 0 then (if from <= m then Some from else None)
  else begin
    let rec go i =
      if i + n > m then None
      else if S.sub s i n = needle then Some i
      else go (i + 1)
    in
    if from < 0 then go 0 else go from
  end

let includes_ s needle = index_of s needle <> None

let last_index_of s needle =
  let n = S.length needle and m = S.length s in
  if n = 0 then (if m = 0 then Some 0 else Some m)
  else begin
    let rec go i = if i < 0 then None else if S.sub s i n = needle then Some i else go (i - 1) in
    go (m - n)
  end

let split s ~on =
  let n = S.length on in
  if n = 0 then [ s ]
  else begin
    let rec go acc i =
      match index_of ~from:i s on with
      | Some j -> go (S.sub s i (j - i) :: acc) (j + n)
      | None -> Stdlib.List.rev (S.sub s i (S.length s - i) :: acc)
    in
    go [] 0
  end

let split_on_char = S.split_on_char
let split_lines s =
  match S.split_on_char '\n' s with
  | [] -> []
  | xs -> Stdlib.List.map (fun l -> if S.length l > 0 && l.[S.length l - 1] = '\r' then S.sub l 0 (S.length l - 1) else l) xs

let lines = split_lines

let replace s ~from ~by = join ~sep:by (Stdlib.List.to_seq (split s ~on:from))

let replace_first s ~from ~by =
  match index_of s from with
  | Some i -> S.sub s 0 i ^ by ^ S.sub s (i + S.length from) (S.length s - i - S.length from)
  | None -> s

let repeat s n =
  let b = Buffer.create (S.length s * n) in
  for _ = 1 to n do
    Buffer.add_string b s
  done;
  Buffer.contents b

let reverse s =
  let n = S.length s in
  S.init n (fun i -> s.[n - 1 - i])

let pad_left n ?(with_ = ' ') s =
  let pad = n - S.length s in
  if pad <= 0 then s else S.make pad with_ ^ s

let pad_right n ?(with_ = ' ') s =
  let pad = n - S.length s in
  if pad <= 0 then s else s ^ S.make pad with_

let escape s rules =
  let b = Buffer.create (S.length s) in
  S.iter
    (fun c ->
      match Stdlib.List.assoc_opt c rules with
      | Some r -> Buffer.add_string b r
      | None -> Buffer.add_char b c)
    s;
  Buffer.contents b
