import argv
import cosmo_cli/list_wrapper
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}

/// Flag is a struct that represents a command line flag.
pub opaque type Flag {
  /// FlagInt is a flag that takes an int value.
  FlagInt(
    short: Option(String),
    long: String,
    description: Option(String),
    value: Int,
  )
  /// FlagString is a flag that takes a string value.
  FlagString(
    short: Option(String),
    long: String,
    description: Option(String),
    value: String,
  )
  /// FlagBool is a flag that takes a boolean value.
  FlagBool(
    short: Option(String),
    long: String,
    description: Option(String),
    value: Bool,
  )
}

fn find_flag(flag_name: String) -> fn(Flag) -> Bool {
  fn(flag: Flag) -> Bool {
    case flag {
      FlagInt(short, long, ..) ->
        case long == flag_name {
          True -> True
          False ->
            case short {
              Some(short) -> short == flag_name
              None -> False
            }
        }
      FlagString(short, long, ..) ->
        case long == flag_name {
          True -> True
          False ->
            case short {
              Some(short) -> short == flag_name
              None -> False
            }
        }
      FlagBool(short, long, ..) ->
        case long == flag_name {
          True -> True
          False ->
            case short {
              Some(short) -> short == flag_name
              None -> False
            }
        }
    }
  }
}

/// new_flag_int creates a new int flag with the given long name and options.
pub fn new_flag_int(
  long_name: String,
  option_fns: List(fn(Flag) -> Flag),
) -> Flag {
  // TODO: validate the long name must start with `--`
  let flag = FlagInt(short: None, long: long_name, description: None, value: 0)
  list.fold(option_fns, flag, fn(flag, option_fn) { option_fn(flag) })
}

/// new_flag_string creates a new string flag with the given long name and options.
pub fn new_flag_string(
  long_name: String,
  option_fns: List(fn(Flag) -> Flag),
) -> Flag {
  // TODO: validate the long name must start with `--`
  let flag =
    FlagString(short: None, long: long_name, description: None, value: "")
  list.fold(option_fns, flag, fn(flag, option_fn) { option_fn(flag) })
}

/// new_flag_bool creates a new boolean flag with the given long name and options.
pub fn new_flag_bool(
  long_name: String,
  option_fns: List(fn(Flag) -> Flag),
) -> Flag {
  // TODO: validate the long name must start with `--`
  let flag =
    FlagBool(short: None, long: long_name, description: None, value: False)
  list.fold(option_fns, flag, fn(flag, option_fn) { option_fn(flag) })
}

/// with_flag_long sets the long name for a flag.
pub fn with_flag_short(short: String) -> fn(Flag) -> Flag {
  fn(flag: Flag) {
    case flag {
      FlagInt(..) -> FlagInt(..flag, short: Some(short))
      FlagString(..) -> FlagString(..flag, short: Some(short))
      FlagBool(..) -> FlagBool(..flag, short: Some(short))
    }
  }
}

/// with_flag_description sets the description for a flag.
pub fn with_flag_description(description: String) -> fn(Flag) -> Flag {
  fn(flag: Flag) {
    case flag {
      FlagInt(..) -> FlagInt(..flag, description: Some(description))
      FlagString(..) -> FlagString(..flag, description: Some(description))
      FlagBool(..) -> FlagBool(..flag, description: Some(description))
    }
  }
}

/// with_flag_default_int sets the default value for an int flag.
pub fn with_flag_default_int(default: Int) -> fn(Flag) -> Flag {
  fn(flag: Flag) {
    case flag {
      FlagInt(..) -> FlagInt(..flag, value: default)
      FlagString(..) -> flag
      FlagBool(..) -> flag
    }
  }
}

/// with_flag_default_string sets the default value for a string flag.
pub fn with_flag_default_string(default: String) -> fn(Flag) -> Flag {
  fn(flag: Flag) {
    case flag {
      FlagInt(..) -> flag
      FlagString(..) -> FlagString(..flag, value: default)
      FlagBool(..) -> flag
    }
  }
}

/// with_flag_default_bool sets the default value for a boolean flag.
pub fn with_flag_default_bool(default: Bool) -> fn(Flag) -> Flag {
  fn(flag: Flag) {
    case flag {
      FlagInt(..) -> flag
      FlagString(..) -> flag
      FlagBool(..) -> FlagBool(..flag, value: default)
    }
  }
}

/// Command is a struct that represents a command in the CLI.
pub opaque type Command {
  Command(
    name: String,
    short: Option(String),
    long: Option(String),
    run: fn(Command) -> Result(Nil, String),
    /// sub_commands is a map of subcommands for this command.
    sub_commands: Dict(String, Command),
    /// flags is a map of flags for this command.
    /// the key forms like `--flag` and `-f`.
    flags: List(Flag),
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
      flags: list.new(),
    )
  list.fold(option_fns, command, fn(command, option_fn) { option_fn(command) })
}

