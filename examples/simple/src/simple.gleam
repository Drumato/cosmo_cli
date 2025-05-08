import cosmo_cli
import gleam/bool
import gleam/dict
import gleam/io
import gleam/result

fn new_greet_command() -> cosmo_cli.Command {
  cosmo_cli.new_command(
    name: "greet",
    run: fn(c: cosmo_cli.Command) {
      let verbosity =
        result.unwrap(cosmo_cli.get_flag_bool(c, "--verbose"), False)
      let name = result.unwrap(cosmo_cli.get_flag_string(c, "--name"), "")
      io.println("Verbosity: " <> bool.to_string(verbosity))
      io.println("Name: " <> name)
      Ok(Nil)
    },
    option_fns: [
      cosmo_cli.with_command_short("Greet command"),
      cosmo_cli.with_command_long("Greet command with cosmo_cli"),
      cosmo_cli.with_command_flags([
        cosmo_cli.new_flag_bool("--verbose", [cosmo_cli.with_flag_short("-v")]),
        cosmo_cli.new_flag_string("--name", [
          cosmo_cli.with_flag_short("-n"),
          cosmo_cli.with_flag_default_string("gleam"),
        ]),
      ]),
    ],
  )
}

fn new_root_command() -> cosmo_cli.Command {
  cosmo_cli.new_command(name: "simple", run: fn(_) { Ok(Nil) }, option_fns: [
    cosmo_cli.with_command_short("Simple command"),
    cosmo_cli.with_command_long("Simple command with cosmo_cli"),
    cosmo_cli.with_command_sub_commands(
      dict.from_list([#("greet", new_greet_command())]),
    ),
  ])
}

pub fn main() -> Nil {
  let root_command = new_root_command()
  case
    cosmo_cli.run(root_command, ["simple", "greet", "-v", "-n", "gleam!!!"])
  {
    Ok(_) -> io.println("Command executed successfully")
    Error(err) -> io.println("Error: " <> err)
  }
}
