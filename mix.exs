defmodule PackageCompare.MixProject do
  use Mix.Project

  def project do
    [
      app: :package_compare,
      escript: escript_config(),
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [
        :poison,
        :bolt_sips 
      ],
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 5.0"},
      {:bolt_sips, "~> 0.4.12"}
    ]
  end

  defp escript_config do
    [main_module: PackageCompare.Cli]
  end
end
