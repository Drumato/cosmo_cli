import cosmo_cli
import gleam/dict
import gleam/io
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

pub fn root_command_with_int_flag_test() {
  let command_fn = fn(flag_value: Int) -> cosmo_cli.Command {
    cosmo_cli.new_command(
      name: "root",
      run: fn(command: cosmo_cli.Command) {
        case cosmo_cli.get_flag_int(command, "--count") {
          Ok(count) -> count |> should.equal(flag_value)
          Error(_) -> {
            io.println("Error: count flag not found")
            should.fail()
          }
        }
        Ok(Nil)
      },
      option_fns: [
        cosmo_cli.with_command_flags([
          cosmo_cli.new_flag_int("--count", [
            cosmo_cli.with_flag_short("-c"),
            cosmo_cli.with_flag_default_int(42),
          ]),
        ]),
      ],
    )
  }

  cosmo_cli.run(command_fn(33), ["root", "-c", "33"])
  |> should.be_ok()

  cosmo_cli.run(command_fn(33), ["root", "--count", "33"])
  |> should.be_ok()

  cosmo_cli.run(command_fn(42), ["root"])
  |> should.be_ok()
}

pub fn root_commad_with_string_flag_test() {
  let c =
    cosmo_cli.new_command(name: "root", run: fn(_) { Ok(Nil) }, option_fns: [
      cosmo_cli.with_command_flags([
        cosmo_cli.new_flag_string("--name", [cosmo_cli.with_flag_short("-n")]),
      ]),
    ])

  cosmo_cli.run(c, ["root", "-n", "gleam"])
  |> should.be_ok()

  cosmo_cli.run(c, ["root", "--name", "gleam"])
  |> should.be_ok()
}

pub fn root_command_with_bool_flag_test() {
  let c =
    cosmo_cli.new_command(name: "root", run: fn(_) { Ok(Nil) }, option_fns: [
      cosmo_cli.with_command_flags([
        cosmo_cli.new_flag_bool("--verbose", [cosmo_cli.with_flag_short("-v")]),
      ]),
    ])

  cosmo_cli.run(c, ["root", "-v"])
  |> should.be_ok()

  cosmo_cli.run(c, ["root", "--verbose"])
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
