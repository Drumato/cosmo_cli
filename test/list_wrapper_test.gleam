import gleeunit
import gleeunit/should
import list_wrapper

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn replace_by_test() {
  let list = [1, 2, 3, 4, 5]
  let find_fn = fn(x) { x == 3 }
  let value = 99
  let result = list_wrapper.replace_by(list, find_fn, value)
  result |> should.equal([1, 2, 99, 4, 5])
}
