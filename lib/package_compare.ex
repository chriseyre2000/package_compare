defmodule PackageCompare do
  @moduledoc """
  Documentation for PackageCompare.
  """

  def parse(body) do
    Poison.Parser.parse!(body, %{keys: :atoms})
    |> Map.take([:name, :version, :dependencies, :devDependencies])
  end

  @doc """
  Returns a list of commands to be sent to a graph database

  This is a summary of the structure:

  (project)-[:has_version]->(project_version)
  (module)-[:has_version]->(module_version)
  (project_version)-[uses_dev_version]->(module_version)
  (project_version)-[uses_version]->(module_version)


  """
  def add_package(commands \\ %{nodes: [], relationships: []}, map) do
    commands = %{
      commands | nodes: [Neo4jQuery.define_project(map.name) | commands.nodes]
    }

    commands = %{
      commands | nodes: [ Neo4jQuery.define_project_version(map.name, map.version) | commands.nodes]
    }

    commands = %{
      commands | relationships: [ Neo4jQuery.define_project_has_version(map.name, map.version) | commands.relationships]
    }

    new_nodes = []
    new_relationships = []

    # This handles the no devDependencies case
    dev_dependencies = Map.get(map, :devDependencies, %{})

    new_nodes =
      new_nodes ++
        for {module, _version} <- dev_dependencies do
          Neo4jQuery.define_module_name(module)
        end

    new_nodes =
      new_nodes ++
        for {module, version} <- dev_dependencies do
          Neo4jQuery.define_module_version(module, version)
        end

    new_relationships =
      new_relationships ++
        for {module, version} <- dev_dependencies do
          Neo4jQuery.define_module_has_version(module, version)
        end

    new_relationships =
      new_relationships ++
        for {module, version} <- dev_dependencies do
          Neo4jQuery.define_use_dev_dependency(map.name, map.version, module, version)
        end

    new_nodes =
      new_nodes ++
        for {module, _version} <- map.dependencies do
          Neo4jQuery.define_module_name(module)
        end

    new_nodes =
      new_nodes ++
        for {module, version} <- map.dependencies do
          Neo4jQuery.define_module_version(module, version)
        end

    new_relationships =
      new_relationships ++
        for {module, version} <- map.dependencies do
          Neo4jQuery.define_module_has_version(module, version)
        end

    new_relationships =
      new_relationships ++
        for {module, version} <- map.dependencies do
          Neo4jQuery.define_use_runtime_dependency(map.name, map.version, module, version)
        end

    commands = %{
      commands
      | nodes: commands.nodes ++ new_nodes,
        relationships: commands.relationships ++ new_relationships
    }

    commands
  end


end
