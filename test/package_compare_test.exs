defmodule PackageCompareTest do
  use ExUnit.Case
  doctest PackageCompare

  @test_json """
  {
    "name": "ghpr",
    "version": "1.0.0",
    "description": "A dashboard for a github team's pull requests",
    "scripts": {
      "start": "node server.js",
      "run": "nodemon server.js",
      "dev": "webpack-dev-server --mode development",
      "build": "webpack --mode production",
      "heroku-postbuild": "npm run build -- --mode production --display-error-details"
    },
    "repository": {
      "type": "git",
      "url": "git+https://github.com/jaramir/ghpr.git"
    },
    "author": "Francesco Gigli <jaramir@gmail.com>",
    "license": "ISC",
    "bugs": {
      "url": "https://github.com/jaramir/ghpr/issues"
    },
    "homepage": "https://github.com/jaramir/ghpr#readme",
    "dependencies": {
      "array-flatten": "^2.1.1",
      "express": "^4.15.2",
      "parse-link-header": "^1.0.1",
      "react": "^15.4.2",
      "react-dom": "^15.4.2",
      "request": "^2.81.0"
    },
    "devDependencies": {
      "babel-core": "^6.24.0",
      "babel-loader": "7.1.4",
      "babel-preset-es2015": "^6.24.0",
      "babel-preset-react": "^6.23.0",
      "nodemon": "^1.11.0",
      "webpack": "4.5.0",
      "webpack-cli": "^2.0.14",
      "webpack-dev-server": "^3.1.3"
    }
  }
  """

  test "parse_json" do
    result = PackageCompare.parse(@test_json)
    assert Map.has_key?(result, :name)
    assert Map.has_key?(result, :version)
    assert Map.has_key?(result, :devDependencies)
    assert Map.has_key?(result, :dependencies)

    assert Map.keys(result) == [:dependencies, :devDependencies, :name, :version]
  end

  test "add_commands" do
    result = PackageCompare.parse(@test_json)

    commands = PackageCompare.add_package(result)

    assert commands.nodes |> Enum.count() == 30
    assert commands.relationships |> Enum.count() == 29
  end
end
