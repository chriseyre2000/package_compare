defmodule Neo4jQuery do
  defstruct [:query, params: %{}]

  def define_project(project_name) do
    %Neo4jQuery{query: "MERGE (n:project {name: {name}})", params: %{name: project_name}}
  end

  def define_project_version(project_name, project_version) do
    %Neo4jQuery{
      query: "MERGE (n:project_version {name: {name}, version: {version}} )",
      params: %{name: project_name, version: project_version}
    }
  end

  def define_project_has_version(project_name, project_version) do
    %Neo4jQuery{
      query: """
      MATCH (n:project { name: {name} })
      MATCH (m:project_version {name: {name}, version: {version}})
      MERGE  (n)-[:has_version]-> (m)
      """,
      params: %{name: project_name, version: project_version}
    }
  end

  def define_module_name(module) do
    %Neo4jQuery{
      query: "MERGE (n:module {name: {name}})",
      params: %{name: module}
    }
  end

  def define_module_version(module, version) do
    %Neo4jQuery{
      query: "MERGE (n:module_version {name: {name}, version: {version}})",
      params: %{name: module, version: version}
    }
  end

  def define_module_has_version(module, version) do
    %Neo4jQuery{
      query: """
      MATCH (n:module { name: {name} })
      MATCH (m:module_version {name: {name}, version: {version}})
      MERGE (n) -[:has_version]-> (m)
      """,
      params: %{name: module, version: version}
    }
  end

  def define_use_dev_dependency(project_name, project_version, module_name, module_version) do
    %Neo4jQuery{
      query: """
      MATCH (n:project_version { name: {project}, version: {project_version}})
      MATCH (m:module_version {name: {name}, version: {version}})
      MERGE (n) -[:uses_dev_version]-> (m)
      """,
      params: %{
        project: project_name,
        project_version: project_version,
        name: module_name,
        version: module_version
      }
    }
  end

  def define_use_runtime_dependency(project_name, project_version, module_name, module_version) do
    %Neo4jQuery{
      query: """
      MATCH (n:project_version { name: {project}, version: {project_version} })
      MATCH (m:module_version {name: {name}, version: {version}})
      MERGE (n) -[:uses_version]-> (m)
      """,
      params: %{
        project: project_name,
        project_version: project_version,
        name: module_name,
        version: module_version
      }
    }
  end
end
