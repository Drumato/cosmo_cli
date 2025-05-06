[![Package Version](https://img.shields.io/hexpm/v/cosmo_cli)](https://hex.pm/packages/cosmo_cli)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/cosmo_cli/)

# cosmo_cli

A Gleam library for building command line interfaces.
cosmo_cli is strongly inspired by [spf13/cobra](https://github.com/spf13/cobra).

```sh
gleam add cosmo_cli@1
```

Further documentation can be found at <https://hexdocs.pm/cosmo_cli>.

## Examples

All examples are in the `examples` directory.

- [simple](./examples/simple) ... A simplest CLI that shows us cosmo_cli can be received the raw `List(String)` arguments.
- [simple_argv](./examples/simple_argv) ... A simplest CLI that shows us we don't need to import argv library directly.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```

## Roadmap

- [ ] subcommands
- [ ] flags(short, long)
- [ ] dynamic completion
