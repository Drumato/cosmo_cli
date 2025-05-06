import cosmo_cli
import gleam/dict
import gleam/io

pub fn main() -> Nil {
  let root_command =
    cosmo_cli.new_command(
      name: "simple",
      run: fn(_) {
        io.println("Hello from simple!")
        Ok(Nil)
      },
      option_fns: [
        cosmo_cli.with_command_short("Simple command"),
        cosmo_cli.with_command_long("Simple command with cosmo_cli"),
        cosmo_cli.with_command_sub_commands(
          dict.from_list([
            #(
              "greet",
              cosmo_cli.new_command(
                name: "greet",
                run: fn(_) {
                  io.println("Hello from greet!")
                  Ok(Nil)
                },
                option_fns: [
                  cosmo_cli.with_command_short("Greet command"),
                  cosmo_cli.with_command_long("Greet command with cosmo_cli"),
                ],
              ),
            ),
          ]),
        ),
      ],
    )
  case cosmo_cli.run_with_argv(root_command) {
    Ok(_) -> io.println("Command executed successfully")
    Error(err) -> io.println("Error: " <> err)
  }
}
