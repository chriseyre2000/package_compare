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
      commands
      | nodes: [
          %Neo4jQuery{query: "MERGE (n:project {name: {name}})", params: %{name: map.name}}
          | commands.nodes
        ]
    }

    commands = %{
      commands
      | nodes: [
          %Neo4jQuery{
            query: "MERGE (n:project_version {name: {name}, version: {version}} )",
            params: %{name: map.name, version: map.version}
          }
          | commands.nodes
        ]
    }

    commands = %{
      commands 
      | relationships: [
        %Neo4jQuery{
          query: """
                  MATCH (n:project { name: {name} }) 
                  MATCH (m:project_version {name: {name}, version: {version}})
                  MERGE  (n)-[:has_version]-> (m) 
                  """,
          params: %{name: map.name, version: map.version}
        }
        | commands.relationships
      ]
    }

    new_nodes = []
    new_relationships = []

    new_nodes = new_nodes ++ for {module, _version} <- map.devDependencies do
      %Neo4jQuery{
        query: "MERGE (n:module {name: {name}})",
        params: %{name: module}
      }
    end  

    new_nodes = new_nodes ++ for {module, version} <- map.devDependencies do
      %Neo4jQuery{
        query: "MERGE (n:module_version {name: {name}, version: {version}})",
        params: %{name: module, version: version}
      }
    end  

    new_relationships = new_relationships ++ for {module, version} <- map.devDependencies do
      %Neo4jQuery{
        query: """
               MATCH (n:module { name: {name} }) 
               MATCH (m:module_version {name: {name}, version: {version}})
               MERGE (n) -[:has_version]-> (m) 
               """,
        params: %{name: module, version: version}
      }
    end  

    new_relationships = new_relationships ++ for {module, version} <- map.devDependencies do
      %Neo4jQuery{
        query: """
               MATCH (n:project_version { name: {project}, version: {project_version}})
               MATCH (m:module_version {name: {name}, version: {version}})
               MERGE (n) -[:uses_dev_version]-> (m)
               """,
        params: %{project: map.name, project_version: map.version, name: module, version: version}
      }
    end  

    new_nodes = new_nodes ++ for {module, _version} <- map.dependencies do
      %Neo4jQuery{
        query: "MERGE (n:module {name: {name}})",
        params: %{name: module}
      }
    end  
    
    new_nodes = new_nodes ++ for {module, version} <- map.dependencies do
      %Neo4jQuery{
        query: "MERGE (n:module_version {name: {name}, version: {version}})",
        params: %{name: module, version: version}
      }
    end  

    new_relationships = new_relationships ++ for {module, version} <- map.dependencies do
      %Neo4jQuery{
        query: """
               MATCH (n:module { name: {name} })
               MATCH (m:module_version {name: {name}, version: {version}})
               MERGE (n) -[:has_version]-> (m)
               """,
        params: %{name: module, version: version}
      }
    end  

    new_relationships = new_relationships ++ for {module, version} <- map.dependencies do
      %Neo4jQuery{
        query: """
               MATCH (n:project_version { name: {project}, version: {project_version} })
               MATCH (m:module_version {name: {name}, version: {version}})
               MERGE (n) -[:uses_version]-> (m)
               """,
        params: %{project: map.name, project_version: map.version, name: module, version: version}
      }
    end  
    
    commands = %{commands | nodes: commands.nodes ++ new_nodes, relationships: commands.relationships ++ new_relationships}
    commands
  end
end