/// get_flag_int returns the value of an int flag.
/// the flag key must be the long name with double-hyphen.
pub fn get_flag_int(command: Command, flag_name: String) -> Result(Int, String) {
  case list.find(command.flags, find_flag(flag_name)) {
    Ok(flag) ->
      case flag {
        FlagInt(value: value, ..) -> Ok(value)
        FlagString(..) -> Error("Flag is not an int")
        FlagBool(..) -> Error("Flag is not an int")
      }
    Error(_) -> Error("Flag not found")
  }
}

/// get_flag_string returns the value of a string flag.
/// the flag key must be the long name with double-hyphen.
pub fn get_flag_string(
  command: Command,
  flag_name: String,
) -> Result(String, String) {
  case list.find(command.flags, find_flag(flag_name)) {
    Ok(flag) ->
      case flag {
        FlagInt(..) -> Error("Flag is not a string")
        FlagString(value: value, ..) -> Ok(value)
        FlagBool(..) -> Error("Flag is not a string")
      }
    Error(_) -> Error("Flag not found")
  }
}

/// get_flag_bool returns the value of a boolean flag.
/// the flag key must be the long name with double-hyphen.
pub fn get_flag_bool(
  command: Command,
  flag_name: String,
) -> Result(Bool, String) {
  case list.find(command.flags, find_flag(flag_name)) {
    Ok(flag) ->
      case flag {
        FlagInt(..) -> Error("Flag is not a boolean")
        FlagString(..) -> Error("Flag is not a boolean")
        FlagBool(value: value, ..) -> Ok(value)
      }
    Error(_) -> Error("Flag not found")
  }
}

/// with_command_short sets the short description for a command.
pub fn with_command_short(short: String) -> fn(Command) -> Command {
  fn(command: Command) { Command(..command, short: Some(short)) }
}

/// with_command_long sets the long description for a command.
pub fn with_command_long(long: String) -> fn(Command) -> Command {
  fn(command: Command) { Command(..command, long: Some(long)) }
}

/// with_command_run sets the run function for a command.
pub fn with_command_sub_commands(
  sub_commands: Dict(String, Command),
) -> fn(Command) -> Command {
  fn(command: Command) {
    let sub_commands = dict.merge(command.sub_commands, sub_commands)
    Command(..command, sub_commands: sub_commands)
  }
}

/// with_command_sub_commands sets the sub commands for a command.
pub fn with_command_flags(flags: List(Flag)) -> fn(Command) -> Command {
  fn(command: Command) { Command(..command, flags: flags) }
}

fn parse_flag_and_run(
  command: Command,
  flag_name: String,
  flag: Flag,
  args: List(String),
) -> Result(Nil, String) {
  let sub_args = list.drop(args, 1)
  case flag, sub_args {
    FlagInt(..), [] ->
      Error("Flag " <> flag_name <> " requires a value because it is an int")
    FlagString(..), [] ->
      Error("Flag " <> flag_name <> " requires a value because it is a string")
    FlagBool(..), _ -> {
      let updated_flag = FlagBool(..flag, value: True)
      let updated_command =
        Command(
          ..command,
          flags: list_wrapper.replace_by(
            command.flags,
            find_flag(flag_name),
            updated_flag,
          ),
        )
      run_command(updated_command, sub_args)
    }
    FlagString(..), [value, ..tail] -> {
      let updated_flag = FlagString(..flag, value: value)
      let updated_command =
        Command(
          ..command,
          flags: list_wrapper.replace_by(
            command.flags,
            find_flag(flag_name),
            updated_flag,
          ),
        )
      run_command(updated_command, tail)
    }
    FlagInt(..), [value, ..tail] -> {
      case int.parse(value) {
        Ok(value) -> {
          let updated_flag = FlagInt(..flag, value: value)
          let updated_command =
            Command(
              ..command,
              flags: list_wrapper.replace_by(
                command.flags,
                find_flag(flag_name),
                updated_flag,
              ),
            )
          run_command(updated_command, tail)
        }
        Error(_) -> Error("Flag " <> flag_name <> " requires a valid int value")
      }
    }
  }
}

fn run_command(
  command command: Command,
  args args: List(String),
) -> Result(Nil, String) {
  case args {
    [] -> command.run(command)
    [first, ..] -> {
      case list.find(command.flags, find_flag(first)) {
        Ok(flag) -> parse_flag_and_run(command, first, flag, args)
        Error(_) ->
          case dict.get(command.sub_commands, first) {
            Ok(sub_command) -> {
              let sub_args = list.drop(args, 1)
              run_command(sub_command, sub_args)
            }
            Error(_) -> Error("Command " <> first <> " not found")
          }
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
