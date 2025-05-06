import cosmo_cli
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn root_command_run_test() {
  let c =
    cosmo_cli.new_command(
      name: "root_command_run",
      run: fn(_) { Ok(Nil) },
      option_fns: [],
    )

  cosmo_cli.run(c, ["root_command_run"])
  |> should.be_ok()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  1
  |> should.equal(1)
}
