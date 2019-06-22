# PackageCompare

This is a utility that will parse and load a package.json file into a neo4j database.
The intent is to load many projects into the database and then perform analysis on them.

## Usage
Once you have run `mix escript.build` then you can use the following:

./package_compare path-to-the/package.json localhost neo4j_username neo4j_password

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `package_compare` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:package_compare, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/package_compare](https://hexdocs.pm/package_compare).

