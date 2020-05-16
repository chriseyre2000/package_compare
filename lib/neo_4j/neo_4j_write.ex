defmodule PackageCompare.Neo4jWrite do
  @moduledoc """
  This is responsible for sending the commands to neo4j  
  """

  def start(database, username, password) do
    Bolt.Sips.start_link(%{url: database, username: username, password: password})
  end

  def write_to_neo4j(data) do
    conn = Bolt.Sips.begin(Bolt.Sips.conn)
    
    Enum.each(data.nodes, fn(item) ->
       Bolt.Sips.query(conn, item.query, item.params)  
    end )

    #Relationships include the properties
    Enum.each(data.relationships, fn(item) -> 
       Bolt.Sips.query(conn, item.query, item.params)  
    end )

    Bolt.Sips.commit(conn)
  end   
end