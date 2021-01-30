defmodule PackageCompare.Cli do

  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
  `argv` can be -h or --help, which returns :help

  Otherwise it is a filename, neo4j database, username and passwword

  Return a tuple of `{filename, neo4j, user, password}` or :help if help was
  given.
  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean], aliases: [h: :help])
    case parse do
      { [ help: true], _, _ }
        -> :help

      { _, [filename, neo4j, user, password], _}
        -> {filename, neo4j, user, password}

      _ -> :help
    end
  end

  defp process(:help) do
    IO.puts """
    usage: package_compare filename database username password

    This loads a given node_modules file into a neo4j database

    """
    System.halt(0)
  end


  defp process({filename, neo4j, user, password}) do
    start(neo4j, user, password)

    File.read!(filename)
    |> PackageCompare.parse
    |> PackageCompare.add_package
    |> PackageCompare.Neo4jWrite.write_to_neo4j()
  end

  @doc "This is an example of how to start and application at runtime"
  def start(neo4j, user, password) do
    Bolt.Sips.start_link(url: "bolt://#{user}:#{password}@#{neo4j}")
  end

end
