defmodule Minirate.MixProject do
  use Mix.Project

  def project do
    [
      app: :minirate,
      description: "A dead simple distributed rate limiter using Mnesia",
      source_url: "https://github.com/4xposed/minirate",
      docs: docs(),
      package: package(),
      version: "0.1.0",
      elixir: "~> 1.8",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Minirate, []},
      extra_applications: [:logger, :mnesia]
    ]
  end

  def docs do
    [
      main: "Minirate",
      extras: ["README.md"]
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.0"},
      {:credo, "~> 1.1.2", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: :minirate,
      maintainers: ["Daniel Climent"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/4xposed/minirate"}
    ]
  end
end
