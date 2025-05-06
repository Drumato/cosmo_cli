import argv
import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}

/// Command is a struct that represents a command in the CLI.
pub opaque type Command {
  Command(
    name: String,
    short: Option(String),
    long: Option(String),
    run: fn(Command) -> Result(Nil, String),
    sub_commands: Dict(String, Command),
  )
}

/// new_command creates a new command with the given name, run function, and options.
pub fn new_command(
  name name: String,
  run run: fn(Command) -> Result(Nil, String),
  option_fns option_fns: List(fn(Command) -> Command),
) -> Command {
  let command =
    Command(
      name: name,
      short: None,
      long: None,
      run: run,
      sub_commands: dict.new(),
    )
  list.fold(option_fns, command, fn(command, option_fn) { option_fn(command) })
}

/// with_command_short sets the short description for a command.
pub fn with_command_short(short: String) -> fn(Command) -> Command {
  fn(command: Command) { Command(..command, short: Some(short)) }
}

/// with_command_long sets the long description for a command.
pub fn with_command_long(long: String) -> fn(Command) -> Command {
  fn(command: Command) { Command(..command, long: Some(long)) }
}

pub fn with_command_sub_commands(
  sub_commands: Dict(String, Command),
) -> fn(Command) -> Command {
  fn(command: Command) {
    let sub_commands = dict.merge(command.sub_commands, sub_commands)
    Command(..command, sub_commands: sub_commands)
  }
}

fn run_command(
  command command: Command,
  args args: List(String),
) -> Result(Nil, String) {
  case args {
    [] -> command.run(command)
    [first, ..] -> {
      // TODO: check the flags before checking the sub_commands
      case dict.get(command.sub_commands, first) {
        Ok(sub_command) -> {
          let sub_args = list.drop(args, 1)
          run_command(sub_command, sub_args)
        }
        Error(_) -> Error("Not found " <> first)
      }
    }
  }
}

/// run executes the root command with the given arguments.
/// It can be called with os argv that has the command name as the first argument.
pub fn run(
  command command: Command,
  args args: List(String),
) -> Result(Nil, String) {
  case args {
    [] -> Error("No command provided")
    [_, ..rest] -> {
      run_command(command, rest)
    }
  }
}

pub fn run_with_argv(command command: Command) -> Result(Nil, String) {
  let argv_all = argv.load()
  run(command, [argv_all.program, ..argv_all.arguments])
}

pub fn main() -> Nil {
  io.println("Hello from cosmo_cli!")
}
