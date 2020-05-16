# PackageCompare

This is a utility that will parse and load a package.json file into a neo4j database.
The intent is to load many projects into the database and then perform analysis on them.

This requires you to have Elixir installed and Neo4j.

```
brew install neo4j
brew install elixir
```

## Usage
Once you have run ` MIX_ENV=prod mix escript.build` then you can use the following:

```
./package_compare path-to-the/package.json localhost neo4j_username neo4j_password
```

This can be installed as a local app on a mac by running:

```
cp package_compare /usr/local/bin/package_compare
```

