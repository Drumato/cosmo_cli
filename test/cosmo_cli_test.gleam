import cosmo_cli
import gleam/dict
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn root_command_run_test() {
  let c =
    cosmo_cli.new_command(name: "root", run: fn(_) { Ok(Nil) }, option_fns: [])

  cosmo_cli.run(c, ["root"])
  |> should.be_ok()
}

pub fn sub_command_run_test() {
  let c =
    cosmo_cli.new_command(name: "root", run: fn(_) { Ok(Nil) }, option_fns: [
      cosmo_cli.with_command_sub_commands(
        dict.from_list([
          #(
            "sub",
            cosmo_cli.new_command(
              name: "sub",
              run: fn(_) { Ok(Nil) },
              option_fns: [],
            ),
          ),
        ]),
      ),
    ])
  cosmo_cli.run(c, ["root", "sub"])
  |> should.be_ok()

  cosmo_cli.run(c, ["root", "sub2"])
  |> should.be_error()
}

pub fn grandchild_command_run_test() {
  let c =
    cosmo_cli.new_command(name: "root", run: fn(_) { Ok(Nil) }, option_fns: [
      cosmo_cli.with_command_sub_commands(
        dict.from_list([
          #(
            "sub",
            cosmo_cli.new_command(
              name: "sub",
              run: fn(_) { Ok(Nil) },
              option_fns: [
                cosmo_cli.with_command_sub_commands(
                  dict.from_list([
                    #(
                      "grandchild",
                      cosmo_cli.new_command(
                        name: "grandchild",
                        run: fn(_) { Ok(Nil) },
                        option_fns: [],
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ]),
      ),
    ])
  cosmo_cli.run(c, ["root", "sub"])
  |> should.be_ok()

  cosmo_cli.run(c, ["root", "sub", "grandchild"])
  |> should.be_ok()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  1
  |> should.equal(1)
}
