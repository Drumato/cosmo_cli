pub fn replace_by(list: List(a), find_fn: fn(a) -> Bool, value: a) -> List(a) {
  case list {
    [] -> []
    [head, ..tail] ->
      case find_fn(head) {
        True -> [value, ..replace_by(tail, find_fn, value)]
        False -> [head, ..replace_by(tail, find_fn, value)]
      }
  }
}
